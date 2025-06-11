-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("races",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Players = {}
local Cooldown = {}
local Paymented = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINIT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Mode in pairs(Races) do
		Players[Mode] = {}
		Paymented[Mode] = {}

		for Selected in pairs(Races[Mode]["Routes"]) do
			Players[Mode][Selected] = {}
			Paymented[Mode][Selected] = 0

			if Races[Mode]["Global"] then
				GlobalState[Mode..":"..Selected] = false
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISH
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Finish(Mode,Selected,Points)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Races[Mode] and Races[Mode]["Routes"] and Races[Mode]["Routes"][Selected] then
		if Active[Passport] then
			Active[Passport] = nil

			if Paymented[Mode][Selected] >= 1 then
				Paymented[Mode][Selected] = Paymented[Mode][Selected] - 1

				if Paymented[Mode][Selected] <= 0 then
					Paymented[Mode][Selected] = 0

					if Races[Mode] and Races[Mode]["Global"] and GlobalState[Mode..":"..Selected] then
						GlobalState[Mode..":"..Selected] = false
					end
				end
			end

			local GainExperience = 8
			local MinCalculate = parseInt(Races[Mode]["Routes"][Selected]["Payment"] * 0.75)
			local MaxCalculate = parseInt(Races[Mode]["Routes"][Selected]["Payment"] * 1.25)
			local Amount = math.random(MinCalculate,MaxCalculate)
			local Experience,Level = vRP.GetExperience(Passport,"Race")
			local Valuation = Amount + Amount * (0.025 * Level)

			if exports["inventory"]:Buffs("Dexterity",Passport) then
				Valuation = Valuation + (Valuation * 0.1)
			end

			if vRP.UserPremium(Passport) then
				local Hierarchy = vRP.LevelPremium(source)
				local Bonification = (Hierarchy == 1 and 0.100) or (Hierarchy == 2 and 0.075) or (Hierarchy >= 3 and 0.050)

				Valuation = Valuation + (Valuation * Bonification)
				GainExperience = GainExperience + 4
			end

			vRP.UpgradeStress(Passport,10)
			exports["markers"]:Exit(source,Passport)
			vRP.RolepassPoints(Passport,GainExperience,true)
			vRP.PutExperience(Passport,"Race",GainExperience)
			vRP.GenerateItem(Passport,"dirtydollar",Valuation,true)
		end

		local Vehicle = vRPC.VehicleName(source)
		local Consult = vRP.Query("Races/User",{ Mode = Mode, Race = Selected, Passport = Passport })
		if Consult[1] then
			if Points < Consult[1]["Points"] then
				vRP.Query("Races/Update",{ Mode = Mode, Race = Selected, Passport = Passport, Vehicle = Vehicle, Points = Points })
			end
		else
			vRP.Query("Races/Insert",{ Mode = Mode, Race = Selected, Passport = Passport, Vehicle = Vehicle, Points = Points })
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- START
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Start(Mode,Selected)
	local Return = false
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Races[Mode] and Races[Mode]["Routes"] and Races[Mode]["Routes"][Selected] and (Races[Mode]["Global"] and not GlobalState[Mode..":"..Selected]) then
		if Cooldown[Passport] and Cooldown[Passport][Mode] and Cooldown[Passport][Mode][Selected] and Cooldown[Passport][Mode][Selected] >= os.time() then
			TriggerClientEvent("Notify",source,"Atenção","Aguarde "..CompleteTimers(Cooldown[Passport][Mode][Selected] - os.time())..".","amarelo",5000)
		elseif vRP.RemoveCharges(Passport,"races") then
			if not Cooldown[Passport] then
				Cooldown[Passport] = {}
				Cooldown[Passport][Mode] = {}
				Cooldown[Passport][Mode][Selected] = os.time()
			end

			if not Players[Mode][Selected][Passport] then
				Players[Mode][Selected][Passport] = source
			end

			exports["markers"]:Enter(source,"Corredor")
			Return = Races[Mode]["Routes"][Selected]["Time"]
			Cooldown[Passport][Mode][Selected] = os.time() + 7200
			Paymented[Mode][Selected] = Paymented[Mode][Selected] + 1
			Active[Passport] = { ["Mode"] = Mode, ["Selected"] = Selected }

			local Service = vRP.NumPermission("Policia")
			for Passports,Sources in pairs(Service) do
				async(function()
					vRPC.PlaySound(Sources,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
					TriggerClientEvent("Notify",Sources,"Circuitos","Encontramos um veículo participando de uma corrida clandestina e todos os policiais foram avisados.","policia",10000)
				end)
			end
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Cancel()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Active[Passport] then
		exports["markers"]:Exit(source,Passport)

		local Mode = Active[Passport]["Mode"]
		local Selected = Active[Passport]["Selected"]
		if Players[Mode][Selected][Passport] then
			Players[Mode][Selected][Passport] = nil

			if Paymented[Mode][Selected] >= 1 then
				Paymented[Mode][Selected] = Paymented[Mode][Selected] - 1

				if Paymented[Mode][Selected] <= 0 then
					Paymented[Mode][Selected] = 0

					if Races[Mode] and Races[Mode]["Global"] and GlobalState[Mode..":"..Selected] then
						GlobalState[Mode..":"..Selected] = false
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.GlobalState(Mode,Selected)
	if Races[Mode] and Races[Mode]["Global"] and not GlobalState[Mode..":"..Selected] then
		TriggerClientEvent("races:Start",-1,Mode,Selected)
		GlobalState[Mode..":"..Selected] = true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Ranking(Mode,Selected,Count)
	local Ranking = {}
	if Races[Mode] and Races[Mode]["Routes"] and Races[Mode]["Routes"][Selected] then
		local Consult = vRP.Query("Races/Consult",{ Mode = Mode, Race = Selected, Count = Count })

		for _,v in pairs(Consult) do
			Ranking[#Ranking + 1] = {
				["Time"] = (v["Points"] / 1000),
				["Name"] = vRP.FullName(v["Passport"]),
				["Vehicle"] = VehicleName(v["Vehicle"])
			}
		end
	end

	return Ranking
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Active[Passport] then
		local Mode = Active[Passport]["Mode"]
		local Selected = Active[Passport]["Selected"]

		if Players[Mode][Selected][Passport] then
			Players[Mode][Selected][Passport] = nil

			if Paymented[Mode][Selected] >= 1 then
				Paymented[Mode][Selected] = Paymented[Mode][Selected] - 1

				if Paymented[Mode][Selected] <= 0 then
					Paymented[Mode][Selected] = 0

					if Races[Mode] and Races[Mode]["Global"] and GlobalState[Mode..":"..Selected] then
						GlobalState[Mode..":"..Selected] = false
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
for Number = 1,#Objects do
	GlobalState["Farmer:"..Number] = 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MINERMAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farmer:Minerman")
AddEventHandler("farmer:Minerman",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		if not Number or type(Number) ~= "number" then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Farmer\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		if GlobalState["Farmer:"..Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
			local Item = "pickaxe"
			local Pickaxe = vRP.ConsultItem(Passport,Item)
			local PickaxePlus = vRP.ConsultItem(Passport,Item.."plus")

			if not Pickaxe and not PickaxePlus then
				TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>1x "..ItemName(Item).."</b>.","amarelo",5000)
			else
				Player(source)["state"]["Cancel"] = true
				Player(source)["state"]["Buttons"] = true
				vRPC.CreateObjects(source,"melee@large_wpn@streamed_core","ground_attack_on_spot","prop_tool_pickaxe",1,18905,0.10,-0.1,0.0,-92.0,260.0,5.0)

				if vRP.Task(source,Pickaxe and 10 or 5,10000) and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					GlobalState["Farmer:"..Number] = GlobalState["Work"] + 60

					local Result = {
						{ ["Item"] = "tin_pure", ["Chance"] = 125, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "lead_pure", ["Chance"] = 125, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "copper_pure", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "iron_pure", ["Chance"] = 75, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "gold_pure", ["Chance"] = 75, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "diamond_pure", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1 },
						{ ["Item"] = "ruby_pure", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1 }
					}

					if PickaxePlus then
						Result = {
							{ ["Item"] = "tin_pure", ["Chance"] = 125, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "lead_pure", ["Chance"] = 125, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "copper_pure", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "iron_pure", ["Chance"] = 75, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "gold_pure", ["Chance"] = 75, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "diamond_pure", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "ruby_pure", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "sapphire_pure", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "emerald_pure", ["Chance"] = 10, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "chalcopyrite", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1 },
							{ ["Item"] = "bauxite", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1 }
						}
					end

					local Consult = RandPercentage(Result)
					if exports["party"]:DoesExist(Passport,2) then
						Consult["Valuation"] = Consult["Valuation"] + (Consult["Valuation"] * 0.5)
					end

					if exports["inventory"]:Buffs("Luck",Passport) then
						Consult["Valuation"] = Consult["Valuation"] + (Consult["Valuation"] * 0.5)
					end

					if vRP.UserPremium(Passport) then
						Consult["Valuation"] = Consult["Valuation"] + (Consult["Valuation"] * 0.5)
					end

					if vRP.CheckWeight(Passport,Consult["Item"],Consult["Valuation"]) then
						vRP.GenerateItem(Passport,Consult["Item"],Consult["Valuation"],true)
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
						exports["inventory"]:Drops(Passport,source,Consult["Item"],Consult["Valuation"])
					end

					vRP.RolepassPoints(Passport,2,true)
					vRP.UpgradeStress(Passport,1)
				end

				Player(source)["state"]["Buttons"] = false
				Player(source)["state"]["Cancel"] = false
				vRPC.Destroy(source)
			end
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LUMBERMAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farmer:Lumberman")
AddEventHandler("farmer:Lumberman",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		if not Number or type(Number) ~= "number" then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Farmer\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		if GlobalState["Farmer:"..Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
			local Item = "axe"
			local Axe = vRP.ConsultItem(Passport,Item)
			local AxePlus = vRP.ConsultItem(Passport,Item.."plus")

			if not Axe and not AxePlus then
				TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>1x "..ItemName(Item).."</b>.","amarelo",5000)
			else
				Player(source)["state"]["Cancel"] = true
				Player(source)["state"]["Buttons"] = true
				vRPC.playAnim(source,false,{"lumberjackaxe@idle","idle"},true)

				if vRP.Task(source,Axe and 10 or 5,10000) and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					GlobalState["Farmer:"..Number] = GlobalState["Work"] + 30

					local Valuation = 3
					if exports["party"]:DoesExist(Passport,2) then
						Valuation = Valuation + (Valuation * 0.25)
					end

					if exports["inventory"]:Buffs("Luck",Passport) then
						Valuation = Valuation + (Valuation * 0.25)
					end

					if vRP.UserPremium(Passport) then
						Valuation = Valuation + (Valuation * 0.25)
					end

					if vRP.CheckWeight(Passport,"woodlog",Valuation) then
						vRP.GenerateItem(Passport,"woodlog",Valuation,true)
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
						exports["inventory"]:Drops(Passport,source,"woodlog",Valuation)
					end

					vRP.RolepassPoints(Passport,2,true)
					vRP.UpgradeStress(Passport,1)
				end

				TriggerClientEvent("inventory:Provisory",source,false)
				Player(source)["state"]["Buttons"] = false
				Player(source)["state"]["Cancel"] = false
				vRPC.Destroy(source)
			end
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSPORTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farmer:Transporter")
AddEventHandler("farmer:Transporter",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		if not Number or type(Number) ~= "number" then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Farmer\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		if GlobalState["Farmer:"..Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
			Player(source)["state"]["Cancel"] = true
			Player(source)["state"]["Buttons"] = true
			TriggerClientEvent("Progress",source,"Coletando",1000)
			vRPC.playAnim(source,false,{"pickup_object","pickup_low"},true)

			SetTimeout(1000,function()
				if GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					GlobalState["Farmer:"..Number] = GlobalState["Work"] + 18

					local Valuation = 1
					if exports["inventory"]:Buffs("Luck",Passport) then
						Valuation = Valuation + 1
					end

					if vRP.CheckWeight(Passport,"pouch",Valuation) then
						vRP.GenerateItem(Passport,"pouch",Valuation,true)
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
						exports["inventory"]:Drops(Passport,source,"pouch",Valuation)
					end

					vRP.RolepassPoints(Passport,3,true)
					vRP.UpgradeStress(Passport,1)
				end

				vRPC.Destroy(source)
			end)

			Player(source)["state"]["Buttons"] = false
			Player(source)["state"]["Cancel"] = false
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SANDMAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farmer:Sandman")
AddEventHandler("farmer:Sandman",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		if not Number or type(Number) ~= "number" then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Farmer\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		if GlobalState["Farmer:"..Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
			Player(source)["state"]["Cancel"] = true
			Player(source)["state"]["Buttons"] = true
			TriggerClientEvent("Progress",source,"Coletando",1000)
			vRPC.playAnim(source,false,{"pickup_object","pickup_low"},true)

			SetTimeout(1000,function()
				if GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					GlobalState["Farmer:"..Number] = GlobalState["Work"] + 30

					local Valuation = 1
					if exports["inventory"]:Buffs("Luck",Passport) then
						Valuation = Valuation + 1
					end

					if vRP.CheckWeight(Passport,"sand",Valuation) then
						vRP.GenerateItem(Passport,"sand",Valuation,true)
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
						exports["inventory"]:Drops(Passport,source,"sand",Valuation)
					end

					vRP.RolepassPoints(Passport,5,true)
					vRP.UpgradeStress(Passport,1)
				end

				vRPC.Destroy(source)
			end)

			Player(source)["state"]["Buttons"] = false
			Player(source)["state"]["Cancel"] = false
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRASHER
-----------------------------------------------------------------------------------------------------------------------------------------
local Trasher = {
	{ ["Item"] = "plastic", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10, ["Addition"] = 0.075 },
	{ ["Item"] = "glass", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10, ["Addition"] = 0.075 },
	{ ["Item"] = "rubber", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10, ["Addition"] = 0.075 },
	{ ["Item"] = "aluminum", ["Chance"] = 50, ["Min"] = 4, ["Max"] = 8, ["Addition"] = 0.025 },
	{ ["Item"] = "copper", ["Chance"] = 50, ["Min"] = 4, ["Max"] = 8, ["Addition"] = 0.025 },
	{ ["Item"] = "techtrash", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "tarp", ["Chance"] = 7, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "sheetmetal", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "roadsigns", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "scotchtape", ["Chance"] = 3, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "insulatingtape", ["Chance"] = 3, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "electroniccomponents", ["Chance"] = 3, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "batteryaa", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "batteryaaplus", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2, ["Addition"] = 0.0 },
	{ ["Item"] = "emptybottle", ["Chance"] = 25, ["Min"] = 3, ["Max"] = 4, ["Addition"] = 0.0 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRASHER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farmer:Trasher")
AddEventHandler("farmer:Trasher",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = true

		if not Number or type(Number) ~= "number" then
			exports["discord"]:Embed("Hackers","**[PASSAPORTE]:** "..Passport.."\n**[FUNÇÃO]:** Payment do Farmer\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end

		if not vRPC.LastVehicle(source,"trash") then
			TriggerClientEvent("Notify",source,"Atenção","Necessário a utilização do veículo <b>Trash</b>.","amarelo",5000)
			Active[Passport] = nil

			return false
		end

		if GlobalState["Farmer:"..Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
			Player(source)["state"]["Cancel"] = true
			Player(source)["state"]["Buttons"] = true
			TriggerClientEvent("Progress",source,"Coletando",1000)
			vRPC.playAnim(source,false,{"pickup_object","pickup_low"},true)

			SetTimeout(1000,function()
				if GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					GlobalState["Farmer:"..Number] = GlobalState["Work"] + 180

					local GainExperience = 1
					local Result = RandPercentage(Trasher)
					local Experience,Level = vRP.GetExperience(Passport,"Garbageman")
					local Valuation = Result["Valuation"] + Result["Valuation"] * (Result["Addition"] * Level)

					if exports["inventory"]:Buffs("Luck",Passport) then
						Valuation = Valuation + (Valuation * 0.1)
					end

					if vRP.UserPremium(Passport) then
						local Hierarchy = vRP.LevelPremium(source)
						local Bonification = (Hierarchy == 1 and 0.100) or (Hierarchy == 2 and 0.075) or (Hierarchy >= 3 and 0.050)

						Valuation = Valuation + (Valuation * Bonification)
						GainExperience = GainExperience + 1
					end

					if vRPC.PolyNorth(source) then
						Valuation = Valuation + (Valuation * 0.5)
						TriggerClientEvent("Notify",source,"Atenção","Você ganhou um <b>bônus</b> por trabalhar no norte.","amarelo",5000)
					end

					if exports["party"]:DoesExist(Passport,2) then
						local Consult = exports["party"]:Room(Passport,source,10)
						local AmountMembers = (CountTable(Consult) > 2 and 2 or CountTable(Consult))

						for Number = 1,AmountMembers do
							if vRP.Passport(Consult[Number]["Source"]) and vRPC.LastVehicle(Consult[Number]["Source"],"trash") then
								Valuation = (Consult[Number]["Passport"] == Passport and Valuation or (Valuation / 2))

								if not vRP.MaxItens(Consult[Number]["Passport"],Result["Item"],Valuation) and vRP.CheckWeight(Consult[Number]["Passport"],Result["Item"],Valuation) then
									vRP.GenerateItem(Consult[Number]["Passport"],Result["Item"],Valuation,true)
								else
									TriggerClientEvent("Notify",Consult[Number]["Source"],"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
									exports["inventory"]:Drops(Consult[Number]["Passport"],Consult[Number]["Source"],Result["Item"],Valuation)
								end

								vRP.PutExperience(Consult[Number]["Passport"],"Garbageman",GainExperience)
								vRP.RolepassPoints(Consult[Number]["Passport"],GainExperience,true)
								vRP.UpgradeStress(Consult[Number]["Passport"],1)
							end
						end
					else
						if not vRP.MaxItens(Passport,Result["Item"],Result["Valuation"]) and vRP.CheckWeight(Passport,Result["Item"],Result["Valuation"]) then
							vRP.GenerateItem(Passport,Result["Item"],Valuation,true)
						else
							TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
							exports["inventory"]:Drops(Passport,source,Result["Item"],Valuation)
						end

						vRP.PutExperience(Passport,"Garbageman",GainExperience)
						vRP.RolepassPoints(Passport,GainExperience,true)
						vRP.UpgradeStress(Passport,1)
					end
				end

				vRPC.Destroy(source)
			end)

			Player(source)["state"]["Buttons"] = false
			Player(source)["state"]["Cancel"] = false
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Active[Passport] then
		Active[Passport] = nil
	end
end)
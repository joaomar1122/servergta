-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("routes",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Players = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Permission(Service)
	local source = source
	local Passport = vRP.Passport(source)

	return Passport and Config[Service] and (not Config[Service]["Permission"] or (Config[Service]["Permission"] and vRP.HasService(Passport,Config[Service]["Permission"]))) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- START
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Start(Table,Service)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Players[Passport] then
		Players[Passport] = {
			["Service"] = Service, ["Mode"] = Config[Service]["Mode"], ["Price"] = 0, ["List"] = {}
		}

		for _,Number in pairs(Table) do
			local Inner = #Players[Passport]["List"] + 1

			Players[Passport]["List"][Inner] = Config[Service]["List"][Number]
			Players[Passport]["Price"] = Players[Passport]["Price"] + Config[Service]["List"][Number]["Price"]
		end

		if Players[Passport]["Mode"] == "Never" or Players[Passport]["Mode"] == "Always" or (Players[Passport]["Mode"] == "Init" and vRP.PaymentFull(Passport,Players[Passport]["Price"])) then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISH
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Finish()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Players[Passport] then
		Players[Passport] = nil

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELIVER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Deliver()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Players[Passport] and (Players[Passport]["Mode"] == "Never" or Players[Passport]["Mode"] == "Init" or (Players[Passport]["Mode"] == "Always" and vRP.PaymentFull(Passport,Players[Passport]["Price"]))) then
		local Service = Players[Passport]["Service"]
		local Result = RandPercentage(Players[Passport]["List"])
		if not vRP.MaxItens(Passport,Result["Item"],Result["Valuation"]) and vRP.CheckWeight(Passport,Result["Item"],Result["Valuation"]) then
			vRP.GenerateItem(Passport,Result["Item"],Result["Valuation"],true)
		else
			TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","roxo",5000)
			exports["inventory"]:Drops(Passport,source,Result["Item"],Result["Valuation"])
		end

		if Config[Service]["Experience"] then
			vRP.PutExperience(Passport,Config[Service]["Experience"]["Name"],Config[Service]["Experience"]["Amount"])
		end

		if Config[Service]["Battlepass"] then
			vRP.RolepassPoints(Passport,Config[Service]["Battlepass"],true)
		end

		if Config[Service]["Wanted"] then
			TriggerEvent("Wanted",source,Passport,Config[Service]["Wanted"])
		end

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Players[Passport] then
		Players[Passport] = nil
	end
end)
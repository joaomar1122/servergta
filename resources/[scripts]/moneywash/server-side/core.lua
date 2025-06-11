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
Tunnel.bindInterface("moneywash",Creative)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local MoneyWash = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINITSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Consult = vRP.Query("entitydata/GetData",{ Name = "MoneyWash" })
	if Consult[1] then
		MoneyWash = json.decode(Consult[1]["Information"])
	end

	while true do
		Wait(60000)

		for Selected,_ in pairs(MoneyWash) do
			if MoneyWash[Selected] and MoneyWash[Selected]["Money"] and MoneyWash[Selected]["Washed"] and MoneyWash[Selected]["Value"] and MoneyWash[Selected]["Launded"] and MoneyWash[Selected]["Timer"] and MoneyWash[Selected]["Timer"] >= os.time() and MoneyWash[Selected]["Money"] >= MoneyWash[Selected]["Value"] then
				MoneyWash[Selected]["Money"] = MoneyWash[Selected]["Money"] - MoneyWash[Selected]["Value"]
				MoneyWash[Selected]["Washed"] = MoneyWash[Selected]["Washed"] + MoneyWash[Selected]["Launded"]
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WASH
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wash",function(Passport,Item,Hash,Coords,Route,Value,Launded)
	repeat
		Selected = GenerateString("DDLLDDLL")
	until Selected and not MoneyWash[Selected]

	MoneyWash[Selected] = {
		["Money"] = 0,
		["Washed"] = 0,
		["Hash"] = Hash,
		["Route"] = Route,
		["Value"] = Value,
		["Coords"] = Coords,
		["Launded"] = Launded,
		["Timer"] = os.time(),
		["Passport"] = Passport,
		["Item"] = Item
	}

	TriggerClientEvent("moneywash:New",-1,Selected,MoneyWash[Selected])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFORMATION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Information(Selected)
	return MoneyWash[Selected] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OSTIME
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.OsTime()
	return os.time()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:WASHED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Washed")
AddEventHandler("moneywash:Washed",function(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and MoneyWash[Selected] and MoneyWash[Selected]["Money"] and MoneyWash[Selected]["Washed"] then
		Active[Passport] = true

		if MoneyWash[Selected]["Washed"] > 0 then
			vRP.GenerateItem(Passport,"dollar",MoneyWash[Selected]["Washed"],true)
			TriggerClientEvent("dynamic:Close",source)
			MoneyWash[Selected]["Washed"] = 0
		end

		Active[Passport] = nil
	else
		TriggerClientEvent("Notify",source,"Sucesso","Nenhum dinheiro encontrado.","verde",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:MONEY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Money")
AddEventHandler("moneywash:Money",function(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and MoneyWash[Selected] and MoneyWash[Selected]["Money"] and MoneyWash[Selected]["Washed"] then
		Active[Passport] = true

		if MoneyWash[Selected]["Money"] > 0 then
			vRP.GenerateItem(Passport,"dirtydollar",MoneyWash[Selected]["Money"],true)
			TriggerClientEvent("dynamic:Close",source)
			MoneyWash[Selected]["Money"] = 0
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:ADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Add")
AddEventHandler("moneywash:Add",function(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and MoneyWash[Selected] and MoneyWash[Selected]["Money"] then
		TriggerClientEvent("dynamic:Close",source)
		Active[Passport] = true

		local Keyboard = vKEYBOARD.Primary(source,"Valor")
		if Keyboard and Keyboard[1] and parseInt(Keyboard[1]) > 0 and vRP.TakeItem(Passport,"dirtydollar",Keyboard[1]) then
			TriggerClientEvent("Notify",source,"Sucesso","Dinheiro adicionado.","verde",5000)
			MoneyWash[Selected]["Money"] = MoneyWash[Selected]["Money"] + Keyboard[1]
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:BATTERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Battery")
AddEventHandler("moneywash:Battery",function(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and MoneyWash[Selected] and MoneyWash[Selected]["Timer"] and MoneyWash[Selected]["Timer"] <= os.time() then
		Active[Passport] = true
		Player(source)["state"]["Cancel"] = true
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("dynamic:Close",source)
		TriggerClientEvent("Progress",source,"Coletando",10000)
		vRPC.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

		SetTimeout(10000,function()
			if vRP.TakeItem(Passport,"washbattery") then
				MoneyWash[Selected]["Timer"] = os.time() + 604800
				TriggerClientEvent("Notify",source,"Sucesso","Bateria trocada.","verde",5000)
			else
				TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>1x "..ItemName("washbattery").."</b>.","amarelo",5000)
			end

			Player(source)["state"]["Buttons"] = false
			Player(source)["state"]["Cancel"] = false
			Active[Passport] = nil
			vRPC.Destroy(source)
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:STOREOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:StoreObjects")
AddEventHandler("moneywash:StoreObjects",function(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and MoneyWash[Selected] and MoneyWash[Selected]["Item"] and MoneyWash[Selected]["Passport"] and (vRP.HasGroup(Passport,"Admin") or MoneyWash[Selected]["Passport"] == Passport) and MoneyWash[Selected]["Money"] and MoneyWash[Selected]["Money"] <= 0 and MoneyWash[Selected]["Washed"] and MoneyWash[Selected]["Washed"] <= 0 and vRP.CheckWeight(Passport,"moneywash") and vRP.GiveItem(Passport,MoneyWash[Selected]["Item"],1,true) then
		TriggerClientEvent("moneywash:Remove",-1,Selected)
		MoneyWash[Selected] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	TriggerClientEvent("moneywash:Table",source,MoneyWash)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Active[Passport] then
		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaveServer",function(Silenced)
	vRP.Query("entitydata/SetData",{ Name = "MoneyWash", Information = json.encode(MoneyWash) })

	if not Silenced then
		print("O resource ^2MoneyWash^7 salvou os dados.")
	end
end)
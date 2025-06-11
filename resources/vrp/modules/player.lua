-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Spawns = {}
local Objects = {}
local Weapons = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("CharacterChosen",function(Passport,source,Creation)
	local Identity = vRP.Identity(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and Identity then
		if Creation then
			vRPC.NewLoadSceneStartSphere(source,CreatorCoords["xyz"])

			for _,v in pairs(SpawnCoords) do
				vRPC.NewLoadSceneStartSphere(source,v)
			end
		end

		if Datatable["Pos"] then
			if not Datatable["Pos"]["x"] or not Datatable["Pos"]["y"] or not Datatable["Pos"]["z"] then
				Datatable["Pos"] = CreatorCoords["xyz"]
			end
		else
			Datatable["Pos"] = CreatorCoords["xyz"]
		end

		if not Datatable["Inventory"] then
			Datatable["Inventory"] = {}
		end

		if not Datatable["Health"] then
			Datatable["Health"] = 200
		end

		if not Datatable["Armour"] then
			Datatable["Armour"] = 0
		end

		if not Datatable["Stress"] then
			Datatable["Stress"] = 0
		end

		if not Datatable["Hunger"] then
			Datatable["Hunger"] = 100
		end

		if not Datatable["Thirst"] then
			Datatable["Thirst"] = 100
		end

		if not Datatable["Weight"] then
			Datatable["Weight"] = MinimumWeight
		end

		vRPC.Skin(source,Identity["Skin"])
		vRP.SetArmour(source,Datatable["Armour"])
		vRPC.SetHealth(source,Datatable["Health"])
		vRP.Teleport(source,Datatable["Pos"]["x"],Datatable["Pos"]["y"],Datatable["Pos"]["z"])

		TriggerClientEvent("hud:Thirst",source,Datatable["Thirst"])
		TriggerClientEvent("hud:Hunger",source,Datatable["Hunger"])
		TriggerClientEvent("hud:Stress",source,Datatable["Stress"])

		if Creation then
			TriggerClientEvent("barbershop:Apply",source,vRP.UserData(Passport,"Barbershop"))
			TriggerClientEvent("tattooshop:Apply",source,vRP.UserData(Passport,"Tattooshop"))
			TriggerClientEvent("skinshop:Apply",source,vRP.UserData(Passport,"Clothings"),true)
			TriggerClientEvent("spawn:Finish",source,nil,CreatorCoords["w"])
		else
			if Spawns[Passport] then
				exports["vrp"]:Bucket(source,"Exit")
				TriggerClientEvent("spawn:Finish",source)
			else
				TriggerClientEvent("spawn:Finish",source,Datatable["Pos"])
			end
		end

		TriggerClientEvent("vRP:Active",source,Passport,Identity["Name"].." "..Identity["Lastname"],Datatable["Inventory"])
		TriggerEvent("Connect",Passport,source,Spawns[Passport] == nil)
		GlobalState["Players"] = GetNumPlayerIndices()

		if not Spawns[Passport] then
			Spawns[Passport] = true
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("DeleteObject")
AddEventHandler("DeleteObject",function(Index,Weapon)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if Objects[Passport] and Objects[Passport][Index] then
			Objects[Passport][Index] = nil
		end

		if Weapon and Weapons[Passport] and Weapons[Passport][Weapon] then
			Index = Weapons[Passport][Weapon]
			Weapons[Passport][Weapon] = nil
		end
	end

	TriggerEvent("DeleteObjectServer",Index)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEOBJECTSERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("DeleteObjectServer",function(Index)
	local Networked = NetworkGetEntityFromNetworkId(Index)
	if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 3 then
		DeleteEntity(Networked)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEPED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("DeletePed")
AddEventHandler("DeletePed",function(Index)
	local Networked = NetworkGetEntityFromNetworkId(Index)
	if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 1 then
		DeleteEntity(Networked)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEBUGOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("DebugObjects",function(Passport,Ignore)
	if Objects[Passport] then
		if not Ignore then
			for Index,_ in pairs(Objects[Passport]) do
				TriggerEvent("DeleteObjectServer",Index)
			end
		end

		Objects[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEBUGWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("DebugWeapons",function(Passport,source,Ignore)
	if Weapons[Passport] then
		for Name,Network in pairs(Weapons[Passport]) do
			TriggerEvent("DeleteObjectServer",Network)

			if not Ignore then
				TriggerClientEvent("inventory:RemoveWeapon",source,Name)
			end
		end

		Weapons[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ClearInventory(Passport,Ignore)
	local source = vRP.Source(Passport)

	TriggerEvent("DebugObjects",Passport)
	exports["inventory"]:CleanWeapons(Passport)
	TriggerEvent("DebugWeapons",Passport,source)

	for Slot,v in pairs(vRP.Inventory(Passport)) do
		if not BlockDelete(v["item"]) then
			vRP.RemoveItem(Passport,v["item"],v["amount"])
		end
	end

	if not Ignore then
		if vRP.UserPremium(Passport) then
			vRP.UpgradeWeight(Passport,25,"-")
		else
			vRP.UpgradeWeight(Passport,50,"-")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDAGRADETHIRST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeThirst(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Thirst"] then
			Datatable["Thirst"] = 0
		end

		Datatable["Thirst"] = Datatable["Thirst"] + parseInt(Amount)

		if Datatable["Thirst"] > 100 then
			Datatable["Thirst"] = 100
		end

		TriggerClientEvent("hud:Thirst",source,Datatable["Thirst"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEHUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeHunger(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Hunger"] then
			Datatable["Hunger"] = 0
		end

		Datatable["Hunger"] = Datatable["Hunger"] + parseInt(Amount)

		if Datatable["Hunger"] > 100 then
			Datatable["Hunger"] = 100
		end

		TriggerClientEvent("hud:Hunger",source,Datatable["Hunger"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADESTRESS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeStress(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Stress"] then
			Datatable["Stress"] = 0
		end

		Datatable["Stress"] = Datatable["Stress"] + parseInt(Amount)

		if Datatable["Stress"] > 100 then
			Datatable["Stress"] = 100
		end

		TriggerClientEvent("hud:Stress",source,Datatable["Stress"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOWNGRADETHIRST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DowngradeThirst(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Thirst"] then
			Datatable["Thirst"] = 100
		end

		Datatable["Thirst"] = Datatable["Thirst"] - parseInt(Amount)

		if Datatable["Thirst"] < 0 then
			Datatable["Thirst"] = 0
		end

		TriggerClientEvent("hud:Thirst",source,Datatable["Thirst"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOWNGRADETHIRST
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.DowngradeThirst()
	local source = source
	local Passport = vRP.Passport(source)
	local Datatable = vRP.Datatable(Passport)
	if Passport and Datatable and Characters[source] then
		if not Datatable["Thirst"] then
			Datatable["Thirst"] = 100
		end

		Datatable["Thirst"] = Datatable["Thirst"] - 1

		if Datatable["Thirst"] < 0 then
			Datatable["Thirst"] = 0
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOWNGRADEHUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DowngradeHunger(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Hunger"] then
			Datatable["Hunger"] = 100
		end

		Datatable["Hunger"] = Datatable["Hunger"] - parseInt(Amount)

		if Datatable["Hunger"] < 0 then
			Datatable["Hunger"] = 0
		end

		TriggerClientEvent("hud:Hunger",source,Datatable["Hunger"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOWNGRADEHUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.DowngradeHunger()
	local source = source
	local Passport = vRP.Passport(source)
	local Datatable = vRP.Datatable(Passport)
	if Passport and Datatable and Characters[source] then
		if not Datatable["Hunger"] then
			Datatable["Hunger"] = 100
		end

		Datatable["Hunger"] = Datatable["Hunger"] - 1

		if Datatable["Hunger"] < 0 then
			Datatable["Hunger"] = 0
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOWNGRADESTRESS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DowngradeStress(Passport,Amount)
	local source = vRP.Source(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and source then
		if not Datatable["Stress"] then
			Datatable["Stress"] = 0
		end

		Datatable["Stress"] = Datatable["Stress"] - parseInt(Amount)

		if Datatable["Stress"] < 0 then
			Datatable["Stress"] = 0
		end

		TriggerClientEvent("hud:Stress",source,Datatable["Stress"])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetHealth(source)
	local Ped = GetPlayerPed(source)

	return DoesEntityExist(Ped) and Characters[source] and GetEntityHealth(Ped) or 100
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MODELPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ModelPlayer(source)
	local Ped = GetPlayerPed(source)
	if DoesEntityExist(Ped) and GetEntityModel(Ped) == GetHashKey("mp_f_freemode_01") and Characters[source] then
		return "mp_f_freemode_01"
	end

	return "mp_m_freemode_01"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetExperience(Passport,Work)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and not Datatable[Work] then
		Datatable[Work] = 0
	end

	return Datatable[Work] or 0,ClassCategory(Datatable[Work] or 0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PUTEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PutExperience(Passport,Work,Number)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		if not Datatable[Work] then
			Datatable[Work] = 0
		end

		Datatable[Work] = Datatable[Work] + Number
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETARMOUR
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SetArmour(source,Amount)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			local Armour = GetPedArmour(Ped)

			if (Armour + Amount) > 100 then
				Amount = 100 - Armour
			end

			SetPedArmour(Ped,Armour + Amount)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TELEPORT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Teleport(source,x,y,z)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			SetEntityCoords(Ped,x + 0.0001,y + 0.0001,z + 0.0001)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCREATION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SpawnCreation(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			SetEntityCoords(Ped,SpawnCoords[math.random(#SpawnCoords)])
			exports["vrp"]:Bucket(source,"Exit")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEADING
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Heading(source,Heading)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			SetEntityHeading(Ped,Heading)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETENTITYCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetEntityCoords(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			return GetEntityCoords(Ped)
		end
	end

	return vec3(0,0,0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSIDEVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InsideVehicle(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) and GetVehiclePedIsIn(Ped) ~= 0 then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSIDEVEHICLEPASSAGER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InsideVehiclePassager(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) and GetVehiclePedIsIn(Ped) ~= 0 and GetPedInVehicleSeat(GetVehiclePedIsIn(Ped),0) == Ped then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOESENTITYEXIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DoesEntityExist(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISENTITYVISIBLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.IsEntityVisible(source)
	if source and Characters[source] then
		local Ped = GetPlayerPed(source)
		if DoesEntityExist(Ped) and not IsEntityVisible(Ped) then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEMODELS
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.CreateModels(Model,x,y,z)
	local Looping = 0
	local Hash = GetHashKey(Model)
	local Looping = GetGameTimer() + 5000
	local Ped = CreatePed(4,Hash,x,y,z,true,true)

	while not DoesEntityExist(Ped) and Looping <= 1000 do
		Looping = Looping + 1
		Wait(1)
	end

	if DoesEntityExist(Ped) then
		SetEntityIgnoreRequestControlFilter(Ped,true)

		return NetworkGetNetworkIdFromEntity(Ped)
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.CreateObject(Model,x,y,z,Weapon,Component)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Model then
		local Looping = 0
		local Hash = GetHashKey(Model)
		local Object = CreateObject(Component or Hash,x,y,z - 2.0,true,true,false)

		while not DoesEntityExist(Object) and Looping <= 1000 do
			Looping = Looping + 1
			Wait(1)
		end

		if DoesEntityExist(Object) then
			SetEntityIgnoreRequestControlFilter(Object,true)

			local NetObjects = NetworkGetNetworkIdFromEntity(Object)

			if Weapon then
				if not Weapons[Passport] then
					Weapons[Passport] = {}
				end

				Weapons[Passport][Weapon] = NetObjects
			else
				if not Objects[Passport] then
					Objects[Passport] = {}
				end

				Objects[Passport][NetObjects] = true
			end

			return NetObjects
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUCKET
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Bucket",function(source,Mode,Route)
	local Mode = Mode
	local Route = Route
	local source = source

	if Mode == "Enter" then
		SetPlayerRoutingBucket(source,Route)
		Player(source)["state"]["Route"] = Route

		if Route > 0 then
			SetRoutingBucketEntityLockdownMode(Route,"strict")
			SetRoutingBucketPopulationEnabled(Route,false)
		end
	else
		SetPlayerRoutingBucket(source,0)
		Player(source)["state"]["Route"] = 0
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP:RELOADWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:ReloadWeapons",function(source)
	local source = source
	local Passport = vRP.Passport(source)
	local Inventory = vRP.Inventory(Passport)
	if Passport and Inventory then
		for Slot,v in pairs(Inventory) do
			if ItemTypeCheck(v["item"],"Armamento") and not vRP.CheckDamaged(v["item"]) then
				TriggerClientEvent("inventory:CreateWeapon",source,v["item"])
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP:WAITCHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("vRP:WaitCharacters")
AddEventHandler("vRP:WaitCharacters",function(Creation)
	local source = source
	local Passport = vRP.Passport(source)
	local Datatable = vRP.Datatable(Passport)
	if Passport and Datatable then
		if not Creation then
			exports["vrp"]:Bucket(source,"Exit")
			TriggerEvent("vRP:ReloadWeapons",source)
		end

		if Characters[source] and Characters[source]["Prison"] > 0 then
			Player(source)["state"]["Prison"] = true
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	TriggerEvent("DebugWeapons",Passport,source,true)
	TriggerEvent("DebugObjects",Passport,true)
end)
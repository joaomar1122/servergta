-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("spawn")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Camera = nil
local Opened = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATE
-----------------------------------------------------------------------------------------------------------------------------------------
local Locate = {
	{ ["Coords"] = vec3(-2205.92,-370.48,13.29), ["Name"] = "" },
	{ ["Coords"] = vec3(-2205.92,-370.48,13.29), ["Name"] = "" },
	{ ["Coords"] = vec3(-250.35,6209.71,31.49), ["Name"] = "" },
	{ ["Coords"] = vec3(1694.37,4794.66,41.92), ["Name"] = "" },
	{ ["Coords"] = vec3(1858.94,3741.78,33.09), ["Name"] = "" },
	{ ["Coords"] = vec3(328.0,2617.89,44.48), ["Name"] = "" },
	{ ["Coords"] = vec3(308.33,-232.25,54.07), ["Name"] = "" },
	{ ["Coords"] = vec3(449.71,-659.27,28.48), ["Name"] = "" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMS
-----------------------------------------------------------------------------------------------------------------------------------------
local Anims = {
	{ ["Dict"] = "rcmbarry", ["Name"] = "base" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN:OPENED
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local Pid = PlayerId()
		local Ped = PlayerPedId()
		if Ped and Ped ~= -1 and Pid and NetworkIsSessionStarted() and NetworkIsPlayerActive(Pid) and not Opened then
			Opened = true
			DoScreenFadeOut(0)
			DisplayRadar(false)

			SetEntityCoords(Ped,233.85,-1387.59,29.55,false,false,false,false)
			FreezeEntityPosition(Ped,true)
			SetEntityInvincible(Ped,true)
			SetEntityHeading(Ped,136.07)
			SetEntityHealth(Ped,100)
			SetPedArmour(Ped,0)

			Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
			RenderScriptCams(true,false,0,false,false)
			SetCamCoord(Camera,232.0,-1388.64,30.45)
			SetCamRot(Camera,0.0,0.0,320.0,2)
			SetCamActive(Camera,true)

			Characters = vSERVER.Characters()
			if CountTable(Characters) > 0 then
				Customization(Characters[1])
			else
				SetEntityVisible(Ped,false,0)
			end

			Wait(5000)

			SendNUIMessage({ Action = "Spawn", Payload = Characters })
			ShutdownLoadingScreenNui()
			ShutdownLoadingScreen()
			SetNuiFocus(true,true)

			if IsScreenFadedOut() then
				DoScreenFadeIn(2500)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CharacterChosen",function(Data,Callback)
	if vSERVER.CharacterChosen(Data["Passport"]) then
		SendNUIMessage({ Action = "Close" })
	end

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("NewCharacter",function(Data,Callback)
	Callback(vSERVER.NewCharacter(Data["name"],Data["lastname"],Data["gender"]))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SWITCHCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("SwitchCharacter",function(Data,Callback)
	for _,v in pairs(Characters) do
		if v["Passport"] == Data["Passport"] then
			Customization(v,true)

			break
		end
	end

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN:FINISH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("spawn:Finish")
AddEventHandler("spawn:Finish",function(Coords,Creation)
	if Coords then
		Locate[1] = { ["Coords"] = Coords, ["Name"] = "" }

		for Number,v in pairs(Locate) do
			local Road = GetStreetNameAtCoord(v["Coords"]["x"],v["Coords"]["y"],v["Coords"]["z"])
			Locate[Number]["Name"] = GetStreetNameFromHashKey(Road)
		end

		SetCamCoord(Camera,Locate[1]["Coords"]["x"],Locate[1]["Coords"]["y"],Locate[1]["Coords"]["z"] + 1)
		SendNUIMessage({ Action = "Location", Payload = Locate })
		SetCamRot(Camera,0.0,0.0,0.0,2)
	else
		if Creation then
			SetEntityVisible(PlayerPedId(),true,0)
			exports["barbershop"]:Creation(Creation)
		else
			TriggerEvent("hud:Active",true)
		end

		TriggerServerEvent("vRP:WaitCharacters",Creation)
		SendNUIMessage({ Action = "Close" })
		SetNuiFocus(false,false)

		if DoesCamExist(Camera) then
			RenderScriptCams(false,false,0,false,false)
			SetCamActive(Camera,false)
			DestroyCam(Camera,false)
			Camera = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Spawn",function(Data,Callback)
	if DoesCamExist(Camera) then
		RenderScriptCams(false,false,0,false,false)
		SetCamActive(Camera,false)
		DestroyCam(Camera,false)
		Camera = nil
	end

	TriggerServerEvent("vRP:WaitCharacters")
	SendNUIMessage({ Action = "Close" })
	TriggerEvent("hud:Active",true)
	SetNuiFocus(false,false)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Chosen",function(Data,Callback)
	local Ped = PlayerPedId()
	local Index = Data["index"]

	SetEntityCoords(Ped,Locate[Index]["Coords"]["x"],Locate[Index]["Coords"]["y"],Locate[Index]["Coords"]["z"] - 1)
	SetCamCoord(Camera,Locate[Index]["Coords"]["x"],Locate[Index]["Coords"]["y"],Locate[Index]["Coords"]["z"] + 1)
	SetCamRot(Camera,0.0,0.0,0.0,2)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CUSTOMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
function Customization(Table,Check)
	local Pid = PlayerId()
	local Ped = PlayerPedId()
	local Model = GetHashKey(Table["Skin"])
	if IsModelInCdimage(Model) and IsModelValid(Model) then
		RequestModel(Model)
		while not HasModelLoaded(Model) do
			RequestModel(Model)
			Wait(0)
		end

		if not Check or (Check and GetEntityModel(Ped) ~= Model) then
			SetPlayerModel(Pid,Model)
			SetModelAsNoLongerNeeded(Model)
		end
	end

	local Ped = PlayerPedId()
	local Random = math.random(#Anims)
	if LoadAnim(Anims[Random]["Dict"]) then
		TaskPlayAnim(Ped,Anims[Random]["Dict"],Anims[Random]["Name"],8.0,8.0,-1,1,1,0,0,0)
	end

	exports["skinshop"]:Apply(Table["Clothes"],Ped)
	exports["barbershop"]:Apply(Table["Barber"],Ped)
	exports["tattooshop"]:Apply(Table["Tattoos"],Ped)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWN:INCREMENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("spawn:Increment")
AddEventHandler("spawn:Increment",function(Tables)
	for _,v in pairs(Tables) do
		Locate[#Locate + 1] = { ["Coords"] = v, ["Name"] = "" }
	end
end)
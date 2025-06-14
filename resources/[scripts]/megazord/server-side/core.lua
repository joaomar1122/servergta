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
Tunnel.bindInterface("megazord",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Explosive = {}
GlobalState["Resource"] = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPLODES
-----------------------------------------------------------------------------------------------------------------------------------------
local Explodes = {
	[0] = "Grenade",
	[1] = "GrenadeLauncher",
	[2] = "StickyBomb",
	[4] = "Rocket",
	[5] = "TankShell",
	[6] = "Hi_Octane",
	[7] = "Car",
	[8] = "Plance",
	[9] = "PetrolPump",
	[10] = "Bike",
	[11] = "Dir_Steam",
	[12] = "Dir_Flame",
	[13] = "Dir_Water_Hydrant",
	[14] = "Dir_Gas_Canister",
	[15] = "Boat",
	[16] = "Ship_Destroy",
	[17] = "Truck",
	[18] = "Bullet",
	[19] = "SmokeGrenadeLauncher",
	[20] = "SmokeGrenade",
	[21] = "BZGAS",
	[22] = "Flare",
	[23] = "Gas_Canister",
	[24] = "Extinguisher",
	[25] = "Programmablear",
	[26] = "Train",
	[27] = "Barrel",
	[28] = "PROPANE",
	[29] = "Blimp",
	[30] = "Dir_Flame_Explode",
	[31] = "Tanker",
	[32] = "PlaneRocket",
	[33] = "VehicleBullet",
	[34] = "Gas_Tank",
	[35] = "FireWork",
	[36] = "RAILGUN",
	[37] = "BLIMP2",
	[38] = "FIREWORK",
	[39] = "SNOWBALL",
	[40] = "PROXMINE",
	[41] = "VALKYRIE_CANNON",
	[42] = "DEFENCE",
	[43] = "PIPEBOMB",
	[44] = "VEHICLEMINE",
	[45] = "EXPLOSIVEAMMO",
	[46] = "APCSHELL",
	[47] = "BOMB_CLUSTER",
	[48] = "BOMB_GAS",
	[49] = "BOMB_INCENDIARY",
	[50] = "BOMB_STANDARD",
	[51] = "TORPEDO",
	[52] = "TORPEDO_UNDERWATER",
	[53] = "BOMBUSHKA_CANNON",
	[54] = "BOMB_CLUSTER_SECONDARY",
	[55] = "HUNTER_BARRAGE",
	[56] = "HUNTER_CANNON",
	[57] = "ROGUE_CANNON",
	[58] = "MINE_UNDERWATER",
	[59] = "ORBITAL_CANNON",
	[60] = "BOMB_STANDARD_WIDE",
	[61] = "EXPLOSIVEAMMO_SHOTGUN",
	[62] = "OPPRESSOR2_CANNON",
	[63] = "MORTAR_KINETIC",
	[64] = "VEHICLEMINE_KINETIC",
	[65] = "VEHICLEMINE_EMP",
	[66] = "VEHICLEMINE_SPIKE",
	[67] = "VEHICLEMINE_SLICK",
	[68] = "VEHICLEMINE_TAR",
	[69] = "SCRIPT_DRONE",
	[70] = "RAYGUN",
	[71] = "BURIEDMINE",
	[72] = "SCRIPT_MISSILE",
	[73] = "RCTANK_ROCKET",
	[74] = "BOMB_WATER",
	[75] = "BOMB_WATER_SECONDARY",
	[76] = "_0xF728C4A9",
	[77] = "_0xBAEC056F",
	[78] = "FLASHGRENADE",
	[79] = "STUNGRENADE",
	[80] = "_0x763D3B3B",
	[81] = "SCRIPT_MISSILE_LARGE",
	[82] = "SUBMARINE_BIG"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WARNING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Warning(Message)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Message then
		exports["discord"]:Embed("Hackers","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[MOTIVO]:** "..Message.."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADRESOURCES
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local ResourceList = {}
	for Number = 0,(GetNumResources() - 1) do
		ResourceList[GetResourceByFindIndex(Number)] = true
	end

	GlobalState["Resource"] = ResourceList
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPLOSIONEVENT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("explosionEvent",function(source,Data)
	local source = source
	local ExplosionType = tonumber(Data["explosionType"])
	if Explodes[ExplosionType] then
		CancelEvent()

		local Passport = vRP.Passport(source)
		if Passport then
			exports["discord"]:Embed("Hackers","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[MOTIVO]:** "..Explodes[ExplosionType].."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANNEDMODELS
-----------------------------------------------------------------------------------------------------------------------------------------
local BannedModels = {
	[`jet`] = true,
	[`besra`] = true,
	[`luxor`] = true,
	[`blimp`] = true,
	[`polmav`] = true,
	[`buzzard2`] = true,
	[`mammatus`] = true,
	[`s_m_y_prismuscl_01`] = true,
	[`u_m_y_prisoner_01`] = true,
	[`s_m_y_prisoner_01`] = true,
	[`frogger`] = true
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTITYCREATING
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("entityCreating",function(Entity)
	if DoesEntityExist(Entity) then
		if BannedModels[GetEntityModel(Entity)] or NetworkGetEntityOwner(Entity) == nil then
			CancelEvent()

			return
		end

		if GetEntityType(Entity) == 2 then
			SetVehicleDoorsLocked(Entity,2)
		end
	else
		CancelEvent()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HACKEREVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
local HackerEvents = { "rpv_uber:success","xex_streetfight:pay","lester:vendita","esx:jackingcar","esx_vehicletrunk:giveDirty","esx_moneywash:deposit","Esx-MenuPessoal:Boss_recruterplayer","esx_blackmoney:washMoney","esx_ambulancejob:setDeathStatus","esx_carthief:alertcops","esx_dmvschool:addLicense","esx_skin:setPlayerInvisible","esx_bank:withdraw","esx:enterpolicecar","esx_handcuffs:cuffing","esx_jail:sendToJail","esx_jail:unjailQuest","esx_jailer:unjailTime","esx_mecanojob:onNPCJobCompleted","esx_mechanicjob:startHarvest","esx_mechanicjob:startCraft","esx-qalle-hunting:reward","esx-qalle-hunting:sell","esx_skin:responseSaveSkin","esx_society:setJob","esx_skin:responseSaDFWMveSkin","esx_dmvschool:addLiceDFWMnse","esx_mechanicjob:starDFWMtCraft","esx_drugs:startHarvestWDFWMeed","esx_drugs:startTransfoDFWMrmWeed","esx_drugs:startSellWeDFWMed","esx_drugs:startHarvestDFWMCoke","esx_drugs:startTransDFWMformCoke","esx_drugs:startSellCDFWMoke","esx_drugs:startHarDFWMvestMeth","esx_drugs:startTDFWMransformMeth","esx_drugs:startSellMDFWMeth","esx_drugs:startHDFWMarvestOpium","esx_drugs:startSellDFWMOpium","esx_drugs:starDFWMtTransformOpium","esx_blanchisDFWMseur:startWhitening","esx_drugs:stopHarvDFWMestCoke","esx_drugs:stopTranDFWMsformCoke","esx_drugs:stopSellDFWMCoke","esx_drugs:stopHarvesDFWMtMeth","esx_drugs:stopTranDFWMsformMeth","esx_drugs:stopSellMDFWMeth","esx_drugs:stopHarDFWMvestWeed","esx_drugs:stopTDFWMransformWeed","esx_drugs:stopSellWDFWMeed","esx_drugs:stopHarvestDFWMOpium","esx_drugs:stopTransDFWMformOpium","esx_drugs:stopSellOpiuDFWMm","esx_society:openBosDFWMsMenu","esx_tankerjob:DFWMpay","esx_vehicletrunk:givDFWMeDirty","esx_vehicleshop:setVehicleOwnedPlayerId","esx_drugs:pickedUpCDFWMannabis","esx_drugs:processCDFWMannabis","esx-qalle-hunting:DFWMreward","esx-qalle-hunting:seDFWMll","esx_mecanojob:onNPCJobCDFWMompleted","esx_society:putVehicleDFWMInGarage","esx:clientLog","esx:triggerServerCallback","esx:playerLoaded","esx:createMissingPickups","esx:updateLoadout","esx:updateLastPosition","esx:removeInventoryItem","esx:useItem","esx:onPickup","esx_jobs:startWork","esx_jobs:stopWork","esx_fueldDFWMelivery:pay","esx_carthDFWMief:pay","esx_godiDFWMrtyjob:pay","esx_pizza:pDFWMay","esx_ranger:pDFWMay","esx_garbageDFWMjob:pay","esx_truckDFWMerjob:pay","esx_jobs:caDFWMution","esx_carthief:alertcoDFWMps","esx:getShDFWMaredObjDFWMect","esx_society:getOnlDFWMinePlayers","esx_jailer:unjailTiDFWMme","esx_ambulancejob:reDFWMvive","esx_moneywash:depoDFWMsit","esx_moneywash:witDFWMhdraw","esx_handcuffs:cufDFWMfing","esx_policejob:haDFWMndcuff","esx-qalle-jail:jailPDFWMlayer","esx_dmvschool:pDFWMay","esx_biDFWMlling:sendBill","esx_jDFWMailer:sendToJail","esx_jaDFWMil:sendToJail","esx_goDFWMpostaljob:pay","esx_baDFWMnksecurity:pay","esx_sloDFWMtmachine:sv:2","esx:giDFWMveInventoryItem","esx_vehicleshop:setVehicleOwnedDFWM","esx_mafiajob:confiscateDFWMPlayerItem","OG_cuffs:cuffCheckNearest","CheckHandcuff","arisonarp:wiezienie","gambling:spend","265df2d8-421b-4727-b01d-b92fd6503f5e","mission:completed","truckerJob:success","c65a46c5-5485-4404-bacf-06a106900258","paycheck:salary","MF_MobileMeth:RewardPlayers","lscustoms:UpdateVeh","xk3ly-farmer:paycheck","AdminMenu:giveDirtyMoney","Tem2LPs5Para5dCyjuHm87y2catFkMpV","dqd36JWLRC72k8FDttZ5adUKwvwq9n9m","antilynxr4:detect","antilynxr6:detection","ynx8:anticheat","antilynx8r4a:anticheat","lynx8:anticheat","AntiLynxR4:kick","AntiLynxR4:log","esx_spectate:kick","Banca:withdraw","BsCuff:Cuff696999","cuffServer","cuffGranted","DFWM:adminmenuenable","DFWM:askAwake","DFWM:checkup","DFWM:cleanareaentity","DFWM:cleanareapeds","DFWM:cleanareaveh","DFWM:enable","DFWM:invalid","DFWM:log","DFWM:openmenu","DFWM:spectate","DFWM:ViolationDetected","eden_garage:payhealth","ems:revive","hentailover:xdlol","JailUpdate","js:removejailtime","LegacyFuel:PayFuel","ljail:jailplayer","mellotrainer:adminTempBan","mellotrainer:adminKick","mellotrainer:s_adminKill","NB:destituerplayer","NB:recruterplayer","paramedic:revive","police:cuffGranted","unCuffServer","uncuffGranted","whoapd:revive","lscustoms:pDFWMayGarage","vrp_slotmachDFWMine:server:2","Banca:dDFWMeposit","bank:depDFWMosit","give_back","AdminMeDFWMnu:giveBank","AdminMDFWMenu:giveCash","NB:recDFWMruterplayer","LegacyFuel:PayFuDFWMel","OG_cuffs:cuffCheckNeDFWMarest","CheckHandcDFWMuff","cuffSeDFWMrver","cuffGDFWMranted","police:cuffGDFWMranted","bank:withdDFWMraw","dmv:succeDFWMss","gambling:speDFWMnd","AdminMenu:giveDirtyMDFWMoney","mission:completDFWMed","truckerJob:succeDFWMss","99kr-burglary:addMDFWMoney","DiscordBot:plaDFWMyerDied","js:jaDFWMiluser","h:xd","adminmenu:setsalary","adminmenu:cashoutall","bank:tranDFWMsfer","paycheck:bonDFWMus","paycheck:salDFWMary","HCheat:TempDisableDetDFWMection","BsCuff:Cuff696DFWM999","veh_SR:CheckMonDFWMeyForVeh","mellotrainer:adminTeDFWMmpBan","mellotrainer:adminKickDFWM","tigoanticheat:getSharedObject","tigoanticheat:triggerServerCallback","tigoanticheat:triggerServerEvent","tigoanticheat:serverCallback","tigoanticheat:triggerClientCallback","tigoanticheat:clientCallback","tigoanticheat:getServerConfig","tigoanticheat:banPlayer","tigoanticheat:playerResourceStarted","tigoanticheat:logToConsole","tigoanticheat:stillAlive","tigoanticheat:storeSecurityToken","modmenu","esx:getSharedObject","esx_ambulancejob:revive","esx_society:openBossMenu","esx_status:set","esx_policejob:handcuff","esx_handcuffs:cuffClosestPlayer","LegacyFuel:RefundFuel","esx_jailer:wysylandoo","esx_godirtyjob:pay","esx_pizza:pay","esx_slotmachine:sv:2","esx_banksecurity:pay","esx_truckerjob:pay","esx_carthief:pay","esx_garbagejob:pay","esx_ranger:pay","esx_truckersjob:payy","esx_blanchisseur:washMoney","esx_moneywash:withdraw","esx_blanchisseur:startWhitening","esx_billing:sendBill","esx_dmvschool:pay","esx_jailer:sendToJail","esx_jailler:sendToJail","esx-qalle-jail:jailPlayer","esx-qalle-jail:jailPlayerNew","esx_jailer:sendToJailCatfrajerze","esx_policejob:billPlayer","esx_skin:openRestrictedMenu","esx_inventoryhud:openPlayerInventory","bank:transfer","advancedFuel:setEssence","display","tost:zgarnijsiano","Sasaki_kurier:pay","wojtek_ubereats:napiwek","wojtek_ubereats:hajs","xk3ly-barbasz:getfukingmony","xk3ly-farmer:paycheck","tostzdrapka:wygranko","laundry:washcash","projektsantos:mandathajs","program-keycard:hacking","6a7af019-2b92-4ec2-9435-8fb9bd031c26","211ef2f8-f09c-4582-91d8-087ca2130157","neweden_garage:pay","8321hiue89js","js:jailuser","wyspa_jail:jailPlayer","wyspa_jail:jail","ambulancier:selfRespawn","UnJP","esx-qalle-jail:openJailMenu","esx:spawnVehicle","HCheat:TempDisableDetection","bank:deposit","bank:withdraw","cacador-vender","esx:giveInventoryItem","esx_jobs:caution","esx_fueldelivery:pay","esx_society:getOnlinePlayers","esx_vehicleshop:setVehicleOwned","gcPhone:tchatchannel","gcPhone:internalAddMessage","AdminMenu:giveBank","AdminMenu:giveCash","vrp_slotmachine:server:2","Banca:deposit","lscustoms:payGarage","LegacyFuel:PayFuel","blarglebus:finishRoute","dmv:success","departamento-vender","reanimar:pagamento","adminmenu:allowall","d0pamine_xyz:getFuckedNigger","chat:server:ServerPSA","antilynx8:anticheat","DiscordBot:playerDie","esx_fueldeliver","PayForRepairNow","esx_jobs:caution","bank:transfer","lscustoms:payGarag","esx_vangelico_robbery:gioielli1","99kr-burglary:addMoney","esx_truckerJob2:payout","es_truckerJob:pay","burglary:money","lenzh_chopshop:sell","esx_deliveries:AddCashMoney","loffe_prisonwork","esx_tankerjob:pay","esx_society:sendMoney","esx_drugs:sellAll","esx_drugs:sellCocaine","esx_drugs:sellCoke","esx_drugs:sellWeed","esx_drugs:sellMeth","esx_drugs:sellOpium","esx_mechanicjob:repairCurrentVehicle","napadtransport:graczZrobilnapad","tost:zgarnijsiano","esx_loffe_fangelse:Pay","esx_mugging:giveMoney","esx_robnpc:giveMoney","esx_vehicletrunk:giveDirty","esx_gopostaljob:pay","f0ba1292-b68d-4d95-8823-6230cdf282b6",":tunnel_req","gambling:spend","265df2d8-421b-4727-b01d-b92fd6503f5e","AdminMenu:giveDirtyMoney","esx_moneywash:deposit","esx_moneywash:withdraw","esx_moneywash:deposit","mission:completed","truckerJob:success","esx_moneywash:getMoney","AdminMenu:addMoney","esx_fishing:receiveFish","c65a46c5-5485-4404-bacf-06a106900258","dropOff","truckerfuel:success","delivery:success","esx_brinksjob:pay","esx_postejob:pay","esx_garbage:pay","esx_carteirojob:pay","esx_pilot:success","esx_taxijob:success","adminmenu:setsalary","esx_mugging:giveMoney","paycheck:salary","vrp_slotmachine:server:2","DiscordBot:playerDied","esx_drugs:startHarvestWeed","esx_drugs:startTransformWeed","esx_drugs:startSellWeed","esx_drugs:startHarvestCoke","esx_drugs:startTransformCoke","esx_drugs:startSellCoke","esx_drugs:startHarvestMeth","esx_drugs:startTransformMeth","esx_drugs:startSellMeth","esx_drugs:startHarvestOpium","esx_drugs:startTransformOpium","esx_drugs:startSellOpium","esx_drugs:stopTransformCoke","esx_handcuffs:unlocking","esx_policejob:requestarrest","esx_policejob:handcuffPasta","17A34C820A685513C5B4ADDD85968B9E905CC300A261EB55D299ABCB6C90AAA872712B3B6C13DC41913FCC2BE84A07EF9300DC4E89669A4B0E6FBB344A69D239","llotrainer:adminKick","esx_mafiajob:confiscatePlayerItem","InteractSound_SV:PlayOnAll","SEM_InteractionMenu:Jail","SEM_InteractionMenu:DragNear" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- HACKEREVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
for Number = 1,#HackerEvents do
	RegisterServerEvent(HackerEvents[Number])
	AddEventHandler(HackerEvents[Number],function()
		local Passport = vRP.Passport(source)
		if Passport then
			exports["discord"]:Embed("Hackers","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[MOTIVO]:** Hacker Events\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARTICLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Particles = {
	GetHashKey("scr_firework_xmas_burst_rgw"),
	GetHashKey("exp_grd_petrol_pump"),
	GetHashKey("scr_clown_bul"),
	GetHashKey("scr_mich4_firework_trailburst_spawn"),
	GetHashKey("blood_shark_attack"),
	GetHashKey("td_blood_shotgun"),
	GetHashKey("td_blood_throat"),
	GetHashKey("blood_melee_punch"),
	GetHashKey("blood_exit"),
	GetHashKey("blood_chopper"),
	GetHashKey("trail_splash_blood"),
	GetHashKey("td_blood_stab"),
	GetHashKey("blood_armour_heavy"),
	GetHashKey("blood_mist"),
	GetHashKey("blood_nose"),
	GetHashKey("blood_entry_head_sniper"),
	GetHashKey("scr_ba_bomb_destroy"),
	GetHashKey("scr_clown_appears")
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSETS
-----------------------------------------------------------------------------------------------------------------------------------------
local Assets = {
	GetHashKey("core"),
	GetHashKey("scr_ba_bomb"),
	GetHashKey("scr_rcbarry2"),
	GetHashKey("scr_rcpaparazzo1")
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PTFXEVENT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("ptFxEvent",function(source,Data)
	for _,v in pairs(Particles) do
		if v == Data["effectHash"] then
			CancelEvent()

			local Passport = vRP.Passport(source)
			if Passport then
				exports["discord"]:Embed("Hackers","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[MOTIVO]:** Particles Block\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
			end
		end
	end

	for _,v in pairs(Assets) do
		if v == Data["assetHash"] then
			CancelEvent()

			local Passport = vRP.Passport(source)
			if Passport then
				exports["discord"]:Embed("Hackers","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[MOTIVO]:** Assets Block\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"),source)
			end
		end
	end
end)
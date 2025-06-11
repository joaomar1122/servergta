-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Sources = {}
Characters = {}
local Prepare = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Prepare(Name,Query)
	Prepare[Name] = Query
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Query(Name,Params)
	return exports["oxmysql"]:query_async(Prepare[Name],Params)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SCALAR
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Scalar(Name,Params)
	return exports["oxmysql"]:scalar_async(Prepare[Name],Params)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITIES
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Identities(source)
	local Return = false

	local Identities = GetPlayerIdentifierByType(source,BaseMode)
	if Identities then
		Return = SplitTwo(Identities,":")
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARCHIVE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Archive(Archive,Text)
	Archive = io.open(Archive,"a")

	if Archive then
		Archive:write(Text.."\n")
	end

	Archive:close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Account(License)
	local Account = vRP.Query("accounts/Account",{ License = License })
	return Account[1] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCOUNTINFORMATION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.AccountInformation(Passport,Mode)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)
	if Identity then
		local Account = vRP.Account(Identity["License"])
		if Account then
			return Account[Mode]
		end
	end

	return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UserData(Passport,Key)
	local Consult = vRP.Query("playerdata/GetData",{ Passport = Passport, Name = Key })
	if Consult[1] then
		return json.decode(Consult[1]["Information"])
	else
		return {}
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSIDEPROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InsidePropertys(Passport,Coords)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		Datatable["Pos"] = Coords
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Inventory(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		if not Datatable["Inventory"] then
			Datatable["Inventory"] = {}
		end

		return Datatable["Inventory"]
	end

	return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SkinCharacter(Passport,Hash)
	vRP.Query("characters/SetSkin",{ Passport = Passport, Skin = Hash })

	local source = vRP.Source(Passport)
	if Characters[source] then
		Characters[source]["Skin"] = Hash
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Passport(source)
	return Characters[source] and Characters[source]["id"] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Players()
	return Sources
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERSOURCE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Source(Passport)
	return Sources[parseInt(Passport)] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATATABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Datatable(Passport)
	local Passport = parseInt(Passport)
	local source = Sources[Passport]

	return Characters[source] and Characters[source]["Datatable"] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANNED
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Banned(source,Account)
	local Return = false
	local Tokens = GetNumPlayerTokens(source) - 1
	local Identities = GetPlayerIdentifiers(source)

	for _,v in pairs(Identities) do
		local Consult = vRP.Query("hwid/Check",{ Token = v })

		if not Consult[1] then
			vRP.Query("hwid/Insert",{ Token = v, Account = Account["id"] })
		else
			if Consult[1]["Banned"] then
				if Consult[1]["Account"] == Account["id"] then
					if not Return then
						Return = "User"
					end
				else
					vRP.Query("hwid/Insert",{ Token = v, Account = Account["id"] })

					if not Return then
						Return = { "Other",Consult[1]["Account"] }
					end
				end
			end
		end
	end

	for Number = 0,Tokens do
		local Token = GetPlayerToken(source,Number)
		if Token then
			local Consult = vRP.Query("hwid/Check",{ Token = Token })

			if not Consult[1] then
				vRP.Query("hwid/Insert",{ Token = Token, Account = Account["id"] })
			else
				if Consult[1]["Banned"] then
					if Consult[1]["Account"] == Account["id"] then
						if not Return then
							Return = "User"
						end
					else
						vRP.Query("hwid/Insert",{ Token = Token, Account = Account["id"] })

						if not Return then
							Return = { "Other",Consult[1]["Account"] }
						end
					end
				end
			end
		end
	end

	if os.time() < Account["Banned"] then
		vRP.Query("hwid/All",{ Account = Account["id"], Banned = 1 })

		if not Return then
			Return = "User"
		end
	else
		vRP.Query("hwid/All",{ Account = Account["id"], Banned = 0 })

		if Return == "User" then
			Return = false
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Kick(source,Reason)
	Dropped(source,Reason)
	DropPlayer(source,Reason)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function(Reason)
	Dropped(source,Reason)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
function Dropped(source,Reason)
	if vRP.DoesEntityExist(source) then
		local Ped = GetPlayerPed(source)
		local Armour = GetPedArmour(Ped)
		local Coords = GetEntityCoords(Ped)
		local Health = GetEntityHealth(Ped)

		Disconnect(source,Health,Armour,Coords,Reason)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Disconnect(source,Health,Armour,Coords,Reason)
	local Passport = vRP.Passport(source)
	local Datatable = vRP.Datatable(Passport)
	if Passport and Datatable then
		exports["discord"]:Embed("Disconnect","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[VIDA]:** "..Health.."\n**[COLETE]:** "..Armour.."\n**[COORDS]:** "..Coords.."\n**[MOTIVO]:** "..Reason.."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))

		Datatable["Pos"] = Coords
		Datatable["Health"] = Health
		Datatable["Armour"] = Armour

		TriggerEvent("Disconnect",Passport,source)
		GlobalState["Players"] = GetNumPlayerIndices()
		vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Datatable", Information = json.encode(Datatable) })
		vRP.Query("characters/LastLogin",{ Passport = Passport })
		Characters[source] = nil
		Sources[Passport] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERCONNECTING
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting",function(Name,Message,deferrals)
	deferrals.defer()

	local source = source
	local License = vRP.Identities(source)
	if License then
		local Account = vRP.Account(License)

		if not Account then
			vRP.Query("accounts/NewAccount",{ License = License, Token = vRP.GenerateToken() })
			Account = vRP.Account(License)
		end

		local Banned = vRP.Banned(source,Account)

		if not Banned then
			if Whitelisted then
				if Account["Whitelist"] then
					vRP.Query("accounts/LastLogin",{ License = License })
					deferrals.done()
				else
					deferrals.done("\n\nEfetue sua liberação através do link <b>"..ServerLink.."</b> enviando <b>"..Account[Liberation].."</b>")
				end
			else
				vRP.Query("accounts/LastLogin",{ License = License })
				deferrals.done()
			end
		else
			if Banned[1] == "Other" then
				deferrals.done("Banido | "..Banned[2].."\n\nInformamos que o motivo do seu banimento são por questões unilaterais, ou seja, onde outra pessoa da sua rede ou seu computador e periféricos comprometeu a sua conexão por completo devido a uma punição, fazendo assim com que a nossa equipe de administração não tenha qualquer tipo de ação nesse caso.")
			else
				deferrals.done("Banido\n\nAguarde "..CompleteTimers(Account["Banned"] - os.time()).." para sua liberação.")
			end
		end
	else
		deferrals.done("\n\nNão foi possível efetuar conexão com a "..(BaseMode == "steam" and "Steam" or "Rockstar")..".")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.CharacterChosen(source,Passport,Model)
	if Sources[Passport] then
		vRP.Kick(source,"Desconectado")
		return false
	end

	Sources[Passport] = source

	local Creation = false
	if not Characters[source] then
		vRP.Query("characters/LastLogin",{ Passport = Passport })

		local License = vRP.Identities(source)
		local Account = vRP.Account(License)
		local Person = vRP.Query("characters/Person",{ Passport = Passport })

		Characters[source] = {}

		for Index,v in pairs(Account) do
			Characters[source][Index] = v
		end

		for _,Table in pairs(Person) do
			for Index,v in pairs(Table) do
				Characters[source][Index] = v
			end
		end

		Characters[source]["Datatable"] = vRP.UserData(Passport,"Datatable")

		if Model then
			Creation = true
			Characters[source]["Datatable"]["Inventory"] = {}

			for Item,Amount in pairs(CharacterItens) do
				vRP.GenerateItem(Passport,Item,Amount,false)
			end

			vRP.Query("playerdata/SetData",{
				Passport = Passport,
				Name = "Barbershop",
				Information = json.encode(BarbershopInit[Model])
			})

			vRP.Query("playerdata/SetData",{
				Passport = Passport,
				Name = "Clothings",
				Information = json.encode(SkinshopInit[Model])
			})

			vRP.Query("playerdata/SetData",{
				Passport = Passport,
				Name = "Tattooshop",
				Information = json.encode({})
			})

			vRP.Query("playerdata/SetData",{
				Passport = Passport,
				Name = "Datatable",
				Information = json.encode({})
			})
		end

		if Account["Gemstone"] > 0 then
			TriggerClientEvent("hud:AddGemstone",source,Account["Gemstone"])
		end

		exports["discord"]:Embed("Connect","**[SOURCE]:** "..source.."\n**[PASSAPORTE]:** "..Passport.."\n**[ADDRESS]:** "..GetPlayerEndpoint(source).."\n**[LICENSE]:** "..Characters[source]["License"].."\n**[DISCORD]:** <@"..Characters[source]["Discord"]..">\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))

		if DiscordBot then
			exports["discord"]:Content("Rename",Account["Discord"].." #"..Passport.." "..Person[1]["Name"].." "..Person[1]["Lastname"])
		end
	end

	TriggerEvent("CharacterChosen",Passport,source,Creation)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FILESDIRECTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.FilesDirectory(Directory)
	local Archive = io.popen("dir \""..Directory.."\" /b")
	local Output = Archive:read("*a")
	local Files = {}
	Archive:close()

	for Filename in string.gmatch(Output,"([^\r\n]+)") do
		if Filename ~= "" then
			Files[#Files + 1] = Filename:match("^(.-)%.") or Filename
		end
	end

	return Files
end
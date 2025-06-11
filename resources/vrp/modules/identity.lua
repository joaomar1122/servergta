-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Identity(Passport)
	local Passport = parseInt(Passport)
	local UserSource = vRP.Source(Passport)

	if Characters[UserSource] then
		return Characters[UserSource]
	else
		local Consult = vRP.Query("characters/Person",{ Passport = Passport })
		if Consult[1] then
			return Consult[1]
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FULLNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.FullName(Passport)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)
	if Identity then
		return Identity["Name"].." "..Identity["Lastname"]
	else
		return NameDefault
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOWERNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.LowerName(Passport)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)
	if Identity then
		return Identity["Name"]
	else
		return SplitOne(NameDefault," ")
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LICENSE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.License(Passport)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)
	if Identity then
		return Identity["License"]
	end

	return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSERTPRISON
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InsertPrison(Passport,Amount)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)

	if Amount > 0 then
		vRP.Query("characters/InsertPrison",{ Passport = Passport, Prison = Amount })

		local source = vRP.Source(Passport)
		if Characters[source] then
			Characters[source]["Prison"] = Characters[source]["Prison"] + Amount
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEPRISON
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpdatePrison(Passport,Amount)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)

	if Amount > 0 then
		vRP.Query("characters/ReducePrison",{ Passport = Passport, Prison = Amount })

		local source = vRP.Source(Passport)
		if Characters[source] then
			Characters[source]["Prison"] = Characters[source]["Prison"] - Amount

			if Characters[source]["Prison"] <= 0 then
				Characters[source]["Prison"] = 0
				Player(source)["state"]["Prison"] = false
				vRP.Teleport(source,PrisonCoords["x"],PrisonCoords["y"],PrisonCoords["z"])
				TriggerClientEvent("Notify",source,"Sucesso","Serviços finalizados.","verde",5000)
			else
				TriggerClientEvent("Notify",source,"Boolingbroke","Restam <b>"..Characters[source]["Prison"].." serviços</b>.","default",5000)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADECHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeCharacters(source)
	if Characters[source] then
		vRP.Query("accounts/UpdateCharacters",{ License = Characters[source]["License"] })
		Characters[source]["Characters"] = Characters[source]["Characters"] + 1
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UserGemstone(License)
	return vRP.Account(License)["Gemstone"] or 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEGEMSTONE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeGemstone(Passport,Amount,SendLicense)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)
	if Amount > 0 and Identity then
		vRP.Query("accounts/AddGemstone",{ License = Identity["License"], Gemstone = Amount })

		if DiscordBot and SendLicense then
			local Account = vRP.Account(Identity["License"])
			exports["discord"]:Content("Gemstone",Account["Discord"].." Obrigado por sua contribuição ao **"..ServerName.."**, seus **"..Dotted(Amount).."x Diamantes** foram creditados em sua conta.")
		end

		local source = vRP.Source(Passport)
		if Characters[source] then
			TriggerClientEvent("hud:AddGemstone",source,Amount)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADENAMES
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradeNames(Passport,Name,Lastname)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)
	vRP.Query("characters/UpdateName",{ Name = Name, Lastname = Lastname, Passport = Passport })

	if Characters[source] then
		Characters[source]["Name"] = Name
		Characters[source]["Lastname"] = Lastname
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORTPLATE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PassportPlate(Plate)
	local Consult = vRP.Query("vehicles/plateVehicles",{ Plate = Plate })
	return Consult[1] and Consult[1]["Passport"] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERTOKEN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UserToken(Token)
	return vRP.Query("accounts/Token",{ Token = Token })[1] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEPLATE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GeneratePlate()
	repeat
		Plate = GenerateString("DDLLLDDD")
		Passport = vRP.PassportPlate(Plate)
	until Plate and not Passport

	return Plate
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATETOKEN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GenerateToken()
	repeat
		Token = GenerateString("DDDDDDD")
		Passport = vRP.UserToken(Token)
	until Token and not Passport

	return Token
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEHASH
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GenerateHash(Index)
	repeat
		Hash = GenerateString("DDLLDDLL")
		Consult = vRP.Query("entitydata/GetData",{ Name = Index..":"..Hash })
	until Hash and not Consult[1]

	return Hash
end
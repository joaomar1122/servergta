-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Groups()
	return Groups
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERGROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UserGroups(Passport)
	local Table = {}
	for Permission in pairs(Groups) do
		local CheckPermission = vRP.HasPermission(Passport,Permission)
		if CheckPermission then
			Table[Permission] = CheckPermission
		end
	end

	return Table
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPLIMIT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GroupLimit(Permission)
	return Groups[Permission] and Groups[Permission]["Max"] or 999999
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATAGROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DataGroups(Permission)
	local Table = vRP.GetSrvData("Permissions:"..Permission,true)
	return Table,CountTable(Table)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPTYPE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GroupType(Permission)
	return Groups[Permission] and Groups[Permission]["Type"] or "UnWorked"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAINELBLOCK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PainelBlock(Permission)
	return Groups[Permission] and Groups[Permission]["Block"] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERTYPE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetUserType(Passport,Type)
	local Returned = false
	local Passport = tostring(Passport)

	for Permission in pairs(Groups) do
		if Groups[Permission]["Type"] and Groups[Permission]["Type"] == Type then
			local Consult = vRP.GetSrvData("Permissions:"..Permission,true)
			if Consult[Passport] then
				Returned = Permission
				break
			end
		end
	end

	return Returned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIERARCHY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Hierarchy(Permission)
	return Groups[Permission] and Groups[Permission]["Hierarchy"] or {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NAMEHIERARCHY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.NameHierarchy(Permission,Level)
	return Groups[Permission] and Groups[Permission]["Hierarchy"] and Groups[Permission]["Hierarchy"][Level] or Permission
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUMPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.NumPermission(Permission)
	local Amount = 0
	local Tables = {}

	if Groups[Permission] and Groups[Permission]["Permission"] then
		for Parent in pairs(Groups[Permission]["Permission"]) do
			if Groups[Parent] and Groups[Parent]["Service"] then
				for Passport,Source in pairs(Groups[Parent]["Service"]) do
					if Source and Characters[Source] and not Tables[Passport] then
						Tables[Passport] = Source
						Amount = Amount + 1
					end
				end
			end
		end
	end

	return Tables,Amount
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AMOUNTSERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.AmountService(Permission)
	local Amount = 0
	local Tables = {}

	if Groups[Permission] and Groups[Permission]["Permission"] then
		for Parent in pairs(Groups[Permission]["Permission"]) do
			if Groups[Parent] and Groups[Parent]["Service"] then
				for Passport,Source in pairs(Groups[Parent]["Service"]) do
					if Source and Characters[Source] and not Tables[Passport] then
						Tables[Passport] = true
						Amount = Amount + 1
					end
				end
			end
		end
	end

	return Amount
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AMOUNTGROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.AmountGroups(Permission)
	return CountTable(vRP.DataGroups(Permission))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICETOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ServiceToggle(Source,Passport,Permission,Silenced)
	if Characters[Source] then
		local Passport = tostring(Passport)
		local Permission = SplitOne(Permission)

		if Groups[Permission] then
			if Groups[Permission]["Service"] and Groups[Permission]["Service"][Passport] then
				vRP.ServiceLeave(Source,Passport,Permission,Silenced)
			else
				if vRP.HasPermission(Passport,Permission) then
					vRP.ServiceEnter(Source,Passport,Permission,Silenced)
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICEENTER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ServiceEnter(Source,Passport,Permission,Silenced)
	if Characters[Source] then
		if Permission == "Premium" and not vRP.UserPremium(Passport) then
			goto Ignore
		end

		if Groups[Permission] then
			local Passport = tostring(Passport)
			local Level = vRP.HasPermission(Passport,Permission)

			if Groups[Permission]["Client"] then
				Player(Source)["state"][Permission] = Level
			end

			if Groups[Permission]["Markers"] then
				exports["markers"]:Enter(Source,Permission,Level)
			end

			if Groups[Permission]["Salary"] then
				TriggerEvent("Salary:Add",Source,Passport,Permission)
			end

			if Groups[Permission]["Service"] then
				Groups[Permission]["Service"][Passport] = Source
				TriggerClientEvent("service:Client",Source,Permission,true)
			end
		end

		if not Silenced then
			TriggerClientEvent("Notify",Source,"Central de Empregos","Você acaba de dar inicio a sua jornada de trabalho, lembrando que a sua vida não se resume só a isso.","default",5000)
		end

		::Ignore::
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICELEAVE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ServiceLeave(Source,Passport,Permission,Silenced)
	if Characters[Source] then
		if Groups[Permission] then
			local Passport = tostring(Passport)

			if Groups[Permission]["Client"] then
				Player(Source)["state"][Permission] = false
			end

			if Groups[Permission]["Markers"] then
				exports["markers"]:Exit(Source,Passport)
				TriggerClientEvent("radio:RadioClean",Source)
			end

			if Groups[Permission]["Salary"] then
				TriggerEvent("Salary:Remove",Passport,Permission)
			end

			if Groups[Permission]["Service"] and Groups[Permission]["Service"][Passport] then
				TriggerClientEvent("service:Client",Source,Permission,false)
				Groups[Permission]["Service"][Passport] = nil
			end
		end

		if not Silenced then
			TriggerClientEvent("Notify",Source,"Central de Empregos","Você acaba finalizar sua jornada de trabalho, esperamos que você tenha aprendido bastante hoje.","default",5000)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SetPermission(Passport,Permission,Level,Mode)
	if Groups[Permission] then
		local Hierarchy = 5
		local Source = vRP.Source(Passport)
		local Passport = tostring(Passport)
		local Consult = vRP.GetSrvData("Permissions:"..Permission,true)

		if Groups[Permission]["Hierarchy"] then
			Hierarchy = CountTable(Groups[Permission]["Hierarchy"])
		end

		if Mode then
			if Mode == "Demote" then
				Consult[Passport] = Consult[Passport] + 1

				if Consult[Passport] > Hierarchy then
					Consult[Passport] = Hierarchy
				end
			else
				Consult[Passport] = Consult[Passport] - 1

				if Consult[Passport] <= 1 then
					Consult[Passport] = 1
				end
			end
		else
			if Level then
				Level = parseInt(Level)

				if Level > Hierarchy then
					Level = Hierarchy
				end
			end

			Consult[Passport] = Level or Hierarchy
		end

		local Discord = vRP.DiscordGroups(Permission)
		local Number = vRP.AccountInformation(Passport,"Discord")
		if DiscordBot and Discord and Number and Number ~= 0 then
			exports["discord"]:Content("Roles",Number.." "..Discord.." Adicionar")
		end

		vRP.ServiceEnter(Source,Passport,Permission,true)
		vRP.SetSrvData("Permissions:"..Permission,Consult,true)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RemovePermission(Passport,Permission)
	if Groups[Permission] then
		local Passport = tostring(Passport)
		local Source = vRP.Source(Passport)

		if Groups[Permission]["Service"] and Groups[Permission]["Service"][Passport] then
			Groups[Permission]["Service"][Passport] = nil
		end

		local Consult = vRP.GetSrvData("Permissions:"..Permission,true)
		if Consult[Passport] then
			local Discord = vRP.DiscordGroups(Permission)
			local Number = vRP.AccountInformation(Passport,"Discord")
			if DiscordBot and Discord and Number and Number ~= 0 then
				exports["discord"]:Content("Roles",Number.." "..Discord.." Remover")
			end

			if vRP.GroupType(Permission) == "Work" then
				vRP.Query("characters/SetGroupsTimer",{ Passport = Passport, Groups = os.time() + GroupsSetCooldown })

				if Characters[Source] then
					Characters[Source]["Groups"] = os.time() + GroupsSetCooldown
				end
			end

			Consult[Passport] = nil
			vRP.ServiceLeave(Source,Passport,Permission,true)
			vRP.SetSrvData("Permissions:"..Permission,Consult,true)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.HasPermission(Passport,Permission,Level)
	local CheckPermission = splitString(Permission,"-")
	if CheckPermission[2] then
		Permission = CheckPermission[1]
		Level = parseInt(CheckPermission[2])
	end

	if Groups[Permission] then
		if type(Passport) ~= "string" then
			Passport = tostring(Passport)
		end

		local Consult = vRP.GetSrvData("Permissions:"..Permission,true)
		if Consult[Passport] and (not Level or Consult[Passport] <= Level) then
			return Consult[Passport]
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASTABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.HasTable(Passport,Table)
	local Results = false
	local Passport = tostring(Passport)

	for _,Permission in pairs(Table) do
		local Check = splitString(Permission)
		local LevelParented = (Check[2] and parseInt(Check[2]) or false)
		local Parented = Check[1]

		local Consult = vRP.GetSrvData("Permissions:"..Parented,true)
		if Consult[Passport] and (not LevelParented or (LevelParented and Consult[Passport] <= LevelParented)) then
			Results = true
		end
	end

	return Results
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASGROUP
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.HasGroup(Passport,Permission,Level)
	local Results = false
	local CheckPermission = splitString(Permission)
	if CheckPermission[2] then
		Permission = CheckPermission[1]
		Level = parseInt(CheckPermission[2])
	end

	if Groups[Permission] then
		local Passport = tostring(Passport)
		for Parent in pairs(Groups[Permission]["Permission"]) do
			local Check = splitString(Parent)
			local LevelParented = (Check[2] and parseInt(Check[2]) or false)
			local Parented = Check[1]

			local Consult = vRP.GetSrvData("Permissions:"..Parented,true)
			if Consult[Passport] and ((not Level and not LevelParented) or (not Level and LevelParented and Consult[Passport] == LevelParented) or (Level and Consult[Passport] <= Level)) then
				Results = true
			end
		end
	end

	return Results
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASSERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.HasService(Passport,Permission,Level)
	local Results = false
	local CheckPermission = splitString(Permission)
	if CheckPermission[2] then
		Permission = CheckPermission[1]
		Level = parseInt(CheckPermission[2])
	end

	if Groups[Permission] and Groups[Permission]["Service"] then
		local Passport = tostring(Passport)
		for Parent in pairs(Groups[Permission]["Permission"]) do
			local Check = splitString(Parent)
			local LevelParented = (Check[2] and parseInt(Check[2]) or false)
			local Parented = Check[1]

			local Consult = vRP.GetSrvData("Permissions:"..Parented,true)
			if Consult[Passport] and Groups[Parented]["Service"][Passport] and ((not Level and not LevelParented) or (not Level and LevelParented and Consult[Passport] == LevelParented) or (Level and Consult[Passport] <= Level)) then
				Results = true
			end
		end
	end

	return Results
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORDGROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.DiscordGroups(Permission)
	return Groups[Permission] and Groups[Permission]["Discord"] or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,Source,First)
	local Passport = tostring(Passport)
	for Permission in pairs(Groups) do
		if vRP.HasPermission(Passport,Permission) and (Groups[Permission]["Service"][Passport] == false or (First and Groups[Permission]["Service"][Passport] == nil)) then
			vRP.ServiceEnter(Source,Passport,Permission,true)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	local Passport = tostring(Passport)
	for Permission,Tables in pairs(Groups) do
		if Groups[Permission]["Service"] and Groups[Permission]["Service"][Passport] then
			Groups[Permission]["Service"][Passport] = false
		end

		if Groups[Permission]["Salary"] then
			TriggerEvent("Salary:Remove",Passport,Permission)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SetPremium(source,Passport,Level,Days)
	if Characters[source] then
		vRP.Query("accounts/SetPremium",{ License = Characters[source]["License"], Level = Level, Days = Days or 30 })
		Characters[source]["Premium"] = os.time() + 2592000
		Characters[source]["Level"] = Level

		if not vRP.HasPermission(Passport,"Premium",Level) then
			vRP.SetPermission(Passport,"Premium",Level)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpgradePremium(source,Passport,Level,Days)
	if Characters[source] then
		vRP.Query("accounts/UpgradePremium",{ License = Characters[source]["License"], Level = Level, Days = Days or 30 })
		Characters[source]["Premium"] = Characters[source]["Premium"] + 2592000
		Characters[source]["Level"] = Level

		if not vRP.HasPermission(Passport,"Premium",Level) then
			vRP.SetPermission(Passport,"Premium",Level)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UserPremium(Passport)
	local Return = false
	local source = vRP.Source(Passport)

	if Characters[source] then
		if Characters[source]["Premium"] > os.time() then
			if not vRP.HasPermission(Passport,"Premium",Characters[source]["Level"]) then
				vRP.SetPermission(Passport,"Premium",Characters[source]["Level"])
			end

			Return = math.floor((Characters[source]["Premium"] - os.time()) / 86400)
		else
			if vRP.HasPermission(Passport,"Premium") then
				vRP.RemovePermission(Passport,"Premium")
			end
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LICENSEPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.LicensePremium(License)
	local Account = vRP.Account(License)

	return Account and Account["Premium"] >= os.time() and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LEVELPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.LevelPremium(source)
	local Level = #PremiumWeight
	if Characters[source] then
		Level = Characters[source]["Level"]
	else
		local License = vRP.Identities(source)
		local Account = vRP.Account(License)
		if Account then
			Level = Account["Level"]
		end
	end

	return Level
end
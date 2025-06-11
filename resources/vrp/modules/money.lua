-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEBANK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GiveBank(Passport,Amount,Notify)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 then
		exports["bank"]:AddTransactions(Passport,"entry",Amount)
		vRP.Query("characters/AddBank",{ Passport = Passport, Bank = Amount })

		if Characters[source] then
			Characters[source]["Bank"] = Characters[source]["Bank"] + Amount

			if Notify then
				TriggerClientEvent("NotifyItem",source,{ "+","dollar",Amount,ItemName("dollar"),ItemRarity("dollar") })
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEBANK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RemoveBank(Passport,Amount)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 then
		exports["bank"]:AddTransactions(Passport,"exit",Amount)
		vRP.Query("characters/RemBank",{ Passport = Passport, Bank = Amount })

		if Characters[source] then
			Characters[source]["Bank"] = Characters[source]["Bank"] - Amount

			if Characters[source]["Bank"] < 0 then
				Characters[source]["Bank"] = 0
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETBANK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetBank(Passport)
	local Passport = parseInt(Passport)
	local Identity = vRP.Identity(Passport)

	return Identity and Identity["Bank"] or 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTGEMS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PaymentGems(Passport,Amount)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 and Characters[source] and vRP.UserGemstone(Characters[source]["License"]) >= Amount then
		vRP.Query("accounts/RemoveGemstone",{ License = Characters[source]["License"], Gemstone = Amount })
		TriggerClientEvent("hud:RemoveGemstone",source,Amount)

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTBANK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PaymentBank(Passport,Amount,Notify)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 and Characters[source] and Characters[source]["Bank"] >= Amount then
		vRP.RemoveBank(Passport,Amount,source)

		if Notify then
			TriggerClientEvent("NotifyItem",source,{ "-","dollar",Amount,ItemName("dollar"),ItemRarity("dollar") })
		end

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTFULL
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.PaymentFull(Passport,Amount,Notify)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 then
		if vRP.TakeItem(Passport,"dollar",Amount,Notify) then
			return true
		else
			return vRP.PaymentBank(Passport,Amount,Notify)
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAWCASH
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.WithdrawCash(Passport,Amount)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	local source = vRP.Source(Passport)

	if Amount > 0 and Characters[source] and Characters[source]["Bank"] >= Amount then
		vRP.GenerateItem(Passport,"dollar",Amount,true)
		vRP.RemoveBank(Passport,Amount,source)

		return true
	end

	return false
end
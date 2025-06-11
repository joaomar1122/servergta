-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Rolepass(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		if not Datatable["Rolepass"] or (Datatable["Rolepass"] and Datatable["Rolepass"]["Clean"] < os.time()) then
			Datatable["Rolepass"] = {
				["Free"] = 0,
				["Points"] = 0,
				["Premium"] = 0,
				["Active"] = false,
				["Clean"] = Rolepass + 2592000
			}
		end

		return Datatable["Rolepass"],Rolepass
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUYROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RolepassBuy(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		if not Datatable["Rolepass"] or (Datatable["Rolepass"] and Datatable["Rolepass"]["Clean"] < os.time()) then
			Datatable["Rolepass"] = {
				["Free"] = 0,
				["Points"] = 0,
				["Premium"] = 0,
				["Active"] = false,
				["Clean"] = Rolepass + 2592000
			}
		end

		Datatable["Rolepass"]["Active"] = Rolepass + 2592000
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSPAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RolepassPayment(Passport,Amount,Mode)
	local Datatable = vRP.Datatable(Passport)
	if Datatable and Datatable["Rolepass"]["Points"] and Datatable["Rolepass"]["Points"] >= Amount then
		Datatable["Rolepass"]["Points"] = Datatable["Rolepass"]["Points"] - Amount
		Datatable["Rolepass"][Mode] = Datatable["Rolepass"][Mode] + 1

		if Datatable["Rolepass"]["Points"] < 0 then
			Datatable["Rolepass"]["Points"] = 0
		end

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RolepassPoints(Passport,Amount,Notify)
	local Datatable = vRP.Datatable(Passport)
	if Datatable then
		if not Datatable["Rolepass"] or (Datatable["Rolepass"] and Datatable["Rolepass"]["Clean"] < os.time()) then
			Datatable["Rolepass"] = {
				["Free"] = 0,
				["Points"] = 0,
				["Premium"] = 0,
				["Active"] = false,
				["Clean"] = Rolepass + 2592000
			}
		end

		if Datatable["Rolepass"]["Active"] then
			Amount = Amount * 2
		end

		Datatable["Rolepass"]["Points"] = Datatable["Rolepass"]["Points"] + Amount

		if Notify then
			TriggerClientEvent("Notify",vRP.Source(Passport),"Passe de Batalha","Você recebeu "..Dotted(Amount).." pontos.","azul",5000)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETMEDICPLAN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SetMedicplan(source,Passport)
	vRP.Query("characters/SetMedicplan",{ Passport = Passport, Medic = os.time() + 604800 })

	if Characters[source] then
		Characters[source]["Medic"] = parseInt(os.time() + 604800)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MEDICPLAN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Medicplan(source)
	local Return = false

	if Characters[source] and Characters[source]["Medic"] > os.time() then
		Return = math.floor((Characters[source]["Medic"] - os.time()) / 86400)
	end

	return Return
end
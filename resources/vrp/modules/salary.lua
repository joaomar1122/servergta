-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Salary = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SALARY:ADD
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Salary:Add",function(Source,Passport,Permission)
	if not Salary[Permission] then
		Salary[Permission] = {}
	end

	if Salary[Permission] and not Salary[Permission][Passport] then
		Salary[Permission][Passport] = {
			["Timer"] = os.time() + SalaryCooldowns,
			["Source"] = Source
		}
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SALARY:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Salary:Remove",function(Passport,Permission)
	if Permission then
		if Salary[Permission] and Salary[Permission][Passport] then
			Salary[Permission][Passport] = nil
		end
	else
		for Permission,_ in pairs(Salary) do
			if Salary[Permission] and Salary[Permission][Passport] then
				Salary[Permission][Passport] = nil
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSALARY
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		Wait(60000)

		for Permission,_ in pairs(Salary) do
			for Passport,v in pairs(Salary[Permission]) do
				if Salary[Permission] and Salary[Permission][Passport] and os.time() >= Salary[Permission][Passport]["Timer"] and vRP.GetHealth(Salary[Permission][Passport]["Source"]) > 100 then
					Salary[Permission][Passport]["Timer"] = os.time() + SalaryCooldowns

					local Number = vRP.HasPermission(Passport,Permission)
					if Number then
						if Groups[Permission] and Groups[Permission]["Salary"] and Groups[Permission]["Salary"][Number] and Groups[Permission]["Salary"][Number] > 0 then
							vRP.GiveBank(Passport,Groups[Permission]["Salary"][Number],true)
						end
					else
						Salary[Permission][Passport] = nil
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	for Permission,_ in pairs(Salary) do
		if Salary[Permission] and Salary[Permission][Passport] then
			Salary[Permission][Passport] = nil
		end
	end
end)
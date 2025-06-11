-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Entitys = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVECHARGES
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.RemoveCharges(Passport,Item)
	local Return = false
	local Consult = vRP.ConsultItem(Passport,Item)
	if Consult and Consult["Item"] and Consult["Slot"] and Consult["Amount"] > 0 and vRP.TakeItem(Passport,Consult["Item"],1,false,Consult["Slot"]) then
		Return = true

		if ItemLoads(Consult["Item"]) then
			local Slotable = Consult["Slot"]
			local Name = SplitOne(Consult["Item"])
			local Charger = SplitTwo(Consult["Item"]) - 1

			if Consult["Amount"] and Consult["Amount"] > 1 then
				Slotable = false
			end

			if Charger >= 1 then
				vRP.GiveItem(Passport,Name.."-"..Charger,1,false,Slotable)
			else
				local Empty = ItemEmpty(Consult["Item"])
				if Empty and ItemExist(Empty) then
					vRP.GenerateItem(Passport,Empty,1,false,Slotable)
				end
			end
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONSULTITEM
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.ConsultItem(Passport,Item,Amount)
	if vRP.Source(Passport) then
		local Passport = parseInt(Passport)
		local Amount = parseInt(Amount,true)
		local Consult = vRP.InventoryItemAmount(Passport,Item)
		if Consult[1] >= Amount and not vRP.CheckDamaged(Consult[2]) then
			return {
				["Amount"] = Consult[1],
				["Item"] = Consult[2],
				["Slot"] = Consult[3]
			}
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.GetWeight(Passport,Ignore)
	local Weight = 0
	local source = vRP.Source(Passport)

	if Characters[source] then
		local Passport = parseInt(Passport)
		local Datatable = vRP.Datatable(Passport)
		if Datatable then
			if not Datatable["Weight"] then
				Datatable["Weight"] = MinimumWeight
			end

			Weight = Datatable["Weight"]

			if not Ignore then
				if vRP.UserPremium(Passport) then
					Weight = Weight + PremiumWeight[vRP.LevelPremium(source)]
				end

				local Slotable = vRP.CheckSlotable(Passport,"104")
				if Slotable then
					Weight = Weight + ItemBackpack(Slotable)
				end
			end
		end
	end

	return Weight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.CheckWeight(Passport,Item,Amount)
	return ((vRP.InventoryWeight(Passport) + (ItemWeight(Item) * (Amount or 1))) <= vRP.GetWeight(Passport)) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.UpgradeWeight(Passport,Amount,Mode)
	local Datatable = vRP.Datatable(Passport)
	if vRP.Source(Passport) and Datatable then
		if not Datatable["Weight"] then
			Datatable["Weight"] = MinimumWeight
		end

		if Mode == "+" then
			Datatable["Weight"] = Datatable["Weight"] + Amount
		else
			Datatable["Weight"] = Datatable["Weight"] - Amount

			if Datatable["Weight"] <= MinimumWeight then
				Datatable["Weight"] = MinimumWeight
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKSLOTABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.CheckSlotable(Passport,Slot)
	local Return = false

	if vRP.Source(Passport) then
		local Slot = tostring(Slot)
		local Passport = parseInt(Passport)
		local Inv = vRP.Inventory(Passport)
		if Inv and Inv[Slot] and Inv[Slot]["item"] and ItemExist(Inv[Slot]["item"]) and Inv[Slot]["amount"] and Inv[Slot]["amount"] >= 1 and not vRP.CheckDamaged(Inv[Slot]["item"]) then
			Return = Inv[Slot]["item"]
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SWAPSLOT	
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.SwapSlot(Passport,Slot,Target)
	local Slot = tostring(Slot)
	local Target = tostring(Target)
	local Passport = parseInt(Passport)

	if Sources[Passport] then
		local Inv = vRP.Inventory(Passport)

		if Inv then
			local TemporarySlot = Inv[Slot]
			local TemporaryTarget = Inv[Target]
			Inv[Slot] = TemporaryTarget
			Inv[Target] = TemporarySlot
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InventoryWeight(Passport)
	local Weight = 0

	if vRP.Source(Passport) then
		local Passport = parseInt(Passport)
		local Inv = vRP.Inventory(Passport)

		for _,v in pairs(Inv) do
			if ItemExist(v["item"]) then
				Weight = Weight + ItemWeight(v["item"]) * v["amount"]
			end
		end
	end

	return Weight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKDAMAGED
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.CheckDamaged(Item)
	if ItemDurability(Item) and SplitTwo(Item) then
		local Max = 3600 * ItemDurability(Item)
		local Actual = parseInt(os.time() - SplitTwo(Item))
		local New = (Max - Actual) / Max

		if parseInt(New * 100) <= 1 then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ChestWeight(Data)
	local Weight = 0

	for _,v in pairs(Data) do
		if ItemExist(v["item"]) then
			Weight = Weight + ItemWeight(v["item"]) * v["amount"]
		end
	end

	return Weight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InventoryItemAmount(Passport,Item)
	if vRP.Source(Passport) then
		local Passport = parseInt(Passport)
		local Inv = vRP.Inventory(Passport)

		for Slot,v in pairs(Inv) do
			if SplitOne(Item) == SplitOne(v["item"]) then
				return { v["amount"],v["item"],Slot }
			end
		end
	end

	return { 0,"" }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYFULL
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.InventoryFull(Passport,Item)
	if vRP.Source(Passport) then
		local Passport = parseInt(Passport)
		local Inv = vRP.Inventory(Passport)

		for _,v in pairs(Inv) do
			if v["item"] == Item then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ItemAmount(Passport,Item)
	local Amount = 0

	if vRP.Source(Passport) then
		local Passport = parseInt(Passport)
		local Inv = vRP.Inventory(Passport)

		for _,v in pairs(Inv) do
			if SplitOne(v["item"]) == SplitOne(Item) then
				Amount = Amount + v["amount"]
			end
		end
	end

	return Amount
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMCHESTAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ItemChestAmount(Data,Item,Save)
	local Amount = 0
	local Consult = vRP.GetSrvData(Data,Save)

	for _,v in pairs(Consult) do
		if SplitOne(v["item"]) == SplitOne(Item) then
			Amount = Amount + v["amount"]
		end
	end

	return Amount
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GiveItem(Passport,Item,Amount,Notify,Slot)
	local Return = false
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	if vRP.Source(Passport) and Amount > 0 then
		local source = vRP.Source(Passport)
		local Inv = vRP.Inventory(Passport)
		local Animation = ItemAnim(Item)

		if not Slot then
			local Selected = "1"
			local MaxSlots = vRP.GetWeight(Passport)

			if MaxSlots > SlotInventory then
				MaxSlots = SlotInventory
			end

			for Number = 1,MaxSlots do
				local Number = tostring(Number)
				if not Inv[Number] or (Inv[Number] and Inv[Number]["item"] == Item) then
					Selected = Number

					break
				end
			end

			if not Inv[Selected] then
				Inv[Selected] = { item = Item, amount = Amount }

				if ItemTypeCheck(Item,"Armamento") and vRP.ConsultItem(Passport,Item) then
					TriggerClientEvent("inventory:CreateWeapon",source,Item)
				end
			elseif Inv[Selected] and Inv[Selected]["item"] == Item then
				Inv[Selected]["amount"] = Inv[Selected]["amount"] + Amount
			end

			if Animation then
				vRPC.PersistentBlock(source,Item,Animation)
			end

			if Notify and ItemExist(Item) then
				TriggerClientEvent("NotifyItem",source,{ "+",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
			end

			Return = true
		else
			local Slot = tostring(Slot)
			if Inv[Slot] and Inv[Slot]["item"] == Item then
				Inv[Slot]["amount"] = Inv[Slot]["amount"] + Amount
			else
				Inv[Slot] = { item = Item, amount = Amount }

				if ItemTypeCheck(Item,"Armamento") and vRP.ConsultItem(Passport,Item) then
					TriggerClientEvent("inventory:CreateWeapon",source,Item)
				end
			end

			if Animation then
				vRPC.PersistentBlock(source,Item,Animation)
			end

			if Notify and ItemExist(Item) then
				TriggerClientEvent("NotifyItem",source,{ "+",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
			end

			Return = true
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GenerateItem(Passport,Item,Amount,Notify,Slot)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	if vRP.Source(Passport) and Amount > 0 then
		local source = vRP.Source(Passport)
		local Inv = vRP.Inventory(Passport)
		local Animation = ItemAnim(Item)

		Item = vRP.SortNameItem(Passport,Item)

		if not Slot then
			local Selected = "1"
			local MaxSlots = vRP.GetWeight(Passport)

			if MaxSlots > SlotInventory then
				MaxSlots = SlotInventory
			end

			for Number = 1,MaxSlots do
				local Number = tostring(Number)
				if not Inv[Number] or (Inv[Number] and Inv[Number]["item"] == Item) then
					Selected = Number
					break
				end
			end

			if not Inv[Selected] then
				Inv[Selected] = { item = Item, amount = Amount }

				if ItemTypeCheck(Item,"Armamento") and vRP.ConsultItem(Passport,Item) then
					TriggerClientEvent("inventory:CreateWeapon",source,Item)
				end
			elseif Inv[Selected] and Inv[Selected]["item"] == Item then
				Inv[Selected]["amount"] = Inv[Selected]["amount"] + Amount
			end

			if Animation then
				vRPC.PersistentBlock(source,Item,Animation)
			end

			if Notify and ItemExist(Item) then
				TriggerClientEvent("NotifyItem",source,{ "+",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
			end
		else
			local Slot = tostring(Slot)
			if Inv[Slot] and Inv[Slot]["item"] == Item then
				Inv[Slot]["amount"] = Inv[Slot]["amount"] + Amount
			else
				Inv[Slot] = { item = Item, amount = Amount }

				if ItemTypeCheck(Item,"Armamento") and vRP.ConsultItem(Passport,Item) then
					TriggerClientEvent("inventory:CreateWeapon",source,Item)
				end
			end

			if Animation then
				vRPC.PersistentBlock(source,Item,Animation)
			end

			if Notify and ItemExist(Item) then
				TriggerClientEvent("NotifyItem",source,{ "+",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAXITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.MaxItens(Passport,Item,Amount)
	local Passport = parseInt(Passport)
	local Amount = parseInt(Amount,true)
	local MaxAmount = ItemMaxAmount(Item)

	return (ItemExist(Item) and MaxAmount and (vRP.ItemAmount(Passport,Item) + Amount) > MaxAmount) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAXCHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.MaxChest(Data,Item,Amount,Save)
	local Amount = parseInt(Amount)
	local MaxAmount = ItemMaxAmount(Item)

	return (ItemExist(Item) and MaxAmount and (vRP.ItemChestAmount(Data,Item,Save) + Amount) > MaxAmount) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.TakeItem(Passport,Item,Amount,Notify,Slot)
	local Returned = false
	local Passport = parseInt(Passport)
	local Amount = parseInt(Amount,true)
	if vRP.Source(Passport) and Amount > 0 then
		local source = vRP.Source(Passport)
		local Inv = vRP.Inventory(Passport)
		local Animation = ItemAnim(Item)

		if not Slot then
			for Index,v in pairs(Inv) do
				if v["item"] == Item and v["amount"] >= Amount then
					v["amount"] = v["amount"] - Amount

					if v["amount"] <= 0 then
						if Animation and not vRP.ConsultItem(Passport,Item) then
							vRPC.PersistentNone(source,Item)
						end

						if ItemTypeCheck(Item,"Armamento") or ItemTypeCheck(Item,"Arremesso") then
							TriggerClientEvent("inventory:verifyWeapon",source,Item)
						end

						if Index == "104" then
							local Skinshop = ItemSkinshop(Item)
							if Skinshop then
								TriggerClientEvent("skinshop:BackpackRemove",source)
							end
						end

						Inv[Index] = nil
					end

					if Notify and ItemExist(Item) then
						TriggerClientEvent("NotifyItem",source,{ "-",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
					end

					Returned = true

					break
				end
			end
		else
			local Slot = tostring(Slot)
			if Inv[Slot] and Inv[Slot]["item"] == Item and Inv[Slot]["amount"] >= Amount then
				Inv[Slot]["amount"] = Inv[Slot]["amount"] - Amount

				if Inv[Slot]["amount"] <= 0 then
					if Animation and not vRP.ConsultItem(Passport,Item) then
						vRPC.PersistentNone(source,Item)
					end

					if ItemTypeCheck(Item,"Armamento") or ItemTypeCheck(Item,"Arremesso") then
						TriggerClientEvent("inventory:verifyWeapon",source,Item)
					end

					if Slot == "104" then
						local Skinshop = ItemSkinshop(Item)
						if Skinshop then
							TriggerClientEvent("skinshop:BackpackRemove",source)
						end
					end

					Inv[Slot] = nil
				end

				if Notify and ItemExist(Item) then
					TriggerClientEvent("NotifyItem",source,{ "-",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
				end

				Returned = true
			end
		end

		local Execute = ItemExecute(Item)
		if Execute and Execute["Event"] and Execute["Type"] and not vRP.ConsultItem(Passport,Item) then
			if Execute["Type"] == "Client" then
				TriggerClientEvent(Execute["Event"],source)
			else
				TriggerEvent(Execute["Event"],source,Passport)
			end
		end
	end

	return Returned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RemoveItem(Passport,Item,Amount,Notify)
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	if vRP.Source(Passport) and Amount > 0 then
		local Inv = vRP.Inventory(Passport)
		local source = vRP.Source(Passport)
		local Animation = ItemAnim(Item)

		for Index,v in pairs(Inv) do
			if v["item"] == Item and v["amount"] >= Amount then
				v["amount"] = v["amount"] - Amount

				if v["amount"] <= 0 then
					if Animation and not vRP.ConsultItem(Passport,Item) then
						vRPC.PersistentNone(source,Item)
					end

					if ItemTypeCheck(Item,"Armamento") or ItemTypeCheck(Item,"Arremesso") then
						TriggerClientEvent("inventory:verifyWeapon",source,Item)
					end

					if ItemUnique(Item) then
						vRP.RemSrvData(SplitUnique(Item))
					end

					Inv[Index] = nil
				end

				if Notify and ItemExist(Item) then
					TriggerClientEvent("NotifyItem",source,{ "-",ItemIndex(Item),Amount,ItemName(Item),ItemRarity(Item) })
				end

				break
			end
		end

		local Execute = ItemExecute(Item)
		if Execute and Execute["Event"] and Execute["Type"] and not vRP.ConsultItem(Passport,Item) then
			if Execute["Type"] == "Client" then
				TriggerClientEvent(Execute["Event"],source)
			else
				TriggerEvent(Execute["Event"],source,Passport)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetSrvData(Key,Save)
	if not Entitys[Key] then
		local Consult = vRP.Query("entitydata/GetData",{ Name = Key })
		if Consult[1] then
			Entitys[Key] = { data = json.decode(Consult[1]["Information"]), timer = os.time() + 180, save = Save }
		else
			Entitys[Key] = { data = {}, timer = os.time() + 180, save = Save }
		end
	end

	return Entitys[Key]["data"]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SetSrvData(Key,Data,Save)
	Entitys[Key] = { data = Data, timer = os.time() + 180, save = Save }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMSRVDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RemSrvData(Key)
	if Entitys[Key] then
		Entitys[Key] = nil
	end

	vRP.Query("entitydata/RemoveData",{ Name = Key })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADENTITYS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		for Data,v in pairs(Entitys) do
			if os.time() >= v["timer"] and v["save"] then
				if type(v["data"]) == "string" then
					vRP.Query("entitydata/SetData",{ Name = Data, Information = v["data"] })
				else
					vRP.Query("entitydata/SetData",{ Name = Data, Information = json.encode(v["data"]) })
				end

				Entitys[Data] = nil
			end
		end

		Wait(60000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaveServer",function(Silenced)
	for Index,Info in pairs(Entitys) do
		if Info["save"] then
			vRP.Query("entitydata/SetData",{ Name = Index, Information = json.encode(Info["data"]) })
		else
			if Silenced and SplitOne(Index,":") == "Trash" then
				for _,v in pairs(Info["data"]) do
					if v["item"] and ItemUnique(v["item"]) then
						vRP.RemSrvData(SplitUnique(v["item"]))
					end
				end
			end
		end
	end

	for Passport,_ in pairs(Sources) do
		local Datatable = vRP.Datatable(Passport)
		if Datatable then
			vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Datatable", Information = json.encode(Datatable) })
		end
	end

	if not Silenced then
		print("O resource ^2vRP^7 salvou os dados.")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVUPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.invUpdate(Slot,Target,Amount)
	local source = source
	local Amount = parseInt(Amount)
	local Passport = vRP.Passport(source)
	if Passport and Amount > 0 then
		local Item = nil
		local Returned = true
		local Slot = tostring(Slot)
		local Target = tostring(Target)
		local Inv = vRP.Inventory(Passport)

		if Inv[Slot] then
			Item = Inv[Slot]["item"]

			if Inv[Target] then
				if Inv[Slot] and Inv[Target] then
					if Item == Inv[Target]["item"] then
						if Inv[Slot]["amount"] >= Amount then
							Inv[Slot]["amount"] = Inv[Slot]["amount"] - Amount
							Inv[Target]["amount"] = Inv[Target]["amount"] + Amount

							if Inv[Slot]["amount"] <= 0 then
								Inv[Slot] = nil
							end

							Returned = false
						end
					else
						local Unique = SplitOne(Item)
						local Splice = splitString(Inv[Target]["item"])
						local ItemRepair = ItemRepair(Inv[Target]["item"])
						local ItemFishing = ItemFishing(Inv[Target]["item"])

						if SplitOne(Item) == "gsrkit" and ItemSerial(Splice[1]) then
							if vRP.TakeItem(Passport,Item,1,false,Slot) then
								if Splice[4] then
									TriggerClientEvent("inventory:Notify",source,"Sucesso","Propriedade do passaporte <b>"..Splice[4].."</b>","verde")
								else
									TriggerClientEvent("inventory:Notify",source,"Aviso","Serial não encontrado.","amarelo")
								end
							end
						elseif SplitOne(Item) == "WEAPON_SWITCHBLADE" and not vRP.CheckDamaged(Item) and ItemFishing then
							local Temporary = Inv[Target]["amount"]
							if vRP.TakeItem(Passport,Inv[Target]["item"],Temporary,false,Target) then
								vRP.GenerateItem(Passport,"fishfillet",Temporary * ItemFishing)
							end
						elseif vRP.CheckDamaged(Inv[Target]["item"]) and ItemRepair and Inv[Target]["amount"] == 1 and ItemRepair == Unique then
							if ItemTypeCheck(Inv[Target]["item"],"Armamento") and parseInt(Splice[3]) <= 0 then
								TriggerClientEvent("inventory:Notify",source,"Aviso","Armamento não pode ser reparado.","amarelo")
							else
								if vRP.TakeItem(Passport,Item,1,false,Slot) then
									if ItemTypeCheck(Inv[Target]["item"],"Armamento") then
										local Serial = ""
										if Splice[4] then
											Serial = "-"..Passport
										end

										Inv[Target]["item"] = Splice[1].."-"..os.time().."-"..parseInt(Splice[3] - 1)..Serial
									else
										if ItemUnique(Splice[1]) then
											Inv[Target]["item"] = Splice[1].."-"..os.time().."-"..Splice[3]
										else
											Inv[Target]["item"] = Splice[1].."-"..os.time()
										end
									end
								end
							end
						else
							local TemporarySlot = Inv[Slot]
							local TemporaryTarget = Inv[Target]
							Inv[Slot] = TemporaryTarget
							Inv[Target] = TemporarySlot

							Returned = false
						end
					end
				end
			else
				if Inv[Slot] and Inv[Slot]["amount"] >= Amount then
					Inv[Target] = { item = Item, amount = Amount }
					Inv[Slot]["amount"] = Inv[Slot]["amount"] - Amount

					if Inv[Slot]["amount"] <= 0 then
						Inv[Slot] = nil
					end

					Returned = false
				end
			end
		end

		if Item and (Returned or Target == "104" or Slot == "104") then
			TriggerClientEvent("inventory:Update",source)

			local Skinshop = ItemSkinshop(Item)
			if Target == "104" and Skinshop then
				TriggerClientEvent("skinshop:Backpack",source,Skinshop)
			elseif Slot == "104" and Skinshop then
				TriggerClientEvent("skinshop:BackpackRemove",source)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYCHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.TakeChest(Passport,Data,Amount,Slot,Target,Save)
	local Returned = true
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	if vRP.Source(Passport) and Amount > 0 then
		local Slot = tostring(Slot)
		local source = vRP.Source(Passport)
		local Consult = vRP.GetSrvData(Data,Save)

		if Consult[Slot] then
			local Item = Consult[Slot]["item"]
			local Animation = ItemAnim(Item)

			if vRP.MaxItens(Passport,Item,Amount) then
				TriggerClientEvent("inventory:Notify",source,"Atenção","Limite atingido.","vermelho")

				return Returned
			end

			if vRP.CheckWeight(Passport,Item,Amount) then
				local Target = tostring(Target)
				local Inv = vRP.Inventory(Passport)

				if Inv[Target] and Consult[Slot] then
					if Inv[Target]["item"] == Item and Consult[Slot]["amount"] >= Amount then
						Inv[Target]["amount"] = Inv[Target]["amount"] + Amount
						Consult[Slot]["amount"] = Consult[Slot]["amount"] - Amount

						if Consult[Slot]["amount"] <= 0 then
							Consult[Slot] = nil
						end

						Returned = false
					end
				else
					if Consult[Slot] and Consult[Slot]["amount"] >= Amount then
						Inv[Target] = { item = Item, amount = Amount }
						Consult[Slot]["amount"] = Consult[Slot]["amount"] - Amount

						if Target == "104" then
							TriggerClientEvent("inventory:Update",source)

							local Skinshop = ItemSkinshop(Item)
							if Skinshop then
								TriggerClientEvent("skinshop:Backpack",source,Skinshop)
							end
						end

						if Animation then
							vRPC.PersistentBlock(source,Item,Animation)
						end

						if ItemTypeCheck(Item,"Armamento") and vRP.ConsultItem(Passport,Item) then
							TriggerClientEvent("inventory:CreateWeapon",source,Item)
						end

						if Consult[Slot]["amount"] <= 0 then
							Consult[Slot] = nil
						end

						Returned = false
					end
				end
			end
		end
	end

	return Returned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.RemoveChest(Data,Slot,Save)
	local Consult = vRP.GetSrvData(Data,Save)
	if Consult[Slot] then
		Consult[Slot] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.StoreChest(Passport,Data,Amount,Weight,Slot,Target,Save,Max)
	local Returned = true
	local Amount = parseInt(Amount)
	local Passport = parseInt(Passport)
	if vRP.Source(Passport) and Amount > 0 then
		local Slot = tostring(Slot)
		local Target = tostring(Target)
		local source = vRP.Source(Passport)
		local Inv = vRP.Inventory(Passport)

		if Inv[Slot] then
			local Item = Inv[Slot]["item"]
			local Animation = ItemAnim(Item)

			if not Max or not vRP.MaxChest(Data,Item,Amount,Save) then
				local Consult = vRP.GetSrvData(Data,Save)

				if (vRP.ChestWeight(Consult) + (ItemWeight(Item) * Amount)) <= Weight then
					if Consult[Target] and Inv[Slot] then
						if Item == Consult[Target]["item"] and Inv[Slot]["amount"] >= Amount then
							Consult[Target]["amount"] = Consult[Target]["amount"] + Amount
							Inv[Slot]["amount"] = Inv[Slot]["amount"] - Amount

							if Inv[Slot]["amount"] <= 0 then
								if Slot == "104" then
									TriggerClientEvent("inventory:Update",source)

									local Skinshop = ItemSkinshop(Item)
									if Skinshop then
										TriggerClientEvent("skinshop:BackpackRemove",source)
									end
								end

								if Animation and not vRP.ConsultItem(Passport,Item) then
									vRPC.PersistentNone(source,Item)
								end

								if ItemTypeCheck(Item,"Armamento") or ItemTypeCheck(Item,"Arremesso") then
									TriggerClientEvent("inventory:verifyWeapon",source,Item)
								end

								Inv[Slot] = nil
							end

							Returned = false
						end
					else
						if Inv[Slot] and Inv[Slot]["amount"] >= Amount then
							Consult[Target] = { item = Item, amount = Amount }
							Inv[Slot]["amount"] = Inv[Slot]["amount"] - Amount

							if Inv[Slot]["amount"] <= 0 then
								if Slot == "104" then
									TriggerClientEvent("inventory:Update",source)

									local Skinshop = ItemSkinshop(Item)
									if Skinshop then
										TriggerClientEvent("skinshop:BackpackRemove",source)
									end
								end

								if Animation and not vRP.ConsultItem(Passport,Item) then
									vRPC.PersistentNone(source,Item)
								end

								if ItemTypeCheck(Item,"Armamento") or ItemTypeCheck(Item,"Arremesso") then
									TriggerClientEvent("inventory:verifyWeapon",source,Item)
								end

								Inv[Slot] = nil
							end

							Returned = false
						end
					end
				end
			else
				TriggerClientEvent("inventory:Notify",source,"Atenção","Limite atingido.","vermelho")
			end

			local Execute = ItemExecute(Item)
			if Execute and Execute["Event"] and Execute["Type"] and not vRP.ConsultItem(Passport,Item) then
				if Execute["Type"] == "Client" then
					TriggerClientEvent(Execute["Event"],source)
				else
					TriggerEvent(Execute["Event"],source,Passport)
				end
			end
		end
	end

	return Returned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATECHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.UpdateChest(Passport,Data,Slot,Target,Amount,Save)
	local Returned = true
	local Passport = parseInt(Passport)
	local Amount = parseInt(Amount,true)
	if vRP.Source(Passport) and Amount > 0 then
		local Slot = tostring(Slot)
		local Target = tostring(Target)
		local Consult = vRP.GetSrvData(Data,Save)

		if Consult[Slot] then
			if Consult[Target] and Consult[Slot] then
				if Consult[Slot]["item"] == Consult[Target]["item"] then
					if Consult[Slot]["amount"] >= Amount then
						Consult[Slot]["amount"] = Consult[Slot]["amount"] - Amount

						if Consult[Slot]["amount"] <= 0 then
							Consult[Slot] = nil
						end

						Consult[Target]["amount"] = Consult[Target]["amount"] + Amount

						Returned = false
					end
				else
					local Temp = Consult[Slot]
					Consult[Slot] = Consult[Target]
					Consult[Target] = Temp

					Returned = false
				end
			else
				if Consult[Slot] and Consult[Slot]["amount"] >= Amount then
					Consult[Slot]["amount"] = Consult[Slot]["amount"] - Amount
					Consult[Target] = { item = Consult[Slot]["item"], amount = Amount }

					if Consult[Slot]["amount"] <= 0 then
						Consult[Slot] = nil
					end

					Returned = false
				end
			end
		end
	end

	return Returned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARRESTITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.ArrestItens(Passport)
	local Inv = vRP.Inventory(Passport)

	for _,v in pairs(Inv) do
		if ItemArrest(v["item"]) then
			vRP.RemoveItem(Passport,v["item"],v["amount"],true)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNTCONTAINER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.MountContainer(Passport,Name,Table,Multiplier,Save,Percentage)
	local Exist = {}
	local Numbers = 0
	local Organize = {}

	if not Percentage or math.random(1000) <= Percentage then
		repeat
			local Rand = RandPercentage(Table)
			local NameItem = Rand["Item"]
			if not Exist[NameItem] then
				Numbers = Numbers + 1
				Exist[NameItem] = true

				Organize[tostring(Numbers)] = {
					["item"] = vRP.SortNameItem(Passport,NameItem),
					["amount"] = math.random(Rand["Min"],Rand["Max"])
				}
			end
		until Numbers >= (Multiplier or 1)
	end

	vRP.SetSrvData(Name,Organize,Save or false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SORTNAMEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.SortNameItem(Passport,Item)
	local NameItem = Item
	if ItemUnique(Item) then
		local Hash = vRP.GenerateHash(Item)

		if Boxes[Item] then
			vRP.MountContainer(Passport,Item..":"..Hash,Boxes[Item]["List"],math.random(Boxes[Item]["Multiplier"]["Min"],Boxes[Item]["Multiplier"]["Max"]),true)
		end

		NameItem = Item.."-"..(os.time() - 1).."-"..Hash
	elseif ItemDurability(Item) then
		if ItemTypeCheck(Item,"Armamento") then
			NameItem = Item.."-"..(os.time() - 1).."-"..MaxRepair.."-"..Passport
		else
			NameItem = Item.."-"..(os.time() - 1)
		end
	elseif ItemLoads(Item) then
		NameItem = Item.."-"..ItemLoads(Item)
	elseif ItemNamed(Item) then
		NameItem = Item.."-"..Passport
	else
		NameItem = Item
	end

	return NameItem
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLPOLICE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("CallPolice",function(Table)
	if not Table["Percentage"] or math.random(1000) >= Table["Percentage"] then
		if Table["Wanted"] then
			TriggerEvent("Wanted",Table["Source"],Table["Passport"],Table["Wanted"])
		end

		if Table["Marker"] then
			exports["markers"]:Enter(Table["Source"],Table["Name"],1,Table["Passport"],type(Table["Marker"]) == "number" and Table["Marker"] or false)
		end

		if not Table["Coords"] then
			Table["Coords"] = vRP.GetEntityCoords(Table["Source"])
		end

		if Table["Notify"] then
			TriggerClientEvent("Notify",Table["Source"],"Departamento Policial","As autoridades foram acionadas.","policia",5000)
		end

		local Service = vRP.NumPermission(Table["Permission"])
		for Passports,Sources in pairs(Service) do
			async(function()
				vRPC.PlaySound(Sources,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
				TriggerClientEvent("NotifyPush",Sources,{ code = Table["Code"] or 20, title = Table["Name"], x = Table["Coords"]["x"], y = Table["Coords"]["y"], z = Table["Coords"]["z"], vehicle = Table["Vehicle"], color = Table["Color"] or 44 })
			end)
		end
	end
end)
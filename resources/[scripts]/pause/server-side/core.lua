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
Tunnel.bindInterface("pause",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Store = {}
local Active = {}
local Carousel = {}
local Shopping = {}
local Rolepass = {}
local PlayerBox = {}
local Marketplace = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Disconnect()
	local source = source
	vRP.Kick(source,"Desconectado")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HOME
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Home()
	local source = source
	local Passport = vRP.Passport(source)
	local Identity = vRP.Identity(Passport)
	local Datatable = vRP.Datatable(Passport)
	if Passport and Datatable and Identity then
		local Experience = {}
		for Index,v in pairs(Works) do
			Experience[#Experience + 1] = { v,Datatable[Index] or 0 }
		end

		local Shop = {}
		for Number = 1,9 do
			if Shopping[Number] then
				Shop[Number] = {
					["Image"] = Shopping[Number]["Image"],
					["Price"] = Shopping[Number]["Price"],
					["Amount"] = Shopping[Number]["Amount"],
					["Name"] = Shopping[Number]["Name"]
				}
			end
		end

		local Hierarchy = 1
		if vRP.UserPremium(Passport) then
			Hierarchy = vRP.LevelPremium(source)
		end

		return {
			["Information"] = {
				["Passport"] = Passport,
				["Bank"] = Identity["Bank"],
				["Phone"] = vRP.Phone(Passport),
				["Medic"] = vRP.Medicplan(source),
				["Blood"] = Sanguine(Identity["Blood"]),
				["Gemstone"] = vRP.UserGemstone(Identity["License"]),
				["Name"] = Identity["Name"].." "..Identity["Lastname"]
			},
			["Premium"] = {
				["Hierarchy"] = Hierarchy,
				["Display"] = Premium[Hierarchy],
				["Active"] = vRP.UserPremium(Passport)
			},
			["Levels"] = TableLevel(),
			["Experience"] = Experience,
			["Carousel"] = Carousel,
			["Shopping"] = Shop,
			["Box"] = Boxes[1]
		}
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADGENERATE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Consult = vRP.Query("entitydata/GetData",{ Name = "Marketplace" })
	if Consult[1] then
		Marketplace = json.decode(Consult[1]["Information"])
	end

	for Index,v in pairs(ShopItens) do
		Store[#Store + 1] = {
			["Index"] = Index,
			["Price"] = v["Price"],
			["Discount"] = v["Discount"],
			["Category"] = v["Category"],
			["Image"] = ItemIndex(Index),
			["Name"] = ItemName(Index),
			["Description"] = ItemDescription(Index)
		}

		if v["Discount"] < 1.0 then
			local Number = #Carousel + 1
			Carousel[Number] = {
				["Id"] = Number,
				["Index"] = Index,
				["Price"] = v["Price"],
				["Category"] = v["Category"],
				["Discount"] = v["Discount"],
				["Image"] = ItemIndex(Index),
				["Name"] = ItemName(Index)
			}
		end
	end

	for Mode,_ in pairs(RoleItens) do
		for Index,v in pairs(RoleItens[Mode]) do
			if not Rolepass[Mode] then
				Rolepass[Mode] = {}
			end

			local Number = #Rolepass[Mode] + 1
			Rolepass[Mode][Number] = {
				["Id"] = Number,
				["Amount"] = v["Amount"],
				["Name"] = ItemName(v["Item"]),
				["Image"] = ItemIndex(v["Item"]),
				["Description"] = ItemDescription(v["Item"])
			}
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.StoreList()
	return Store
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.StoreBuy(Item,Amount)
	local source = source
	local Amount = parseInt(Amount,true)
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and ShopItens[Item] then
		Active[Passport] = true

		if Amount > 1 and ItemUnique(Item) then
			Amount = 1
		end

		local Price = ShopItens[Item]["Price"]
		if ShopItens[Item]["Discount"] < 1.0 then
			Price = Price * ShopItens[Item]["Discount"]
		end

		if not vRP.MaxItens(Passport,Item,Amount) and vRP.PaymentGems(Passport,Price * Amount) then
			exports["discord"]:Embed("Pause","**[TIPO]:** Comprou\n**[PASSAPORTE]:** "..Passport.."\n**[ITEM]:** "..Dotted(Amount).."x "..Item.."\n**[DIAMANTES]:** "..Dotted(Price * Amount).."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))
			TriggerClientEvent("pause:Notify",source,"Sucesso","Compra concluída.","verde")
			vRP.GenerateItem(Passport,Item,Amount,false)

			table.insert(Shopping,1,{
				["Price"] = Price,
				["Amount"] = Amount,
				["Image"] = ItemIndex(Item),
				["Name"] = vRP.LowerName(Passport)
			})

			Active[Passport] = nil

			return Amount
		end
	end

	Active[Passport] = nil

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREMIUMBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.PremiumBuy(Hierarchy,Selectable)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and Premium[Hierarchy] then
		Active[Passport] = true

		if vRP.UserPremium(Passport) and vRP.LevelPremium(source) ~= Hierarchy then
			TriggerClientEvent("pause:Notify",source,"Atenção","Você já possui um premium ativo.","vermelho")
			Active[Passport] = nil

			return false
		end

		local Price = Premium[Hierarchy]["Price"]
		if Premium[Hierarchy]["Discount"] < 1.0 then
			Price = Price * Premium[Hierarchy]["Discount"]
		end

		if vRP.PaymentGems(Passport,Price) then
			TriggerClientEvent("pause:Notify",source,"Sucesso","Compra concluída.","verde")
			Active[Passport] = nil

			if not vRP.UserPremium(Passport) then
				vRP.SetPremium(source,Passport,Hierarchy,30)
			else
				vRP.UpgradePremium(source,Passport,Hierarchy,30)
			end

			return true
		end

		Active[Passport] = nil
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Rolepass()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult,Initial = vRP.Rolepass(Passport)
		if Consult then
			return {
				["Free"] = Rolepass["Free"],
				["Premium"] = Rolepass["Premium"],
				["Points"] = Consult["Points"],
				["CurrentFree"] = Consult["Free"],
				["CurrentPremium"] = Consult["Premium"],
				["Finish"] = Initial + 2592000 - os.time(),
				["Active"] = Consult["Active"],
				["Price"] = RolepassPrice,
				["Necessary"] = RolepassPoints
			}
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSRESCUE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.RolepassRescue(Mode,Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and RoleItens[Mode] and RoleItens[Mode][Number] then
		Active[Passport] = true

		local Consult = vRP.Rolepass(Passport)
		if Consult then
			if Mode == "Premium" and (not Consult["Active"] or Consult["Active"] < os.time()) then
				Active[Passport] = nil

				return false
			end

			local Item = RoleItens[Mode][Number]["Item"]
			local Amount = RoleItens[Mode][Number]["Amount"]
			if vRP.CheckWeight(Passport,Item,Amount) and (Consult[Mode] + 1) == Number and vRP.RolepassPayment(Passport,RolepassPoints,Mode) then
				TriggerClientEvent("pause:Notify",source,"Sucesso","Resgate concluído.","verde")
				vRP.GenerateItem(Passport,Item,Amount)
				Active[Passport] = nil

				return true
			end
		end

		Active[Passport] = nil
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.RolepassBuy()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult,Initial = vRP.Rolepass(Passport)
		if Consult and (Initial + 2592000) >= os.time() and not Consult["Active"] and vRP.PaymentGems(Passport,RolepassPrice) then
			TriggerClientEvent("pause:Notify",source,"Sucesso","Compra concluída.","verde")
			vRP.RolepassBuy(Passport)

			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBOX
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.OpenBox(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and not PlayerBox[Passport] then
		local Price = Boxes[Number]["Price"]
		if Boxes[Number]["Discount"] < 1.0 then
			Price = Price * Boxes[Number]["Discount"]
		end

		if vRP.PaymentGems(Passport,Price) then
			exports["discord"]:Embed("Boxes","**[TIPO]:** Comprou\n**[PASSAPORTE]:** "..Passport.."\n**[CAIXA]:** "..Boxes[Number]["Name"].."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))
			PlayerBox[Passport] = RandPercentage(Boxes[Number]["Rewards"])
			Active[Passport] = true

			SetTimeout(6000,function()
				local Item = PlayerBox[Passport]["Id"]

				vRP.GenerateItem(Passport,Boxes[Number]["Rewards"][Item]["Item"],Boxes[Number]["Rewards"][Item]["Amount"])
				PlayerBox[Passport] = nil
				Active[Passport] = nil
			end)

			return PlayerBox[Passport]["Id"]
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Marketplace()
	local Return = {}

	for Index,v in pairs(Marketplace) do
		if v["timer"] > os.time() then
			Return[#Return + 1] = {
				["Id"] = Index,
				["Key"] = v["key"],
				["Name"] = ItemName(v["item"]),
				["Price"] = v["price"],
				["Amount"] = v["quantity"]
			}
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceInventory(Mode)
	local Return = {}
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Mode then
		if Mode == "Create" then
			local Inv = vRP.Inventory(Passport)
			for Index,v in pairs(Inv) do
				if not BlockMarket(v["item"]) and not vRP.CheckDamaged(v["item"]) then
					Return[#Return + 1] = {
						["Item"] = v["item"],
						["Key"] = ItemIndex(v["item"]),
						["Name"] = ItemName(v["item"]),
						["Amount"] = v["amount"]
					}
				end
			end
		elseif Mode == "Announce" then
			for Index,v in pairs(Marketplace) do
				if Passport == v["passport"] then
					Return[#Return + 1] = {
						["Id"] = Index,
						["Key"] = v["key"],
						["Name"] = ItemName(v["item"]),
						["Price"] = v["price"],
						["Amount"] = v["quantity"]
					}
				end
			end
		end
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEANNOUNCE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceAnnounce(Table)
	local source = source
	local Item = Table["Item"]
	local Price = Table["Price"]
	local Quantity = Table["Amount"]
	local Passport = vRP.Passport(source)
	if Passport and Item and Price and Quantity and not BlockMarket(Item) and vRP.PaymentFull(Passport,250) and vRP.TakeItem(Passport,Item,Quantity) then
		repeat
			Selected = GenerateString("DDLLDDLL")
		until Selected and not Marketplace[Selected]

		Marketplace[Selected] = {
			["key"] = ItemIndex(Item),
			["item"] = Item,
			["price"] = Price,
			["quantity"] = Quantity,
			["passport"] = Passport,
			["timer"] = os.time() + 259200
		}

		exports["discord"]:Embed("Marketplace","**[TIPO]:** Anúncio\n**[PASSAPORTE]:** "..Passport.."\n**[ITEM]:** "..Dotted(Quantity).."x "..Item.."\n**[POR]:** $"..Dotted(Price).."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACECANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceCancel(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Marketplace[Selected] and Marketplace[Selected]["passport"] and Marketplace[Selected]["passport"] == Passport and vRP.GiveItem(Passport,Marketplace[Selected]["item"],Marketplace[Selected]["quantity"]) then
		exports["discord"]:Embed("Marketplace","**[TIPO]:** Cancelou\n**[PASSAPORTE]:** "..Passport.."\n**[ITEM]:** "..Dotted(Marketplace[Selected]["quantity"]).."x "..Marketplace[Selected]["item"].."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))
		Marketplace[Selected] = nil

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceBuy(Selected)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Marketplace[Selected] then
		if vRP.MaxItens(Passport,Marketplace[Selected]["item"],Marketplace[Selected]["quantity"]) then
			TriggerClientEvent("pause:Notify",source,"Atenção","Limite atingido.","vermelho")

			return false
		end

		if vRP.PaymentFull(Passport,Marketplace[Selected]["price"]) and vRP.GiveItem(Passport,Marketplace[Selected]["item"],Marketplace[Selected]["quantity"]) then
			exports["discord"]:Embed("Marketplace","**[TIPO]:** Comprou\n**[PASSAPORTE]:** "..Passport.."\n**[VENDEDOR]:** "..Marketplace[Selected]["passport"].."\n**[ITEM]:** "..Dotted(Marketplace[Selected]["quantity"]).."x "..Marketplace[Selected]["item"].."\n**[POR]:** $"..Dotted(Marketplace[Selected]["price"]).."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))
			TriggerClientEvent("pause:Notify",source,"Sucesso","Compra concluída.","verde")
			vRP.GiveBank(Marketplace[Selected]["passport"],Marketplace[Selected]["price"])
			Marketplace[Selected] = nil

			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if PlayerBox[Passport] then
		PlayerBox[Passport] = nil
	end

	if Active[Passport] then
		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaveServer",function(Silenced)
	vRP.Query("entitydata/SetData",{ Name = "Marketplace", Information = json.encode(Marketplace) })

	if not Silenced then
		print("O resource ^2Pause^7 salvou os dados.")
	end
end)
if Config.Framework ~= "standalone" then
    return
end

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
Tunnel.bindInterface("lb-phone",Creative)

function Creative.CheckPhone()
    local source = source
    local Passport = vRP.Passport(source)
    if Passport and not Player(source)["state"]["Cancel"] and not Player(source)["state"]["Buttons"] and vRP.ConsultItem(Passport,Config.Item.Name) then
        return true
    end

    return false
end

--- @param source number
--- @return string | nil
function GetIdentifier(source)
    return vRP.Passport(source)
end

---Check if a player has a phone with a specific number
---@param source any
---@param number string
---@return boolean
function HasPhoneItem(source)
    return true
end

---Get a player's character name
---@param source any
---@return string # Firstname
---@return string # Lastname
function GetCharacterName(source)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        return vRP.FullName(Passport)
    end

    return "Individuo Indigente"
end

---Get an array of player sources with a specific job
---@param job string
---@return table # Player sources
function GetEmployees(job)
    local Services = {}
    local Permissions = vRP.NumPermission(job)
    for Passport,Sources in pairs(Permissions) do
        Services[#Services + 1] = Sources
    end

    return Services
end

---Get the bank balance of a player
---@param source any
---@return integer
function GetBalance(source)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        return vRP.GetBank(Passport)
    end

    return 0
end

---Add money to a player's bank account
---@param source any
---@param amount integer
---@return boolean # Success
function AddMoney(source, amount)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        vRP.GiveBank(Passport,amount)

        return true
    end

    return false
end

---Remove money from a player's bank account
---@param source any
---@param amount integer
---@return boolean # Success
function RemoveMoney(source, amount)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport and vRP.PaymentBank(Passport,amount) then
        return true
    end

    return false
end

---Send a message to a player
---@param source number
---@param message string
function Notify(source, message)
    TriggerClientEvent("Notify",source,"Telefone",message,"amarelo",5000)
end

-- GARAGE APP

---@param source number
---@return VehicleData[] vehicles An array of vehicles that the player owns
function GetPlayerVehicles(source)
    return {}
end

---Get a specific vehicle
---@param source number
---@param plate string
---@return table? vehicleData
function GetVehicle(source, plate)
end

function IsAdmin(source)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport and vRP.HasPermission(Passport,"Admin") then
        return true
    end

    return false
end

-- COMPANIES APP
function GetJob(source)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        return vRP.GetUserType(Passport,"Work")
    end

    return "Desempregado"
end

function RefreshCompanies()
    for i = 1, #Config.Companies.Services do
        local jobData = Config.Companies.Services[i]

        jobData.open = vRP.AmountService(jobData.job) > 0
    end
end
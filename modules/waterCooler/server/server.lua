local Config = require 'modules.waterCooler.config.config'

RegisterNetEvent('mri_Qwaterbottle:server:FillWaterBottle', function(skillCheckSuccess)
    local src = source
    local playerHasItem = exports.ox_inventory:Search(src, "slots", Config.items.empty_bottle)

    if playerHasItem and skillCheckSuccess then
        local itemRemoved = exports.ox_inventory:RemoveItem(src, Config.items.empty_bottle, 1)
        if itemRemoved then
            exports.ox_inventory:AddItem(src, Config.items.filled_bottle, 1)
            TriggerClientEvent('ox_lib:notify', src, { type = 'success', text = 'Garrafa de Água reabastecida!' })
        else
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', text = 'Você não possui uma garrafa vazia' })
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', text = 'Falha ao reabastecer a garrafa de Água' })
    end
end)

RegisterNetEvent('mri_Qwaterbottle:server:PlayerTooFar', function()
    local src = source
    if Config.dropplayer.status then
        DropPlayer(src, Config.dropplayer.dropreason)
    end
end)


local QBCore = exports['qb-core']:GetCoreObject()
local hydration = Config.hydrationValue or 10
local excessive_drink = Config.excessiveDrinkCount or 3
local Players = {}

-- get player data
local function localGetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

-- Function to kill player
local function KillPlayer(src)
    local player = localGetPlayer(src)
    -- kill player logic here
end

local function notify(src, message, messageType)
    TriggerClientEvent('QBCore:Notify', src, message, messageType)
end

-- Function to handle excessive drinking
local function handleExcessiveDrinking(src)
    local currentTime = os.time()
    if not Players[src] then
        Players[src] = { count = 1, lastDrinkTime = currentTime }
    else
        Players[src].count = Players[src].count + 1
        Players[src].lastDrinkTime = currentTime
    end

    local drinksInPastMinute = 0
    for _, playerData in pairs(Players) do
        if currentTime - playerData.lastDrinkTime <= 60 then
            drinksInPastMinute = drinksInPastMinute + playerData.count
        end
    end

    if drinksInPastMinute > excessive_drink then
        KillPlayer(src)
    else
        notify(src, "Você está bebendo água demais!", 'error')
    end
end

local function updateClientHUD(src, hunger, thirst)
    TriggerClientEvent('hud:client:UpdateNeeds', src, hunger, thirst)
end

-- set player's thirst metadata
local function setThirst(src, player, newThirst)
    player.Functions.SetMetaData('thirst', newThirst)
    notify(src, "Você se sente mais hidratado...", 'success')
end

-- handle drinking
local function drink(src)
    local player = localGetPlayer(src)
    if not player then return end

    local currentThirst = player.PlayerData.metadata['thirst']

    if currentThirst < 100 then
        local newThirst = currentThirst + hydration
        if newThirst > 100 then newThirst = 100 end

        setThirst(src, player, newThirst)
        updateClientHUD(src, player.PlayerData.metadata.hunger, newThirst)
    elseif currentThirst >= 100 then
        handleExcessiveDrinking(src)
    end
end

-- Register drink event
RegisterNetEvent('mri_Qwaterbottle:server:drink', function()
    local src = source
    drink(src)
end)
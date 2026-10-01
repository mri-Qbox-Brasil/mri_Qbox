local function Config() return Mri.cfg('watercooler') end

RegisterNetEvent('mri_Qwaterbottle:server:FillWaterBottle', function(skillCheckSuccess)
    if not Mri.enabled('watercooler') then return end
    local src = source
    local cfg = Config()
    local playerHasItem = exports.ox_inventory:Search(src, "slots", cfg.emptyBottle)

    if playerHasItem and skillCheckSuccess then
        local itemRemoved = exports.ox_inventory:RemoveItem(src, cfg.emptyBottle, 1)
        if itemRemoved then
            exports.ox_inventory:AddItem(src, cfg.filledBottle, 1)
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
    local cfg = Config()
    if cfg.dropTooFar then
        DropPlayer(src, cfg.dropReason)
    end
end)


local QBCore = exports['qb-core']:GetCoreObject()
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
    local playerData = Players[src]

    if not playerData or currentTime - playerData.lastDrinkTime > 60 then
        Players[src] = { count = 1, lastDrinkTime = currentTime }
    else
        playerData.count = playerData.count + 1
        playerData.lastDrinkTime = currentTime
    end

    if Players[src].count > (Config().excessiveDrinkCount or 3) then
        KillPlayer(src)
    else
        notify(src, "Você está bebendo água demais!", 'error')
    end
end

AddEventHandler('playerDropped', function()
    Players[source] = nil
end)

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
        local newThirst = currentThirst + (Config().hydration or 10)
        if newThirst > 100 then newThirst = 100 end

        setThirst(src, player, newThirst)
        updateClientHUD(src, player.PlayerData.metadata.hunger, newThirst)
    elseif currentThirst >= 100 then
        handleExcessiveDrinking(src)
    end
end

-- Register drink event
RegisterNetEvent('mri_Qwaterbottle:server:drink', function()
    if not Mri.enabled('watercooler') then return end
    local src = source
    drink(src)
end)
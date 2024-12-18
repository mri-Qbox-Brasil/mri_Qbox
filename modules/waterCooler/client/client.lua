local Config = require 'modules.waterCooler.config.config'
local MAX_DISTANCE = Config.distances.max_distance
local TARGET_DISTANCE = Config.distances.target_distance

local function isPlayerWithinRange(target)
    if not DoesEntityExist(target) then
        return false
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(target)
    local distance = #(playerCoords - targetCoords)
    return distance <= MAX_DISTANCE
end

local isDrinking = false

local function setDrinkingFlag(v)
    isDrinking = v
end

local function drink(entity)
    if isDrinking then return end
    TriggerEvent('mri_Qwaterbottle:client:emote', entity, setDrinkingFlag)
end

AddEventHandler('mri_Qwaterbottle:client:emote', function(entity, setDrinkingFlag)
    setDrinkingFlag(true)

    local animDict = 'amb@world_human_drinking@coffee@male@idle_a'
    local animName = 'idle_a'
    local propModel = 'prop_plastic_cup_02'

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end

    local playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local prop = CreateObject(GetHashKey(propModel), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(prop, playerPed, 71, 0.14566236852204, 0.033520647178898, -0.028332872096562, -91.369023488984, -47.715911678213, -34.594450849604, true, true, false, true, 1, true)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    local completed = lib.progressCircle({
        label = 'Bebendo água...',
        duration = 5000,
        position = 'middle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
        },
    })

    if completed then
        TriggerServerEvent('mri_Qwaterbottle:server:drink', GetEntityCoords(entity))
    else
        lib.notify({
            title = 'Negado',
            description = 'Você desperdiçou essa água...',
            type = 'error'
        })
    end

    ClearPedTasks(playerPed)
    DeleteObject(prop)
    SetModelAsNoLongerNeeded(propModel)
    RemoveAnimDict(animDict)
    setDrinkingFlag(false)
end)

for _, model in ipairs(Config.targetmodels) do
    exports.ox_target:addModel(model, {
        {
            icon = 'fas fa-tint',
            label = 'Beber Água',
            canInteract = function(entity, distance, coords, name, bone)
                local thirst = QBX.PlayerData.metadata["thirst"]
                return thirst < 100
            end,
            onSelect = function(data)
                local targetEntity = data.entity or nil
                drink(targetEntity)
            end,
            distance = TARGET_DISTANCE
        },
        {
            icon = 'fa-solid fa-bottle-water',
            label = 'Encher garrafa',
            canInteract = function(entity, distance, coords, name, bone)
                local count = exports.ox_inventory:Search('count', 'empty_water_bottle')
                return count > 0
            end,
            onSelect = function(data)
                local targetEntity = data.entity or nil
                TriggerEvent('mri_Qwaterbottle:client:FillWaterBottle', targetEntity)
            end,
            distance = TARGET_DISTANCE
        },
    })
end

RegisterNetEvent('mri_Qwaterbottle:client:FillWaterBottle', function(targetEntity)
    if targetEntity and isPlayerWithinRange(targetEntity) then
        TriggerEvent('animations:client:EmoteCommandStart', { "mechanic4" })
        local completed = lib.progressCircle({
            duration = Config.progressSettings.duration,
            label = 'Enchendo garrafa...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
        })

        if completed then
            TriggerServerEvent('mri_Qwaterbottle:server:FillWaterBottle', true)
            exports.scully_emotemenu:cancelEmote()
        else
            exports.scully_emotemenu:cancelEmote()
        end
    else
        if Config.dropplayer.status then
            TriggerServerEvent('mri_Qwaterbottle:server:PlayerTooFar')
        else
            lib.notify({
                title = 'Negado',
                description = 'O jogador está muito longe.',
                type = 'error'
            })
        end
    end
end)

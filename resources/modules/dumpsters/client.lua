-- Lixeiras pelo olhinho: esconder dentro e vasculhar (abre o inventário da lixeira).
local inside = false
local oldcoords = nil
local Enter, Exit

local function setup()
    local cfg = Mri.cfg('dumpsters')
    exports.ox_target:addModel(cfg.hideModels, {
        name = 'mri_Qbox:dumpster_hide',
        event = 'mri_Qhideintrash:enter',
        icon = "fa-sharp fa-solid fa-eye-low-vision",
        label ="Esconder",
        distance = 1
    })
    exports.ox_target:addModel(cfg.searchModels, {
        name = 'mri_Qbox:dumpster_search',
        icon = 'fas fa-dumpster',
        label = "Vasculhar",
        onSelect = function(data)
            local entity = data.entity
            local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
            if not netId then
                local coords = GetEntityCoords(entity)
                entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
                netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
            end
            if netId then
                local completed = lib.progressCircle({
                    label = 'Vasculhando...',
                    duration = 2000,
                    position = 'middle',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                    },
                    anim = {
                        scenario = 'PROP_HUMAN_PARKING_METER',
                    }
                })
                if not completed then return end
                exports.ox_inventory:openInventory('dumpster', 'dumpster'..netId)
            end
        end,
        distance = 2
	})
end

-- liga, desliga e troca de modelos na hora (o stop tira das listas que estavam valendo)
local active
Mri.lifecycle('dumpsters', function(cfg)
    active = cfg
    setup()
end, function()
    if not active then return end
    exports.ox_target:removeModel(active.hideModels, 'mri_Qbox:dumpster_hide')
    exports.ox_target:removeModel(active.searchModels, 'mri_Qbox:dumpster_search')
    active = nil
end)

RegisterNetEvent('mri_Qhideintrash:enter',function()
    Enter()
end)

RegisterNetEvent('mri_Qhideintrash:exit',function()
    Exit()
end)

local function listenForKeyPressToLeave()
    if IsControlJustReleased(0, 38) then
        lib.hideTextUI()
        Exit()
    end
end

function Enter()
    if inside then return end
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(PlayerPedId())
    for _, model in ipairs(Mri.cfg('dumpsters').searchModels) do
        local objectId = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 1.0, model, false, false, false)
        if DoesEntityExist(objectId) then
            inside = true
            local objectcoords = GetEntityCoords(objectId)
            oldcoords = GetEntityCoords(ped)
            SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z, 0.0, 0.0, 0.0)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false)
            lib.zones.sphere({
                coords = vector3(objectcoords.x, objectcoords.y, objectcoords.z),
                radius = 2.75,
                onEnter = function()
                    lib.showTextUI('[E] Sair ')
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = listenForKeyPressToLeave,
            })
            return
        end
    end
end

function Exit()
    local ped = PlayerPedId()
    inside = false
    SetEntityCoords(ped,oldcoords.x,oldcoords.y,oldcoords.z - 1)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
end
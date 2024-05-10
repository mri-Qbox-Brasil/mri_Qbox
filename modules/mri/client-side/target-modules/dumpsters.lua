local inside = false
local oldcoords = nil

CreateThread(function()
    App()
end)

function App()
    exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
        event = 'mri_Qhideintrash:enter',
        icon = "fa-sharp fa-solid fa-eye-low-vision",
        label ="Esconder",
        distance = 1
    })
    exports.ox_target:addModel(cfg.dumpsters.TrashCans.Model, {
        icon = 'fas fa-dumpster',
        label = "Abrir",
        onSelect = function(data)
            local entity = data.entity
            local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
            if not netId then
                local coords = GetEntityCoords(entity)
                entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.1, GetEntityModel(entity), true, true, true)
                netId = entity ~= 0 and NetworkGetNetworkIdFromEntity(entity)
            end
            if netId then
                exports.ox_inventory:openInventory('dumpster', 'dumpster'..netId)
            end
        end,
        distance = 2
	})
end

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
    for k,v in pairs(cfg.dumpsters.TrashCans.Model) do
        local objectId = GetClosestObjectOfType(pedCoords, 1.0, cfg.dumpsters.TrashCans.Model[k], false)
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
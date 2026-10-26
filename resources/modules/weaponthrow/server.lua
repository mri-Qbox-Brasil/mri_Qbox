-- A thrown weapon becomes a server object; its item (ammo and attachments included) waits there until someone picks it up.
local ox_inventory = exports.ox_inventory

local MAX_SPEED = 26.0
local MAX_HAND_DISTANCE = 3.0
local MAX_PICKUP_DISTANCE = 3.0

---@type table<number, { name: string, label: string, metadata: table, model: number }>
local ThrownWeapons = {}

RegisterNetEvent('mri_Qbox:weaponthrow:release', function(model, coords, velocity)
    local src = source
    if not Mri.enabled('weaponthrow') or math.type(model) ~= 'integer' then return end
    if type(coords) ~= 'vector3' or type(velocity) ~= 'vector3' or #velocity > MAX_SPEED then return end

    local ped = GetPlayerPed(src)
    if ped == 0 or GetVehiclePedIsIn(ped, false) ~= 0 then return end
    if #(GetEntityCoords(ped) - coords) > MAX_HAND_DISTANCE then return end

    local weapon = ox_inventory:GetCurrentWeapon(src)
    if not weapon then return end
    if not ox_inventory:RemoveItem(src, weapon.name, 1, nil, weapon.slot) then return end

    local object = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, true, false)
    if object == 0 then
        ox_inventory:AddItem(src, weapon.name, 1, weapon.metadata)
        return
    end

    -- the default orphan mode deletes it once nobody is around, and the weapon with it
    SetEntityOrphanMode(object, 2)
    SetEntityHeading(object, GetEntityHeading(ped) + 90.0)
    SetEntityVelocity(object, velocity.x, velocity.y, velocity.z)
    ThrownWeapons[object] = { name = weapon.name, label = weapon.label, metadata = weapon.metadata, model = model }
    Entity(object).state:set('mriThrownWeapon', true, true)
end)

RegisterNetEvent('mri_Qbox:weaponthrow:pickup', function(netId)
    local src = source
    if math.type(netId) ~= 'integer' then return end
    local object = NetworkGetEntityFromNetworkId(netId)
    local thrown = ThrownWeapons[object]
    if not thrown then return end

    local ped = GetPlayerPed(src)
    if ped == 0 or #(GetEntityCoords(ped) - GetEntityCoords(object)) > MAX_PICKUP_DISTANCE then return end

    if not ox_inventory:CanCarryItem(src, thrown.name, 1, thrown.metadata) then
        lib.notify(src, { type = 'error', description = locale('weaponthrow.no_space') })
        return
    end

    ThrownWeapons[object] = nil
    DeleteEntity(object)
    ox_inventory:AddItem(src, thrown.name, 1, thrown.metadata)
end)

-- deleted by something else (admin cleanup): the weapon is gone with it
AddEventHandler('entityRemoved', function(entity)
    ThrownWeapons[entity] = nil
end)

-- weapons still on the ground stay as an ox_inventory drop
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for object, thrown in pairs(ThrownWeapons) do
        if DoesEntityExist(object) then
            ox_inventory:CustomDrop(thrown.label, { { thrown.name, 1, thrown.metadata } }, GetEntityCoords(object), 1, nil, nil, thrown.model)
            DeleteEntity(object)
        end
    end
    ThrownWeapons = {}
end)

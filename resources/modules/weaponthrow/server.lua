-- A thrown weapon becomes a server object; its item (ammo and attachments included) waits there until someone picks it up.
local ox_inventory = exports.ox_inventory

local MAX_HAND_DISTANCE = 3.0
local MAX_PICKUP_DISTANCE = 3.0
local STRENGTH = { weak = 0.8, normal = 1.0, strong = 1.2 }

---@type table<number, { name: string, label: string, metadata: table, model: number }>
local ThrownWeapons = {}

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Launch from the item weight (grams, ammo and attachments included): lighter flies faster and flatter, heavier lobs.
---@return vector3 velocity, vector3 angular
local function trajectory(weight, aim, strength)
    local kg = math.max((weight or 1000) / 1000, 0.1)
    -- ~24 m/s for a knife, ~20 a pistol, ~14 a rifle, ~6 a minigun
    local speed = clamp(26.0 * (0.5 / kg) ^ 0.35, 6.0, 24.0) * strength
    local loft = math.rad(8.0 + 14.0 * clamp((kg - 0.3) / 10.0, 0.0, 1.0))

    local flat = math.sqrt(aim.x * aim.x + aim.y * aim.y)
    if flat < 0.01 then return aim * speed, vec3(0.0, 0.0, 0.0) end
    local pitch = math.min(math.atan(aim.z, flat) + loft, math.rad(75.0))
    local ux, uy = aim.x / flat, aim.y / flat
    local dir = vec3(ux * math.cos(pitch), uy * math.cos(pitch), math.sin(pitch))

    -- end over end, top forward; light blades whirl, heavy guns barely turn
    local spin = clamp(16.0 / math.sqrt(kg), 3.0, 20.0) * (0.85 + math.random() * 0.3)
    return dir * speed, vec3(-uy, ux, 0.0) * spin
end

RegisterNetEvent('mri_Qbox:weaponthrow:release', function(model, coords, aim)
    local src = source
    if not Mri.enabled('weaponthrow') or math.type(model) ~= 'integer' or type(coords) ~= 'vector3' then return end
    if aim and (type(aim) ~= 'vector3' or #aim < 0.5) then return end

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
    ThrownWeapons[object] = { name = weapon.name, label = weapon.label, metadata = weapon.metadata, model = model }
    Entity(object).state:set('mriThrownWeapon', true, true)

    if not aim then
        SetEntityHeading(object, GetEntityHeading(ped) + 90.0)
        return
    end

    local strength = STRENGTH[Mri.cfg('weaponthrow').strength] or STRENGTH.normal
    local velocity, angular = trajectory(weapon.weight, aim / #aim, strength)
    -- weapon models point along +X: turn the barrel or blade toward the flight
    SetEntityHeading(object, math.deg(math.atan(-velocity.x, velocity.y)) + 90.0)
    -- running throws carry the body's momentum
    velocity = velocity + GetEntityVelocity(ped)
    SetEntityVelocity(object, velocity.x, velocity.y, velocity.z)
    TriggerClientEvent('mri_Qbox:weaponthrow:spin', src, NetworkGetNetworkIdFromEntity(object), angular)
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

-- Throw the weapon in hand (or drop it on death): the server takes the item and spawns the object; pickup is by target.
local GROUPS = {
    [`GROUP_MELEE`] = 'melee',
    [`GROUP_PISTOL`] = 'pistols',
    [`GROUP_STUNGUN`] = 'pistols',
    [`GROUP_SMG`] = 'smgs',
    [`GROUP_SHOTGUN`] = 'shotguns',
    [`GROUP_RIFLE`] = 'rifles',
    [`GROUP_MG`] = 'machineGuns',
    [`GROUP_SNIPER`] = 'snipers',
    [`GROUP_HEAVY`] = 'heavy',
}
local THROW_SPEED = 25.0
local RIGHT_HAND = 57005

local throwing = false

local function throwable(weapon)
    local key = weapon and GROUPS[GetWeapontypeGroup(weapon)]
    return key ~= nil and Mri.cfg('weaponthrow')[key] == true
end

local function release(weapon, velocity)
    local coords = GetPedBoneCoords(cache.ped, RIGHT_HAND, 0.0, 0.0, 0.0)
    TriggerServerEvent('mri_Qbox:weaponthrow:release', GetWeapontypeModel(weapon), coords, velocity)
end

local function aimDirection()
    local rot = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    local flat = math.abs(math.cos(pitch))
    return vec3(-math.sin(yaw) * flat, math.cos(yaw) * flat, math.sin(pitch))
end

lib.addKeybind({
    name = 'mri_throwweapon',
    description = locale('weaponthrow.keybind'),
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_MIDDLE',
    onPressed = function()
        if throwing or not Mri.enabled('weaponthrow') or cache.vehicle or IsEntityDead(cache.ped) then return end
        if LocalPlayer.state.isDead or QBX.PlayerData.metadata.ishandcuffed then return end
        local weapon = cache.weapon
        if not throwable(weapon) then return end

        throwing = true
        lib.playAnim(cache.ped, 'melee@thrown@streamed_core', 'plyr_takedown_front', 8.0, -8.0, 1100, 48)
        -- the hand reaches the front of the swing here
        Wait(550)
        if cache.weapon == weapon and not IsEntityDead(cache.ped) then
            release(weapon, aimDirection() * THROW_SPEED)
        end
        throwing = false
    end,
})

-- the killing hit still has the weapon in hand; the ox_inventory disarms right after
AddEventHandler('gameEventTriggered', function(event, args)
    if event ~= 'CEventNetworkEntityDamage' or args[1] ~= cache.ped or not IsEntityDead(cache.ped) then return end
    local cfg = Mri.cfg('weaponthrow')
    local weapon = cache.weapon
    if not cfg.enabled or not cfg.dropOnDeath or not throwable(weapon) then return end
    release(weapon, vec3(0.0, 0.0, 0.0))
end)

-- registered even with the module off, so weapons already on the ground can still be picked up
exports.ox_target:addGlobalObject({{
    name = 'mri_Qbox:weaponthrow_pickup',
    icon = 'fa-solid fa-hand',
    label = locale('weaponthrow.pickup'),
    distance = 1.5,
    canInteract = function(entity)
        return NetworkGetEntityIsNetworked(entity) and Entity(entity).state.mriThrownWeapon == true
    end,
    onSelect = function(data)
        lib.playAnim(cache.ped, 'pickup_object', 'pickup_low', 8.0, -8.0, 1000, 0)
        Wait(800)
        TriggerServerEvent('mri_Qbox:weaponthrow:pickup', NetworkGetNetworkIdFromEntity(data.entity))
    end,
}})

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
local THROW_DICT, THROW_CLIP = 'melee@thrown@streamed_core', 'plyr_takedown_front'
-- the hand reaches the front of the swing here, at normal anim speed
local RELEASE_MS = 550
local AIM_DISTANCE = 80.0
local RIGHT_HAND = 57005

local throwing = false

local function throwable(weapon)
    local key = weapon and GROUPS[GetWeapontypeGroup(weapon)]
    return key ~= nil and Mri.cfg('weaponthrow')[key] == true
end

-- a knife whips out, a rifle swings slower, a minigun barely leaves the hands
local function swingSpeed()
    local current = exports.ox_inventory:getCurrentWeapon()
    local kg = (current and current.weight or 1000) / 1000
    return math.min(math.max(1.15 - 0.03 * kg, 0.75), 1.15)
end

-- from the hand to what the crosshair points at, so the third person camera offset doesn't skew the throw
local function aimDirection(hand)
    local cam = GetFinalRenderedCamCoord()
    local rot = GetFinalRenderedCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    local flat = math.abs(math.cos(pitch))
    local forward = vec3(-math.sin(yaw) * flat, math.cos(yaw) * flat, math.sin(pitch))
    local destination = cam + forward * AIM_DISTANCE
    local hit, _, coords = lib.raycast.fromCoords(cam, destination, 511, 4)
    local target = hit and coords or destination
    local dir = target - hand
    return #dir > 0.5 and dir / #dir or forward
end

local function release(weapon, thrown)
    local hand = GetPedBoneCoords(cache.ped, RIGHT_HAND, 0.0, 0.0, 0.0)
    TriggerServerEvent('mri_Qbox:weaponthrow:release', GetWeapontypeModel(weapon), hand, thrown and aimDirection(hand) or false)
end

local function throw()
    if throwing or not Mri.enabled('weaponthrow') or cache.vehicle or IsEntityDead(cache.ped) then return end
    if LocalPlayer.state.isDead or QBX.PlayerData.metadata.ishandcuffed then return end
    local weapon = cache.weapon
    if not throwable(weapon) then return end

    throwing = true
    local speed = swingSpeed()
    lib.playAnim(cache.ped, THROW_DICT, THROW_CLIP, 8.0, -8.0, math.floor(1100 / speed), 48)
    SetEntityAnimSpeed(cache.ped, THROW_DICT, THROW_CLIP, speed)
    Wait(math.floor(RELEASE_MS / speed))
    if cache.weapon == weapon and not IsEntityDead(cache.ped) then
        release(weapon, true)
        -- leaves the hand now instead of after the inventory round trip
        SetPedCurrentWeaponVisible(cache.ped, false, true, true, true)
        SetTimeout(1500, function()
            if cache.weapon == weapon then SetPedCurrentWeaponVisible(cache.ped, true, true, true, true) end
        end)
    end
    throwing = false
end

local KEYS = {
    mouse_middle = { 'MOUSE_BUTTON', 'MOUSE_MIDDLE' },
    mouse_back = { 'MOUSE_BUTTON', 'MOUSE_EXTRABTN1' },
    mouse_forward = { 'MOUSE_BUTTON', 'MOUSE_EXTRABTN2' },
    h = { 'keyboard', 'H' },
    j = { 'keyboard', 'J' },
    k = { 'keyboard', 'K' },
    y = { 'keyboard', 'Y' },
}

local function currentKey()
    local key = Mri.cfg('weaponthrow').key
    return KEYS[key] and key or 'mouse_middle'
end

-- one mapping per panel key: FiveM only applies a default to a mapping the player never had, so a new name reaches everyone
local registered = {}
Mri.lifecycle('weaponthrow', function()
    local key = currentKey()
    if registered[key] then return end
    registered[key] = true
    lib.addKeybind({
        name = 'mri_throwweapon_' .. key,
        description = locale('weaponthrow.keybind'),
        defaultMapper = KEYS[key][1],
        defaultKey = KEYS[key][2],
        onPressed = function()
            if currentKey() == key then throw() end
        end,
    })
end, function() end)

-- the server object belongs to the closest player (the thrower); spin is client side only
RegisterNetEvent('mri_Qbox:weaponthrow:spin', function(netId, angular)
    local deadline = GetGameTimer() + 1000
    while GetGameTimer() < deadline do
        if NetworkDoesNetworkIdExist(netId) then
            local object = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(object) and NetworkHasControlOfEntity(object) then
                SetEntityAngularVelocity(object, angular.x, angular.y, angular.z)
                return
            end
        end
        Wait(0)
    end
end)

-- the killing hit still has the weapon in hand; the ox_inventory disarms right after
AddEventHandler('gameEventTriggered', function(event, args)
    if event ~= 'CEventNetworkEntityDamage' or args[1] ~= cache.ped or not IsEntityDead(cache.ped) then return end
    local cfg = Mri.cfg('weaponthrow')
    local weapon = cache.weapon
    if not cfg.enabled or not cfg.dropOnDeath or not throwable(weapon) then return end
    release(weapon, false)
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

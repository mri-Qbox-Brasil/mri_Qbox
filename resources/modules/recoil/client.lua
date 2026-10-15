-- The recoil thread only exists while a weapon is in hand (cache.weapon).

local GROUPS = {
    [`GROUP_RIFLE`] = 'RIFLE',
    [`GROUP_PISTOL`] = 'PISTOL',
    [`GROUP_SMG`] = 'SMG',
    [`GROUP_MG`] = 'LMG',
    [`GROUP_SNIPER`] = 'SNIPER',
    [`GROUP_HEAVY`] = 'SNIPER',
    [`GROUP_SHOTGUN`] = 'SHOTGUN',
}
local FIRST_PERSON = 4

-- weapon names from the panel turned into hash sets, rebuilt only when the list changes
local lookups = {}
local function byHash(key, value, toSet)
    local entry = lookups[key]
    if not entry or entry.source ~= value then
        local map = {}
        if toSet then
            for _, name in ipairs(value or {}) do map[joaat(name)] = true end
        else
            for name, amount in pairs(value or {}) do map[joaat(name)] = tonumber(amount) end
        end
        entry = { source = value, map = map }
        lookups[key] = entry
    end
    return entry.map
end

-- how far the camera climbs for one shot
local function kick(cfg, weapon)
    local amount = byHash('weaponRecoil', cfg.weaponRecoil)[weapon] or 0.0
    local mult = cfg.recoilMultipliers or {}
    amount = amount * (mult[GROUPS[GetWeapontypeGroup(weapon)]] or 1.0)
    if IsPedDoingDriveby(cache.ped) then amount = amount * (mult.VEHICLE or 0.0) end
    return amount
end

local active
local shaking = false

local function shake(on, power)
    if on == shaking then return end
    shaking = on
    ShakeGameplayCam('DRUNK_SHAKE', on and power or 0.0)
end

local function run(weapon)
    local token = {}
    active = token
    CreateThread(function()
        -- climb left from the shots, done one step per frame like qbx_recoils
        local pending, strong = 0.0, false
        while active == token do
            local cfg = Mri.cfg('recoil')
            local exempt = byHash('whitelistedWeapons', cfg.whitelistedWeapons, true)[weapon]
            local ped = cache.ped
            local shooting = IsPedShooting(ped)

            if cfg.disableAimPunching and IsPedArmed(ped, 4) then
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
            end

            if cfg.verticalRecoil and shooting and not exempt then
                local amount = kick(cfg, weapon)
                if amount > 0 then
                    pending += amount
                    strong = amount > 0.1
                end
            end
            if pending > 0 then
                local pitch = GetGameplayCamRelativePitch()
                if GetFollowPedCamViewMode() ~= FIRST_PERSON then
                    SetGameplayCamRelativePitch(pitch + 0.1, 0.2)
                    pending -= 0.1
                elseif strong then
                    SetGameplayCamRelativePitch(pitch + 0.6, 1.2)
                    pending -= 0.6
                else
                    SetGameplayCamRelativePitch(pitch + 0.016, 0.333)
                    pending -= 0.1
                end
            end

            shake(cfg.drunkAiming and not exempt and (shooting or IsPlayerFreeAiming(cache.playerId)), cfg.drunkAimingPower or 0.2)
            Wait(0)
        end
        shake(false)
    end)
end

local function refresh(weapon)
    if weapon and Mri.enabled('recoil') then run(weapon) else active = nil end
end

local function applyHeadshots(ped)
    SetPedSuffersCriticalHits(ped, not (Mri.enabled('recoil') and Mri.cfg('recoil').disableHeadshots))
end

lib.onCache('weapon', refresh)
lib.onCache('ped', function(ped)
    if Mri.enabled('recoil') then applyHeadshots(ped) end
end)

Mri.lifecycle('recoil', function()
    refresh(cache.weapon)
    applyHeadshots(cache.ped)
end, function()
    active = nil
    SetPedSuffersCriticalHits(cache.ped, true)
end)

-- Recuo realista e mira bêbada (créditos https://github.com/nwvh/wx_recoil/ by .mur4i)

local GROUPS = {
    [970310034] = 'RIFLE',
    [416676503] = 'PISTOL',
    [-957766203] = 'SMG',
    [1159398588] = 'LMG',
    [3082541095] = 'SNIPER',
    [2725924767] = 'SNIPER',
    [860033945] = 'SHOTGUN',
}

-- Armas sem recuo: nomes no painel, comparados pelo hash da arma na mão.
-- (A versão antiga comparava com GetHashKey(_wep), variável inexistente, e a
-- lista nunca valia.)
local whitelistSource, whitelistSet
local function whitelisted(cfg, weaponHash)
    local list = cfg.whitelistedWeapons or {}
    if list ~= whitelistSource then
        whitelistSource, whitelistSet = list, {}
        for _, name in ipairs(list) do whitelistSet[joaat(name)] = true end
    end
    return whitelistSet[weaponHash] == true
end

-- recuo vertical, headshot e soco mirando
CreateThread(function()
    while true do
        local cfg = Mri.cfg('recoil')
        if not cfg.enabled or not cfg.verticalRecoil then
            Wait(1000)
        else
            Wait(0)
            local ped = PlayerPedId()
            if cfg.disableHeadshots then
                SetPedSuffersCriticalHits(ped, false)
            end
            if IsPedArmed(ped, 4) and cfg.disableAimPunching then
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
            end
            if IsPedShooting(ped) then
                local inVehicle = IsPedInAnyVehicle(ped, false)
                local movementSpeed = math.ceil(GetEntitySpeed(ped))

                Wait(1)
                local _, wep = GetCurrentPedWeapon(ped, false)
                local group = GROUPS[GetWeapontypeGroup(wep)]
                local pitch = GetGameplayCamRelativePitch()
                local recoil = math.random(10, 100 + movementSpeed) / 80
                local mult = cfg.recoilMultipliers or {}
                if inVehicle then
                    recoil = recoil * (mult.VEHICLE or 0.0)
                end
                if group then
                    recoil = recoil * (mult[group] or 0.0)
                end
                if not whitelisted(cfg, wep) then
                    SetGameplayCamRelativePitch(pitch + recoil, 0.8)
                end
            end
            if not IsPedArmed(ped, 4) then
                Wait(1000)
            end
        end
    end
end)

-- mira bêbada
local drunkAiming = false

local function stopDrunk()
    if drunkAiming then
        drunkAiming = false
        ShakeGameplayCam('DRUNK_SHAKE', 0.0)
    end
end

CreateThread(function()
    while true do
        local cfg = Mri.cfg('recoil')
        if not cfg.enabled or not cfg.drunkAiming then
            stopDrunk()
            Wait(1000)
        else
            Wait(0)
            local ped = PlayerPedId()
            if GetPedConfigFlag(ped, 78, true) then
                local _, weapon = GetCurrentPedWeapon(ped, false)
                if not whitelisted(cfg, weapon) then
                    if IsPlayerFreeAiming(PlayerId()) or IsPedShooting(ped) then
                        if not drunkAiming then
                            drunkAiming = true
                            ShakeGameplayCam('DRUNK_SHAKE', cfg.drunkAimingPower or 0.2)
                        end
                    else
                        stopDrunk()
                    end
                end
            else
                Wait(1000)
            end
        end
    end
end)

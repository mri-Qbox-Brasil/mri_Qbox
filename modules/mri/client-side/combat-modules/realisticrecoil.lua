-- créditos https://github.com/nwvh/wx_recoil/ by .mur4i
if cfg.realisticrecoil.verticalRecoil then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            if cfg.realisticrecoil.disableHeadshots then
                SetPedSuffersCriticalHits(ped, false)
            end
            if IsPedArmed(ped, 4) and cfg.realisticrecoil.disableAimPunching then
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
            end
            if IsPedShooting(ped) then      
                local Vehicled = IsPedInAnyVehicle(ped, false)
                local MovementSpeed = math.ceil(GetEntitySpeed(ped))

                Citizen.Wait(1)
                local _,wep = GetCurrentPedWeapon(ped,false)
                local group = GetWeapontypeGroup(wep)
                local p = GetGameplayCamRelativePitch()
                local recoil = math.random(10,100+MovementSpeed)/80
                local pistol = false
                local smg = false
                local rifle = false
                local shotgun = false
                local sniper = false
                local lmg = false
                if group == 970310034 then rifle = true
                elseif group == 416676503 then pistol = true
                elseif group == -957766203 then smg = true
                elseif group == 1159398588 then lmg = true
                elseif group == 3082541095 or group == 2725924767 then sniper = true
                elseif group == 860033945 then shotgun = true end
                if Vehicled then
                    recoil = recoil * cfg.realisticrecoil.recoilMultipliers["VEHICLE"]
                end
                if pistol then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["PISTOL"]
                elseif smg then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["SMG"]
                elseif rifle then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["RIFLE"]
                elseif shotgun then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["SHOTGUN"]
                elseif lmg then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["LMG"]
                elseif sniper then recoil = recoil * cfg.realisticrecoil.recoilMultipliers["SNIPER"]
                end
                local set = p+recoil
                if not cfg.realisticrecoil.whitelistedWeapons[GetHashKey(_wep)] then
                    SetGameplayCamRelativePitch(set,0.8)
                end
            end
            if not IsPedArmed(ped, 4) then
                Citizen.Wait(1000)
            end
        end
	end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)

        if cfg.realisticrecoil.hideCrosshair then
            HideHudComponentThisFrame(14)
        end
    end
end)

if cfg.realisticrecoil.drunkAiming then
    local drunkAiming = false

    function Drunk()
        local playerPed = PlayerPedId()
        local playerId = PlayerId()

        local _, weapon = GetCurrentPedWeapon(playerPed,false)
        if not cfg.realisticrecoil.whitelistedWeapons[weapon] then
            if IsPlayerFreeAiming(playerId) then
                DrunkRecoil()
            elseif IsPedShooting(playerPed) then
                DrunkRecoil()
            else
                if drunkAiming then
                    drunkAiming = false
                    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
                end
            end
        end
    end

    function DrunkRecoil()
        if not drunkAiming then
            drunkAiming = true
            ShakeGameplayCam("DRUNK_SHAKE", cfg.realisticrecoil.drunkAimingPower)
        end
    end

    function IsPedAiming(ped)
        return GetPedConfigFlag(ped, 78, true) == 1 and true or false
    end


    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local sleep = true
            if IsPedAiming(PlayerPedId()) then
            -- if IsPedArmed(PlayerPedId(), 6) then
                sleep = false
                Drunk()
            end
            if sleep then
                Wait(1000)
            end
        end
    end)
end


-- Roda solta em batida forte ("impact": perda de lataria ou de velocidade de
-- uma vez; "speed": colisão acima de uma velocidade).

local vehicleBodyHealthCache = {}
local vehicleCooldownCache = {}
local vehicleSpeedCache = {}
local setVehicleWheelsCanBreakOff = SetVehicleWheelsCanBreakOff

-- motos, off-road, barcos, helicópteros e aviões ficam fora
local EXCLUDED_CLASS = { [8] = true, [9] = true, [14] = true, [15] = true, [16] = true }

local function getRandomWheelIndex(vehicle)
    local numWheels = GetVehicleNumberOfWheels(vehicle)
    if numWheels == 2 then
        return (math.random(2) - 1) * 4
    end
    if numWheels == 4 then
        local index = math.random(4) - 1
        if index > 1 then index = index + 2 end
        return index
    end
    if numWheels == 6 then
        return math.random(6) - 1
    end
    return 0
end

CreateThread(function()
    while true do
        local waitLoop = 5000
        local cfg = Mri.cfg('wheelbreak')
        local playerPed = PlayerPedId()
        if cfg.enabled and IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) == playerPed and not EXCLUDED_CLASS[GetVehicleClass(vehicle)] then
                waitLoop = 100
                local gameTimer = GetGameTimer()
                local canBreakWheel = (vehicleCooldownCache[vehicle] or 0) <= gameTimer
                local hasCollision = HasEntityCollidedWithAnything(vehicle)
                local shouldBreakWheel = false
                local currentSpeed = GetEntitySpeed(vehicle) * 3.6
                local previousSpeed = vehicleSpeedCache[vehicle] or currentSpeed
                vehicleSpeedCache[vehicle] = currentSpeed

                if (cfg.mode or 'impact') == 'impact' then
                    local currentBodyHealth = GetVehicleBodyHealth(vehicle)
                    local previousBodyHealth = vehicleBodyHealthCache[vehicle] or currentBodyHealth
                    local bodyHealthLoss = previousBodyHealth - currentBodyHealth
                    local speedLoss = math.max(0.0, previousSpeed - currentSpeed)
                    vehicleBodyHealthCache[vehicle] = currentBodyHealth
                    local hasStrongImpact = bodyHealthLoss >= (cfg.impactDamage or 120.0) or speedLoss >= (cfg.impactDeltaSpeed or 35.0)
                    if canBreakWheel and hasStrongImpact and (hasCollision or previousSpeed >= (cfg.minImpactSpeed or 20.0)) then
                        shouldBreakWheel = true
                    end
                elseif hasCollision and canBreakWheel and math.ceil(currentSpeed) >= (cfg.speed or 85) then
                    shouldBreakWheel = true
                end

                if shouldBreakWheel then
                    local wheel = getRandomWheelIndex(vehicle)
                    if setVehicleWheelsCanBreakOff then
                        setVehicleWheelsCanBreakOff(vehicle, true)
                    end
                    BreakOffVehicleWheel(vehicle, wheel, true, false, true, false)
                    SetVehicleTyreBurst(vehicle, wheel, false, 1000.0)
                    vehicleCooldownCache[vehicle] = gameTimer + (cfg.cooldown or 5000)
                    waitLoop = cfg.cooldown or 5000
                end
            else
                vehicleBodyHealthCache[vehicle] = GetVehicleBodyHealth(vehicle)
                vehicleSpeedCache[vehicle] = GetEntitySpeed(vehicle) * 3.6
            end
        end
        Wait(waitLoop)
    end
end)

local wheelBreakSpeed = cfg.wheelbreak.speed
local wheelBreakMode = cfg.wheelbreak.mode or "impact"
local wheelBreakImpactDamage = cfg.wheelbreak.impactDamage or 120.0
local wheelBreakCooldown = cfg.wheelbreak.cooldown or 5000
local wheelBreakMinImpactSpeed = cfg.wheelbreak.minImpactSpeed or 20.0
local wheelBreakImpactDeltaSpeed = cfg.wheelbreak.impactDeltaSpeed or 35.0
local vehicleBodyHealthCache = {}
local vehicleCooldownCache = {}
local vehicleSpeedCache = {}
local setVehicleWheelsCanBreakOff = SetVehicleWheelsCanBreakOff

--[[ Vehicle classes:
0: Compacts   1: Sedans   2: SUVs   3: Coupes   4: Muscle
5: Sports Classics   6: Sports   7: Super   8: Motorcycles   9: Off-road
10: Industrial   11: Utility   12: Vans   13: Cycles   14: Boats
15: Helicopters   16: Planes   17: Service   18: Emergency   19: Military
20: Commercial   21: Trains ]]
local excludedClasses = {
    [8] = true,
    [9] = true,
    [14] = true,
    [15] = true,
    [16] = true
}

---@param class string Vehicle class
---@return boolean
local function isVehicleClassValid(class)
    return not excludedClasses[class]
end

local function getRandomWheelIndex(vehicle)
    local numWheels = GetVehicleNumberOfWheels(vehicle)
    if numWheels == 2 then
        return (math.random(2) - 1) * 4
    end
    if numWheels == 4 then
        local index = math.random(4) - 1
        if index > 1 then
            index = index + 2
        end
        return index
    end
    if numWheels == 6 then
        return math.random(6) - 1
    end
    return 0
end

CreateThread(function()
    while cfg.wheelbreak and cfg.wheelbreak.toggle do
        local waitLoop = 5000
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) == playerPed and isVehicleClassValid(GetVehicleClass(vehicle)) then
                waitLoop = 100
                local gameTimer = GetGameTimer()
                local canBreakWheel = (vehicleCooldownCache[vehicle] or 0) <= gameTimer
                local hasCollision = HasEntityCollidedWithAnything(vehicle)
                local shouldBreakWheel = false
                local currentSpeed = GetEntitySpeed(vehicle) * 3.6
                local previousSpeed = vehicleSpeedCache[vehicle] or currentSpeed
                vehicleSpeedCache[vehicle] = currentSpeed

                if wheelBreakMode == "impact" then
                    local currentBodyHealth = GetVehicleBodyHealth(vehicle)
                    local previousBodyHealth = vehicleBodyHealthCache[vehicle] or currentBodyHealth
                    local bodyHealthLoss = previousBodyHealth - currentBodyHealth
                    local speedLoss = math.max(0.0, previousSpeed - currentSpeed)
                    vehicleBodyHealthCache[vehicle] = currentBodyHealth
                    local hasStrongImpact = bodyHealthLoss >= wheelBreakImpactDamage or speedLoss >= wheelBreakImpactDeltaSpeed
                    if canBreakWheel and hasStrongImpact and (hasCollision or previousSpeed >= wheelBreakMinImpactSpeed) then
                        shouldBreakWheel = true
                    end
                else
                    local vehicleSpeed = math.ceil(currentSpeed)
                    if hasCollision and canBreakWheel and vehicleSpeed >= wheelBreakSpeed then
                        shouldBreakWheel = true
                    end
                end

                if shouldBreakWheel then
                    local randomWheelIndex = getRandomWheelIndex(vehicle)
                    if setVehicleWheelsCanBreakOff then
                        setVehicleWheelsCanBreakOff(vehicle, true)
                    end
                    BreakOffVehicleWheel(vehicle, randomWheelIndex, true, false, true, false)
                    SetVehicleTyreBurst(vehicle, randomWheelIndex, false, 1000.0)
                    vehicleCooldownCache[vehicle] = gameTimer + wheelBreakCooldown
                    waitLoop = wheelBreakCooldown
                end
            else
                vehicleBodyHealthCache[vehicle] = GetVehicleBodyHealth(vehicle)
                vehicleSpeedCache[vehicle] = GetEntitySpeed(vehicle) * 3.6
            end
        end
        Wait(waitLoop)
    end
end)

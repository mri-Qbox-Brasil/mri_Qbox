-- Contador de pontos de drift na tela (NUI do mri_Qbox).

local score = 0
local screenScore = 0
local idleTime
local mult = 0.2
local stopped = false
local lastSent

local function roundScore(number)
    number = math.floor(tonumber(number) or 0)
    if number < 0.01 then return 0 end
    return math.min(number, 999999999)
end

local function driftAngle(veh)
    local vx, vy = table.unpack(GetEntityVelocity(veh))
    local modV = math.sqrt(vx * vx + vy * vy)
    local _, _, rz = table.unpack(GetEntityRotation(veh, 0))
    local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

    if GetEntitySpeed(veh) * 3.6 < 30 or GetVehicleCurrentGear(veh) == 0 then return 0, modV end

    local cosX = (sn * vx + cs * vy) / modV
    if cosX > 0.966 or cosX < 0 then return 0, modV end
    return math.deg(math.acos(cosX)) * 0.5, modV
end

local function send(points)
    SendNUIMessage({ drift = points })
end

CreateThread(function()
    while true do
        if not Mri.enabled('driftpoints') then
            if not stopped then send(0) stopped = true end
            Wait(1000)
        else
            local ped = PlayerPedId()
            local tick = GetGameTimer()
            local veh = GetVehiclePedIsUsing(ped)
            if not IsPedDeadOrDying(ped, true) and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped
                and IsVehicleOnAllWheels(veh) and not IsPedInFlyingVehicle(ped) then
                local angle, velocity = driftAngle(veh)
                local chained = tick - (idleTime or 0) < 1850

                if angle ~= 0 then
                    stopped = false
                    if chained then
                        score = score + math.floor(angle * velocity) * mult
                    else
                        score = math.floor(angle * velocity) * mult
                    end
                    screenScore = roundScore(score)
                    idleTime = tick
                elseif lastSent and lastSent > 0 and lastSent == screenScore and not stopped then
                    send(0)
                    stopped = true
                end
            elseif not IsPedInAnyVehicle(ped, false) and not stopped then
                send(0)
                stopped = true
            end

            if not stopped then
                send(screenScore or 0)
                lastSent = screenScore
            end
            Wait(500)
        end
    end
end)

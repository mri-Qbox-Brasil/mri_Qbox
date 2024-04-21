local score = 0
local screenScore = 0
local tick
local idleTime
local driftTime
local tablemultiplier = {350,1400,4200,11200}
local mult = 0.2
local previous = 0
local total = 0
local curAlpha = 0

local SaveAtEndOfDrift = nil
local SaveTime = nil

function round(number)
    number = tonumber(number)
    number = math.floor(number)
    
    if number < 0.01 then
        number = 0
    elseif number > 999999999 then
        number = 999999999
    end
    return number
end

function calculateBonus(previous)
    local points = previous
    local points = round(points)
    return points or 0
end


function angle(veh)
    if not veh then return false end
    local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
    local modV = math.sqrt(vx*vx + vy*vy)
    
    
    local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
    local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
    
    if GetEntitySpeed(veh)* 3.6 < 30 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --speed over 30 km/h
    
    local cosX = (sn*vx + cs*vy)/modV
    if cosX > 0.966 or cosX < 0 then return 0,modV end
    return math.deg(math.acos(cosX))*0.5, modV
end

local stopped = false

Citizen.CreateThread( function()
	while true do
		local sleep = 1000
		PlayerPed = PlayerPedId()
		tick = GetGameTimer()
		if not IsPedDeadOrDying(PlayerPed, 1) and GetVehiclePedIsUsing(PlayerPed) and GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPed), -1) == PlayerPed and IsVehicleOnAllWheels(GetVehiclePedIsUsing(PlayerPed)) and not IsPedInFlyingVehicle(PlayerPed) then
            sleep = 1
            PlayerVeh = GetVehiclePedIsIn(PlayerPed,false)
			local angle,velocity = angle(PlayerVeh)
			local tempBool = tick - (idleTime or 0) < 1850
			
			if angle ~= 0 then
                stopped = false
				if score == 0 then
					driftTime = tick
				end
				if tempBool then
					score = score + math.floor(angle*velocity)*mult
				else
					score = math.floor(angle*velocity)*mult
				end
				screenScore = calculateBonus(score)
				
				idleTime = tick
            else
                if old and not stopped then
                    if old > 0 then
                        if old == screenScore then
                            SendNUIMessage({ drift = 0})
                            stopped = true
                        end
                    end
                end
			end
		end
		
		if tick - (idleTime or 0) < 3000 then
			if curAlpha < 255 and curAlpha+10 < 255 then
				curAlpha = curAlpha+10
			elseif curAlpha > 255 then
				curAlpha = 255
			elseif curAlpha == 255 then
				curAlpha = 255
			elseif curAlpha == 250 then
				curAlpha = 255
			end
		else
			if curAlpha > 0 and curAlpha-10 > 0 then
				curAlpha = curAlpha-10			elseif curAlpha < 0 then
				curAlpha = 0
			elseif curAlpha == 5 then
				curAlpha = 0
			end
		end
       
        if not stopped then
            if not screenScore then
                screenScore = 0  
                SendNUIMessage({ drift = 0})
            else
                SendNUIMessage({ drift = screenScore})
            end
            old = screenScore
        end
       
        Citizen.Wait(500)
	end
end)


Citizen.CreateThread( function()
    while true do
        if not IsPedInAnyVehicle(PlayerPedId()) and stopped == false then
            SendNUIMessage({ drift = 0})
            stopped = true
        end
        Citizen.Wait(1000)
    end
end)

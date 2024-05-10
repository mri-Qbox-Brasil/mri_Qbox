-- Otimização em cima do RealisticAirControl by .mur4i
-- contriubição: .reiffps

Citizen.CreateThread(function()
    local playerPed = -1
    local vehicle = nil
    local vehicleClass = nil
    local vehicleClassDisableControl = {
        [0] = true,     --compacts
        [1] = true,     --sedans
        [2] = true,     --SUV's
        [3] = true,     --coupes
        [4] = true,     --muscle
        [5] = true,     --sport classic
        [6] = true,     --sport
        [7] = true,     --super
        [8] = false,    --motorcycle
        [9] = true,     --offroad
        [10] = true,    --industrial
        [11] = true,    --utility
        [12] = true,    --vans
        [13] = false,   --bicycles
        [14] = false,   --boats
        [15] = false,   --helicopter
        [16] = false,   --plane
        [17] = true,    --service
        [18] = true,    --emergency
        [19] = false    --military
    }
    local disableIfFlying = true        -- Enable/disable control disable while flying
  
    while cfg.disableaircontrol.toogle do
      if not IsPedInAnyVehicle(playerPed) then
        -- Player not in vehicle, reset variables
        playerPed = GetPlayerPed(-1)
        vehicle = nil
        vehicleClass = nil
        Citizen.Wait(1000)
      else
        if playerPed ~= GetPlayerPed(-1) or vehicle ~= GetVehiclePedIsIn(playerPed, false) then
          -- Player or vehicle changed, update variables
          playerPed = GetPlayerPed(-1)
          vehicle = GetVehiclePedIsIn(playerPed, false)
          if IsPedInAnyVehicle(playerPed) then
            vehicleClass = GetVehicleClass(vehicle)
          end
        end
  
        if vehicleClass and  vehicleClassDisableControl[vehicleClass] and (GetPedInVehicleSeat(vehicle, -1) == playerPed) then
          if disableIfFlying and IsEntityInAir(vehicle) then
            DisableControlAction(2, 59)  -- Disable jump control
            DisableControlAction(2, 60)  -- Disable exit vehicle control
          end
        end
      end
  
      Citizen.Wait(0) -- Wait for next frame without unnecessary delay
    end
  end)
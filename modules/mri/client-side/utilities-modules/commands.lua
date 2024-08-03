RegisterNetEvent("mri_Qbox:ExecuteCommand", function(command,args)
    if not args then
        ExecuteCommand(command)
    else
        ExecuteCommand(command.." "..args)
    end
end)

-- RegisterNetEvent("vehtuning", function()
lib.callback.register("vehtuning", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    if IsEntityAVehicle(vehicle) then
        SetVehicleModKit(vehicle,0)
        -- SetVehicleMod(vehicle,0,GetNumVehicleMods(vehicle,0)-1,false) -- spoiler
        SetVehicleMod(vehicle,1,GetNumVehicleMods(vehicle,1)-1,false)
        SetVehicleMod(vehicle,2,GetNumVehicleMods(vehicle,2)-1,false)
        SetVehicleMod(vehicle,3,GetNumVehicleMods(vehicle,3)-1,false)
        SetVehicleMod(vehicle,4,GetNumVehicleMods(vehicle,4)-1,false)
        SetVehicleMod(vehicle,5,GetNumVehicleMods(vehicle,5)-1,false)
        SetVehicleMod(vehicle,6,GetNumVehicleMods(vehicle,6)-1,false)
        -- SetVehicleMod(vehicle,7,GetNumVehicleMods(vehicle,7)-1,false) -- bonnet
        SetVehicleMod(vehicle,8,GetNumVehicleMods(vehicle,8)-1,false)
        SetVehicleMod(vehicle,9,GetNumVehicleMods(vehicle,9)-1,false)
        -- SetVehicleMod(vehicle,10,GetNumVehicleMods(vehicle,10)-1,false) -- roof
        SetVehicleMod(vehicle,11,GetNumVehicleMods(vehicle,11)-1,false)
        SetVehicleMod(vehicle,12,GetNumVehicleMods(vehicle,12)-1,false)
        SetVehicleMod(vehicle,13,GetNumVehicleMods(vehicle,13)-1,false)
        -- SetVehicleMod(vehicle,14,16,false) -- horn
        SetVehicleMod(vehicle,15,GetNumVehicleMods(vehicle,15)-2,false)
        SetVehicleMod(vehicle,16,GetNumVehicleMods(vehicle,16)-1,false)
        ToggleVehicleMod(vehicle,17,true)
        ToggleVehicleMod(vehicle,18,true)
        ToggleVehicleMod(vehicle,19,true)
        ToggleVehicleMod(vehicle,20,true)
        ToggleVehicleMod(vehicle,21,true)
        ToggleVehicleMod(vehicle,22,true)
        -- SetVehicleMod(vehicle,23,1,false) -- wheels
        -- SetVehicleMod(vehicle,24,1,false) -- bike wheels back
        SetVehicleMod(vehicle,25,GetNumVehicleMods(vehicle,25)-1,false)
        -- SetVehicleMod(vehicle,27,GetNumVehicleMods(vehicle,27)-1,false)
        SetVehicleMod(vehicle,28,GetNumVehicleMods(vehicle,28)-1,false)
        SetVehicleMod(vehicle,30,GetNumVehicleMods(vehicle,30)-1,false)
        SetVehicleMod(vehicle,33,GetNumVehicleMods(vehicle,33)-1,false)
        SetVehicleMod(vehicle,34,GetNumVehicleMods(vehicle,34)-1,false)
        SetVehicleMod(vehicle,35,GetNumVehicleMods(vehicle,35)-1,false)
        SetVehicleMod(vehicle,38,GetNumVehicleMods(vehicle,38)-1,true)
        SetVehicleTyreSmokeColor(vehicle,0,0,0)
        SetVehicleWindowTint(vehicle,1)
        SetVehicleTyresCanBurst(vehicle,false)
        -- SetVehicleNumberPlateText(vehicle,"Fluxooo")
        SetVehicleNumberPlateTextIndex(vehicle,5)
        SetVehicleModColor_1(vehicle,0,0,0)
        SetVehicleModColor_2(vehicle,0,0)
        SetVehicleColours(vehicle,0,0)
        SetVehicleExtraColours(vehicle,0,0)
        -- SetVehicleNeonLightEnabled(vehicle,0,true)
        -- SetVehicleNeonLightEnabled(vehicle,1,true)
        -- SetVehicleNeonLightEnabled(vehicle,2,true)
        -- SetVehicleNeonLightEnabled(vehicle,3,true)
        -- SetVehicleNeonLightsColour(vehicle,255,255,255)
    end
end)

RegisterCommand("addskill", function(source, args)
    exports["cw-rep"]:updateSkill(args[1], args[2])
end)

RegisterCommand("menu", function(source, args)
    if args and args[1] then
        exports.qbx_management:OpenBossMenu(args[1])
    end
end)

if not cfg.indestructibleProps then return end

--[[ This is a CLIENT script ]]

--[[ Delay between executions to freeze the items ]]
local delay = 1500

--[[ List of props that should be 'invicible' ]]
local indestructibleModels = {
    [`prop_traffic_03b`] = true,
    [`prop_traffic_lightset_01`] = true,
    [`prop_traffic_01a`] = true,
    [`prop_traffic_01b`] = true,
    [`prop_traffic_01d`] = true,
    [`prop_traffic_02b`] = true,
    [`prop_traffic_02a`] = true,
    [`prop_streetlight_11c`] = true,
    [`prop_streetlight_10`] = true,
    [`prop_streetlight_12a`] = true,
    [`prop_streetlight_11b`] = true,
    [`prop_streetlight_06`] = true,
    [`prop_streetlight_07a`] = true,
    [`prop_streetlight_11a`] = true,
    [`prop_streetlight_15a`] = true,
    [`prop_streetlight_07b`] = true,
    [`prop_streetlight_09`] = true,
    [`prop_snow_streetlight_09`] = true,
    [`prop_streetlight_12b`] = true,
    [`prop_streetlight_08`] = true,
    [`prop_streetlight_04`] = true,
    [`prop_streetlight_14a`] = true,
    [`prop_streetlight_02`] = true,
    [`prop_streetlight_03c`] = true,
    [`prop_snow_streetlight01`] = true,
    [`prop_streetlight_05_b`] = true,
    [`prop_streetlight_03`] = true,
    [`prop_streetlight_01b`] = true,
    [`prop_streetlight_03b`] = true,
    [`prop_streetlight_03d`] = true,
    [`prop_traffic_03a`] = true,
    [`prop_snow_streetlight_01_frag_`] = true,
    [`prop_streetlight_03e`] = true,
    [`prop_streetlight_05`] = true,
    [`prop_streetlight_16a`] = true,
    [`prop_streetlight_01`] = true,
    [`prop_fire_hydrant_2`] = true,
    [`prop_fire_hydrant_1`] = true,
    [`prop_fire_hydrant_4`] = true,
    [`prop_fire_hydrant_2_l1`] = true
}

--[[ Redeclaring the natives to improve performance ]]
--[[ Best to run with "use_experimental_fxv2_oal 'yes'" in manifest ]]
local GetGamePool, Wait, GetEntityModel, IsEntityPositionFrozen, FreezeEntityPosition, SetEntityCanBeDamaged = GetGamePool, Wait, GetEntityModel, IsEntityPositionFrozen, FreezeEntityPosition, SetEntityCanBeDamaged

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(50) end

    while true do
        Wait(delay)

        local props = GetGamePool('CObject')
        for _, prop in ipairs(props) do
            local model = GetEntityModel(prop)

            if indestructibleModels[model] then
                if not IsEntityPositionFrozen(prop) then
                    FreezeEntityPosition(prop, true)
                    SetEntityCanBeDamaged(prop, false)
                end
            end
        end
    end
end)

--[[ Inspired from JayPaulinCodes C# version ]]
--[[ https://github.com/JayPaulinCodes/Indestructible-Objects ]]
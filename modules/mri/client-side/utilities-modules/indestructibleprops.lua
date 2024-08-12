if not cfg.indestructibleProps then return end

--[[ This is a CLIENT script ]]

--[[ Delay between executions to freeze the items ]]
local delay = 1500

--[[ List of props that should be 'invicible' ]]
local indestructibleModels = {
    `prop_traffic_03b`,
    `prop_traffic_lightset_01`,
    `prop_traffic_01a`,
    `prop_traffic_01b`,
    `prop_traffic_01d`,
    `prop_traffic_02b`,
    `prop_traffic_02a`,
    `prop_streetlight_11c`,
    `prop_streetlight_10`,
    `prop_streetlight_12a`,
    `prop_streetlight_11b`,
    `prop_streetlight_06`,
    `prop_streetlight_07a`,
    `prop_streetlight_11a`,
    `prop_streetlight_15a`,
    `prop_streetlight_07b`,
    `prop_streetlight_09`,
    `prop_snow_streetlight_09`,
    `prop_streetlight_12b`,
    `prop_streetlight_08`,
    `prop_streetlight_04`,
    `prop_streetlight_14a`,
    `prop_streetlight_02`,
    `prop_streetlight_03c`,
    `prop_snow_streetlight01`,
    `prop_streetlight_05_b`,
    `prop_streetlight_03`,
    `prop_streetlight_01b`,
    `prop_streetlight_03b`,
    `prop_streetlight_03d`,
    `prop_traffic_03a`,
    `prop_snow_streetlight_01_frag_`,
    `prop_streetlight_03e`,
    `prop_streetlight_05`,
    `prop_streetlight_16a`,
    `prop_streetlight_01`,
    `prop_fire_hydrant_2`,
    `prop_fire_hydrant_1`,
    `prop_fire_hydrant_4`,
    `prop_fire_hydrant_2_l1`
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

            for _, indestructibleModel in ipairs(indestructibleModels) do
                if model == indestructibleModel then
                    if not IsEntityPositionFrozen(prop) then
                        FreezeEntityPosition(prop, true)
                        SetEntityCanBeDamaged(prop, false)
                    end
                    break
                end
            end
        end
    end
end)

--[[ Inspired from JayPaulinCodes C# version ]]
--[[ https://github.com/JayPaulinCodes/Indestructible-Objects ]]
if cfg.entervehicle.toggle then
exports.ox_target:addGlobalVehicle({
        {
        name = 'ox_target:driverF_ENTER',
        icon = 'fa-solid fa-right-to-bracket',
        label = "Porta dianteira do motorista",
        bones = { 'seat_dside_f' },
        distance = 2,
        onSelect = function(data)
            local vehicle = data.entity
            local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity
            
            if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
            else
                TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
            end
        end
    },
    {
        name = 'ox_target:passengerF_ENTER',
        icon = 'fa-solid fa-right-to-bracket',
        label = "Porta dianteira do passageiro",
        bones = { 'seat_pside_f' },
        distance = 2,
        onSelect = function(data)
            local vehicle = data.entity
            local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity
            
            if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
            else
                TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
            end
        end
    },
    {
        name = 'ox_target:driverR_ENTER',
        icon = 'fa-solid fa-right-to-bracket',
        label = "Porta traseira do motorista",
        bones = { 'seat_dside_r' },
        distance = 2,
        onSelect = function(data)
            local vehicle = data.entity
            local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity
            
            if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
            else
                TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
            end
        end
    },
    {
        name = 'ox_target:passengerR_ENTER',
        icon = 'fa-solid fa-right-to-bracket',
        label = "Porta traseira do passageiro",
        bones = { 'seat_pside_r' },
        distance = 2,
        onSelect = function(data)
            local vehicle = data.entity
            local isVehicleShopEntity = Entity(vehicle).state.isVehicleShopEntity
            
            if isVehicleShopEntity and isVehicleShopEntity ~= "" then
                exports.qbx_core:Notify("Você não pode entrar em carros da concessionária")
            else
                TaskEnterVehicle(PlayerPedId(), vehicle, 10000, -1, 1.0, 1, 0)
            end
        end
    }
    -- {
    --     name = 'ox_target:trunk_ENTER',
    --     icon = 'fa-solid fa-car-rear',
    --     label = "Entrar no porta-malas",
    --     offset = vec3(0.5, 0, 0.5),
    --     distance = 2,
    --     onSelect = function(data)
    --         ExecuteCommand("getintrunk")
    --     end
    -- }
})
end
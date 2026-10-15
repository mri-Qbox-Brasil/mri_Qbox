local OPTION = 'mri_flipvehicle'

local function overturned(vehicle)
    return IsEntityUpsidedown(vehicle) or math.abs(GetEntityRoll(vehicle)) > 60.0
end

-- qbx_flipvehicle: no vehicle means the closest one; flipTest skips the progress bar
---@param vehicle number?
---@param flipTest boolean?
local function flipVehicle(vehicle, flipTest)
    if cache.vehicle then return end
    local cfg = Mri.cfg('flipvehicle')
    local maxDistance = tonumber(cfg.maxDistance) or 2
    local pedCoords = GetEntityCoords(cache.ped)
    vehicle = vehicle or lib.getClosestVehicle(pedCoords, maxDistance, false)
    if not vehicle or #(pedCoords - GetEntityCoords(vehicle)) > maxDistance then
        return exports.qbx_core:Notify('Sem veículo por perto para desvirar.', 'error')
    end

    if not flipTest and not lib.progressBar({
        label = 'Desvirando veículo...',
        duration = math.floor((tonumber(cfg.seconds) or 15) * 1000),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, mouse = false, combat = true },
        anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
    }) then
        return exports.qbx_core:Notify('Cancelado...', 'error')
    end

    -- only the entity owner can place it on the ground
    NetworkRequestControlOfEntity(vehicle)
    -- lib.waitFor raises on timeout
    pcall(lib.waitFor, function() return NetworkHasControlOfEntity(vehicle) or nil end, nil, 2000)
    SetVehicleOnGroundProperly(vehicle)
    exports.qbx_core:Notify('Veículo desvirado com sucesso!', 'success')
end

-- exports of qbx_flipvehicle, answered under the old resource name
for _, name in ipairs({ 'FlipVehicle', 'flipVehicle' }) do
    AddEventHandler(('__cfx_export_qbx_smallresources_%s'):format(name), function(setCB)
        setCB(function(...)
            if Mri.enabled('flipvehicle') then flipVehicle(...) end
        end)
    end)
end

Mri.lifecycle('flipvehicle', function(cfg)
    exports.ox_target:addGlobalVehicle({{
        name = OPTION,
        icon = 'fa-solid fa-rotate',
        label = 'Desvirar',
        distance = tonumber(cfg.maxDistance) or 2,
        canInteract = function(entity)
            return not cache.vehicle and overturned(entity)
        end,
        onSelect = function(data)
            flipVehicle(data.entity)
        end,
    }})
end, function()
    exports.ox_target:removeGlobalVehicle(OPTION)
end)

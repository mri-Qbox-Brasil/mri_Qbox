-- Postes, semáforos e hidrantes não quebram nem saem do lugar (inspirado em
-- JayPaulinCodes/Indestructible-Objects). Modelos no painel.

local GetGamePool, Wait, GetEntityModel, IsEntityPositionFrozen, FreezeEntityPosition, SetEntityCanBeDamaged =
    GetGamePool, Wait, GetEntityModel, IsEntityPositionFrozen, FreezeEntityPosition, SetEntityCanBeDamaged

local sourceList, modelSet
local function models(cfg)
    if cfg.models ~= sourceList then
        sourceList, modelSet = cfg.models, {}
        for _, name in ipairs(cfg.models or {}) do modelSet[joaat(name)] = true end
    end
    return modelSet
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(50) end

    while true do
        local cfg = Mri.cfg('indestructibleprops')
        Wait(cfg.delay or 1500)
        if cfg.enabled then
            local set = models(cfg)
            for _, prop in ipairs(GetGamePool('CObject')) do
                if set[GetEntityModel(prop)] and not IsEntityPositionFrozen(prop) then
                    FreezeEntityPosition(prop, true)
                    SetEntityCanBeDamaged(prop, false)
                end
            end
        end
    end
end)

-- Impede o capacete automático nas motos (config flag 35 do ped). Desligado,
-- devolve o comportamento padrão do jogo.

local function apply(ped, enabled)
    if ped and ped ~= 0 then
        SetPedConfigFlag(ped, 35, not enabled)
    end
end

lib.onCache('ped', function(value)
    if Mri.enabled('helmet') then apply(value, true) end
end)

Mri.lifecycle('helmet', function()
    apply(cache.ped, true)
end, function()
    apply(cache.ped, false)
end)

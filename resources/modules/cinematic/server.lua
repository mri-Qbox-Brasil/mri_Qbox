-- Comandos ficam registrados (o FiveM não remove comando); desligado no painel,
-- avisam e não fazem nada.
local function guarded(fn)
    return function(source, ...)
        if not Mri.enabled('cinematic') then
            if source and source > 0 then
                lib.notify(source, { type = 'error', description = 'Comando desligado no painel do mri_Qbox.' })
            end
            return
        end
        return fn(source, ...)
    end
end

lib.addCommand('cinematic', {
    help = 'Iniciar o cinematica',
    restricted = 'group.admin'
}, guarded(function(source, args)
    TriggerClientEvent('mth-cinematic:start', source)
end))
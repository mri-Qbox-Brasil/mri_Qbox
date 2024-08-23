lib.addCommand('cinematic', {
    help = 'Iniciar o cinematica',
    restricted = 'group.admin'
}, function(source, args)
    TriggerClientEvent('mth-cinematic:start', source)
end)
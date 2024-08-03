AddEventHandler('playerConnecting', function(playerName, setKickReason)
    identifiers = GetPlayerIdentifiers(source)
    if cfg.printidentifiers then
        for i in ipairs(identifiers) do
            print('Jogador: ' .. playerName .. ', Identificador #' .. i .. ': ' .. identifiers[i])
        end
    end
end)

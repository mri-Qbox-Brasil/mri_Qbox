-- Mostra no console os identificadores de quem conecta.

AddEventHandler('playerConnecting', function(playerName)
    if not Mri.enabled('identifiers') then return end
    local identifiers = GetPlayerIdentifiers(source)
    for i in ipairs(identifiers) do
        print('Jogador: ' .. playerName .. ', Identificador #' .. i .. ': ' .. identifiers[i])
    end
end)

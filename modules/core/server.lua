local cfg = require('modules.core.config')

if not cfg.dropitems then return end
local dropItems = cfg.dropitems_table

local bannedItems = {
    ["identification"] = true
}

exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= 'newdrop' then return end

    local item = payload.fromSlot
    local items = { { item.name, payload.count, item.metadata } }
    local dropId = exports.ox_inventory:CustomDrop(item.label, items,
        GetEntityCoords(GetPlayerPed(payload.source)), 1, item.weight, nil, dropItems[item.name])

    if not dropId then return end

    CreateThread(function()
        exports.ox_inventory:RemoveItem(payload.source, item.name, payload.count, nil, item.slot)
        Wait(0)
        exports.ox_inventory:forceOpenInventory(payload.source, 'drop', dropId)
    end)

    return false
end, {
    itemFilter = dropItems,
    typeFilter = { player = true }
})

AddEventHandler('playerConnecting', function(playerName, setKickReason)
    identifiers = GetPlayerIdentifiers(source)
    if cfg.printidentifiers then
        for i in ipairs(identifiers) do
            print('Jogador: ' .. playerName .. ', Identificador #' .. i .. ': ' .. identifiers[i])
        end
    end
end)

lib.addCommand('viewallitems', {
    help = "Views all the items thats currently on the server",
    restricted = "group.admin"
}, function(source)
    local items = exports.ox_inventory:Items()
    local showItems = {}
    local weight = 0
    local slots = 0

    for k, v in pairs(items) do
        if not bannedItems[k] then
            slots += 1
            weight += v.weight
            showItems[slots] = { k, 1 }
        end
    end

    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = 'CheckItems',
        slots = slots,
        maxWeight = weight,
        items = showItems
    })

    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stash)
end)

RegisterCommand('models', function ()
    local models = GetAllVehicleModels()
    local missingVehicles = {}
    for i = 1, #models do
        if not VehicleList[models[i]] then
            missingVehicles[#missingVehicles+1] = models[i]
        end
    end
    lib.setClipboard(json.encode(missingVehicles))
end)

--- Envia uma notificacao ao jogador ou exibe uma mensagem de log no console.
-- @param source O ID do jogador que recebera a notificacao. Se `source` for maior que 0 e o tipo nao for 'debug', a notificação sera enviada ao jogador. Caso contrário, apenas uma mensagem sera exibida no console.
-- @param type O tipo de notificação. Pode ser 'success', 'error', 'debug' ou 'warn'. Cada tipo determina a cor e o título da notificacao.
-- @param message A mensagem que sera exibida na notificação ou no console.
-- @example
-- SendNotification(1, 'success', 'Operação concluida com sucesso.')
-- -- Envia uma notificacao de sucesso para o jogador com ID 1.
--
-- SendNotification(0, 'error', 'Falha ao realizar a operação.')
-- -- Exibe uma mensagem de erro no console.
function SendNotification(source, type, message, webhook, keepOnConsole)
    local msgColor = '^2'
    local title = 'Sucesso'

    if type == 'error' then
        msgColor = '^1'
        title = 'Erro'
    elseif type == 'debug' then
        msgColor = '^5'
        title = 'Debug'
    elseif type == 'warn' then
        msgColor = '^3'
        title = 'Aviso'
    elseif type == 'info' then
        msgColor = '^4'
        title = 'Informação'
    end

    if webhook then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = title, content = message}), { ['Content-Type'] = 'application/json' })
    end

    if (not webhook or (webhook and keepOnConsole)) and ((source > 0) and (type ~= 'debug')) then
        lib.notify(source, {
            title = title,
            type = type,
            description = message
        })
    end

    print(string.format("%s %s: %s^7", msgColor, title, message))
end

--- Divide uma string em partes com base em um separador especificado.
-- @param inputstr A string que sera dividida.
-- @param sep O separador usado para dividir a string. Se nao for especificado, o separador padrao sera um espaco em branco.
-- @return Uma tabela contendo as partes da string dividida.
-- @example
-- local result = Split("Ola, mundo!", ",")
-- -- result = {"Ola", " mundo!"}
function Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

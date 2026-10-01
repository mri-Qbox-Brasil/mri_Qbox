-- Utilidades do núcleo no server, usadas pelos módulos e por outros resources.

-- Cores de status que outros resources MRI leem (ex.: mri_Qjobsystem colore o menu).
GlobalState:set('UIColors', {
    success = '#51CF66',
    info = '#668CFF',
    warning = '#FFD700',
    danger = '#FF6347',
}, true)

--- Envia uma notificação ao jogador ou só registra no console.
---@param source number jogador; 0 ou tipo 'debug' = só console
---@param type 'success'|'error'|'debug'|'warn'|'info'
---@param message string
---@param webhook? string manda também pro webhook (Discord)
---@param keepOnConsole? boolean com webhook, notifica o jogador mesmo assim
function SendNotification(source, type, message, webhook, keepOnConsole)
    local msgColor, title = '^2', 'Sucesso'
    if type == 'error' then
        msgColor, title = '^1', 'Erro'
    elseif type == 'debug' then
        msgColor, title = '^5', 'Debug'
    elseif type == 'warn' then
        msgColor, title = '^3', 'Aviso'
    elseif type == 'info' then
        msgColor, title = '^4', 'Informação'
    end

    if webhook then
        PerformHttpRequest(webhook, function() end, 'POST', json.encode({ username = title, content = message }), { ['Content-Type'] = 'application/json' })
    end

    if (not webhook or keepOnConsole) and source > 0 and type ~= 'debug' then
        lib.notify(source, { title = title, type = type, description = message })
    end

    print(('%s %s: %s^7'):format(msgColor, title, message))
end

--- Divide uma string pelo separador (padrão: espaço).
---@param inputstr string
---@param sep? string
---@return string[]
function Split(inputstr, sep)
    sep = sep or '%s'
    local t = {}
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
        t[#t + 1] = str
    end
    return t
end

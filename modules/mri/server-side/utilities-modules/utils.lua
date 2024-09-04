--- Envia uma notificação ao jogador ou exibe uma mensagem de log no console.
-- @param source O ID do jogador que receberá a notificação. Se `source` for maior que 0 e o tipo não for 'debug', a notificação será enviada ao jogador. Caso contrário, apenas uma mensagem será exibida no console.
-- @param type O tipo de notificação. Pode ser 'success', 'error', 'debug' ou 'warn'. Cada tipo determina a cor e o título da notificação.
-- @param message A mensagem que será exibida na notificação ou no console.
-- @example
-- SendNotification(1, 'success', 'Operação concluída com sucesso.')
-- -- Envia uma notificação de sucesso para o jogador com ID 1.
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
-- @param inputstr A string que será dividida.
-- @param sep O separador usado para dividir a string. Se não for especificado, o separador padrão será um espaço em branco.
-- @return Uma tabela contendo as partes da string dividida.
-- @example
-- local result = Split("Olá, mundo!", ",")
-- -- result = {"Olá", " mundo!"}
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

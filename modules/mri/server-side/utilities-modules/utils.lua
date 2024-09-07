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

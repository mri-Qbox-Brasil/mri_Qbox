-- The server filters the panel map (server commands are only visible here) and publishes it to the clients.
local STATE_KEY = 'mri_Qbox:aliases'

local function normalize(name)
    if type(name) ~= 'string' then return nil end
    name = name:match('^%s*/?(.-)%s*$'):lower()
    return name:match('^[%w_%-%.:]+$') and #name <= 32 and name or nil
end

local function serverCommands()
    local names = {}
    for _, command in ipairs(GetRegisteredCommands()) do
        names[command.name:lower()] = true
    end
    return names
end

local function publish(cfg)
    local taken, out = serverCommands(), {}
    local raw = type(cfg.aliases) == 'table' and cfg.aliases or {}
    local aliasNames = {}
    for alias in pairs(raw) do
        local name = normalize(alias)
        if name then aliasNames[name] = true end
    end
    for alias, target in pairs(raw) do
        local name, command = normalize(alias), normalize(target)
        if not name or not command then
            lib.print.warn(('atalho ignorado: "%s" -> "%s" (nome inválido)'):format(alias, target))
        elseif taken[name] then
            lib.print.warn(('atalho /%s ignorado: já existe um comando com esse nome'):format(name))
        elseif aliasNames[command] then
            lib.print.warn(('atalho /%s ignorado: aponta pra outro atalho (/%s)'):format(name, command))
        else
            out[name] = command
        end
    end
    GlobalState[STATE_KEY] = out
end

local running = false

-- a resource started after us may register a command with an alias name
AddEventHandler('onServerResourceStart', function(name)
    if running and name ~= GetCurrentResourceName() then publish(Mri.cfg('aliases')) end
end)

Mri.lifecycle('aliases', function(cfg)
    running = true
    publish(cfg)
end, function()
    running = false
    GlobalState[STATE_KEY] = {}
end)

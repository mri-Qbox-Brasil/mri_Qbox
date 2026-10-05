-- Commands can't be unregistered: an alias stays registered and reads the current map when used.
local STATE_KEY = 'mri_Qbox:aliases'
local current = {}
local registered = {}
local suggested = {}

local function clientCommands()
    local names = {}
    for _, command in ipairs(GetRegisteredCommands()) do
        names[command.name:lower()] = true
    end
    return names
end

local function run(alias, raw)
    local target = current[alias]
    if not target then
        lib.notify({ type = 'error', description = ('O atalho /%s foi desligado no painel do mri_Qbox.'):format(alias) })
        return
    end
    -- a server command falls through to the server, checked against the player's own permission
    ExecuteCommand(target .. (raw:match('^%S+(.*)$') or ''))
end

local function apply(map)
    current = type(map) == 'table' and map or {}
    local taken = clientCommands()
    for alias, target in pairs(current) do
        if not registered[alias] then
            if taken[alias] then
                current[alias] = nil
                print(('^3[mri_Qbox] atalho /%s ignorado: já existe um comando com esse nome^7'):format(alias))
            else
                registered[alias] = true
                RegisterCommand(alias, function(_, _, raw) run(alias, raw) end, false)
            end
        end
        if current[alias] and suggested[alias] ~= target then
            suggested[alias] = target
            TriggerEvent('chat:addSuggestion', '/' .. alias, ('Atalho de /%s'):format(target))
        end
    end
    for alias in pairs(suggested) do
        if not current[alias] then
            suggested[alias] = nil
            TriggerEvent('chat:removeSuggestion', '/' .. alias)
        end
    end
end

AddStateBagChangeHandler(STATE_KEY, 'global', function(_, _, value)
    apply(value)
end)

CreateThread(function()
    apply(GlobalState[STATE_KEY])
end)

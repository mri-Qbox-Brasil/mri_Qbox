-- Painel de config dos módulos (/mriqbox e aba no mri_Qadmin). Quem pode: ACE
-- `mri_Qbox.admin` ou `command`. Todo valor que chega da NUI é validado pelo tipo
-- do campo declarado no config.lua do módulo antes de gravar.

local function isAdmin(source)
    return IsPlayerAceAllowed(source, 'mri_Qbox.admin') or IsPlayerAceAllowed(source, 'command')
end

lib.callback.register('mri_Qbox:panel:isAdmin', function(source)
    return isAdmin(source)
end)

local MOMENT_DISPLAYS = { toast = true, player = true, none = true }
local MOMENT_POSITIONS = {
    top = true, ['top-right'] = true, ['top-left'] = true, bottom = true,
    ['bottom-right'] = true, ['bottom-left'] = true, ['center-right'] = true, ['center-left'] = true,
}

-- Valor válido pro campo, ou nil (descartado).
local function clean(field, value)
    local t = field.type
    if t == 'boolean' then
        if type(value) ~= 'boolean' then return nil end
        return value
    elseif t == 'number' then
        local n = tonumber(value)
        if not n then return nil end
        if field.min then n = math.max(field.min, n) end
        if field.max then n = math.min(field.max, n) end
        return n
    elseif t == 'text' then
        return type(value) == 'string' and value:sub(1, 300) or nil
    elseif t == 'select' then
        for _, option in ipairs(field.options or {}) do
            if option.value == value then return value end
        end
        return nil
    elseif t == 'list' then
        if type(value) ~= 'table' then return nil end
        local out = {}
        for _, item in ipairs(value) do
            if field.itemType == 'number' then
                local n = tonumber(item)
                if n then out[#out + 1] = n end
            elseif type(item) == 'string' and item ~= '' then
                out[#out + 1] = item:sub(1, 120)
            end
            if #out >= 500 then break end
        end
        return out
    elseif t == 'map' then
        if type(value) ~= 'table' then return nil end
        local out, count = {}, 0
        for k, v in pairs(value) do
            if type(k) == 'string' and k ~= '' then
                if field.itemType == 'number' then
                    v = tonumber(v)
                elseif type(v) == 'string' then
                    v = v:sub(1, 120)
                else
                    v = nil
                end
                if v ~= nil then
                    out[k:sub(1, 120)] = v
                    count = count + 1
                end
            end
            if count >= 500 then break end
        end
        return out
    elseif t == 'json' then
        if type(value) ~= 'table' or #json.encode(value) > 20000 then return nil end
        return value
    elseif t == 'moments' then
        -- momentos da trilha: nome -> { urls = { ... }, volume, loop }
        if type(value) ~= 'table' then return nil end
        local out, count = {}, 0
        for name, m in pairs(value) do
            if type(name) == 'string' and name ~= '' and type(m) == 'table' then
                local urls = {}
                for _, url in ipairs(type(m.urls) == 'table' and m.urls or { m.url }) do
                    if type(url) == 'string' and url ~= '' then urls[#urls + 1] = url:sub(1, 300) end
                    if #urls >= 50 then break end
                end
                if #urls > 0 then
                    out[name:sub(1, 60)] = {
                        urls = urls,
                        volume = math.max(0, math.min(1, tonumber(m.volume) or 1)),
                        loop = m.loop ~= false,
                        display = MOMENT_DISPLAYS[m.display] and m.display or nil,
                        autoplay = m.autoplay ~= false,
                        position = MOMENT_POSITIONS[m.position] and m.position or nil,
                    }
                    count = count + 1
                end
            end
            if count >= 200 then break end
        end
        return out
    elseif t == 'places' then
        -- locais da trilha sonora: círculo no mapa que toca um momento
        if type(value) ~= 'table' then return nil end
        local PRIORITIES = { ambient = true, zone = true, activity = true, scene = true, ui = true }
        local MODES = { any = true, foot = true, vehicle = true }
        local out = {}
        for _, p in ipairs(value) do
            if type(p) == 'table' and tonumber(p.x) and tonumber(p.y) and tonumber(p.z) and type(p.moment) == 'string' then
                out[#out + 1] = {
                    id = type(p.id) == 'string' and p.id:sub(1, 40) or tostring(#out + 1),
                    name = type(p.name) == 'string' and p.name:sub(1, 80) or 'Local',
                    x = tonumber(p.x) + 0.0,
                    y = tonumber(p.y) + 0.0,
                    z = tonumber(p.z) + 0.0,
                    radius = math.max(1, math.min(1000, tonumber(p.radius) or 30)),
                    minZ = tonumber(p.minZ),
                    maxZ = tonumber(p.maxZ),
                    moment = p.moment:sub(1, 80),
                    priority = PRIORITIES[p.priority] and p.priority or 'zone',
                    onlyNight = p.onlyNight == true,
                    mode = MODES[p.mode] and p.mode or 'any',
                }
            end
            if #out >= 200 then break end
        end
        return out
    end
    return nil
end

-- O que a NUI precisa pra montar a lista e os formulários.
local function snapshot()
    local list = {}
    for _, id in ipairs(Mri.order) do
        local def = Mri.modules[id]
        local values = { enabled = Mri.cfg(id).enabled == true }
        for _, field in ipairs(def.fields) do
            values[field.key] = Mri.cfg(id)[field.key]
        end
        local defaults = { enabled = def.defaults.enabled }
        for _, field in ipairs(def.fields) do
            defaults[field.key] = def.defaults[field.key]
        end
        list[#list + 1] = {
            id = id,
            label = def.label,
            category = def.category,
            description = def.description,
            restart = def.restart == true,
            required = def.required == true,
            page = def.page,
            fields = def.fields,
            values = values,
            defaults = defaults,
        }
    end
    return list
end

lib.callback.register('mri_Qbox:panel:get', function(source)
    if not isAdmin(source) then return false end
    return snapshot()
end)

lib.callback.register('mri_Qbox:panel:save', function(source, id, values)
    if not isAdmin(source) then return false, 'sem permissão' end
    local def = type(id) == 'string' and Mri.modules[id]
    if not def or type(values) ~= 'table' then return false, 'módulo inválido' end

    -- (sem `cond and x or y`: com x = false ele sempre caía no valor atual e desligar não gravava)
    local enabled = values.enabled
    if type(enabled) ~= 'boolean' or def.required then enabled = Mri.cfg(id).enabled == true end
    local saved = { enabled = enabled }
    for _, field in ipairs(def.fields) do
        local value = clean(field, values[field.key])
        if value ~= nil then saved[field.key] = value end
    end

    Mri.save(id, saved)
    lib.print.info(('[mri_Qbox] %s salvou o módulo %s'):format(GetPlayerName(source) or source, id))
    return true, snapshot()
end)

-- Cores da suíte ao vivo pra NUI aberta.
AddConvarChangeListener('mri:color', function(name)
    if name ~= 'mri:color' then return end
    local color = GetConvar('mri:color', '#00E699')
    if not color:match('^#%x%x%x%x%x%x$') then return end
    TriggerClientEvent('mri_Qbox:accentColorChanged', -1, color)
end)

AddConvarChangeListener('mri:backgroundColor', function(name)
    if name ~= 'mri:backgroundColor' then return end
    local color = GetConvar('mri:backgroundColor', '')
    if color ~= '' and not color:match('^#%x%x%x%x%x%x$') then return end
    TriggerClientEvent('mri_Qbox:backgroundColorChanged', -1, color)
end)

-- Aba no mri_Qadmin (opcional: sem ele o /mriqbox continua funcionando).
local function registerPlugin()
    if GetResourceState('mri_Qadmin') ~= 'started' then return end
    local ok, err = pcall(function()
        exports['mri_Qadmin']:RegisterPlugin({
            id = 'mriqbox',
            label = 'MRI Qbox',
            icon = 'blocks',
            resource = 'mri_Qbox',
            htmlPath = 'html/index.html',
            requiredPerms = { 'mri_Qbox.admin', 'command' },
            description = 'Módulos do mri_Qbox: ligar, desligar e configurar',
        })
    end)
    if not ok then
        lib.print.warn(('[mri_Qbox] Falha ao registrar plugin no mri_Qadmin: %s'):format(tostring(err)))
    end
end

-- O Qadmin avisa quando o registro dele fica pronto (inclusive num ensure dele);
-- o onServerResourceStart cobre o registro já pronto antes deste handler existir.
AddEventHandler('mri_Qadmin:server:pluginsReady', registerPlugin)
AddEventHandler('onServerResourceStart', function(name)
    if name == 'mri_Qadmin' then registerPlugin() end
end)
CreateThread(function()
    Wait(0)
    registerPlugin()
end)

-- Núcleo do mri_Qbox: registro dos módulos e leitura da config.
--
-- Cada resources/modules/<id>/config.lua chama Mri.module{...} com os padrões e os campos
-- que o painel edita. O server junta os padrões com o data/config.json e
-- publica o resultado em GlobalState['mri_Qbox:config']; o client guarda uma
-- cópia local atualizada pela statebag. Os módulos leem sempre por Mri.cfg(id),
-- então valor alterado no painel vale na hora para quem lê em loop.

Mri = Mri or {}

---@class MriField
---@field key string campo em Mri.cfg(id)
---@field type 'boolean'|'number'|'text'|'select'|'list'|'map'|'json'
---@field label string
---@field help? string
---@field min? number
---@field max? number
---@field step? number
---@field unit? string
---@field options? { value: string, label: string }[]
---@field itemType? 'text'|'number' tipo dos itens de list e dos valores de map

---@class MriModuleDef
---@field id string nome da pasta em resources/modules/
---@field label string
---@field category 'menus'|'admin'|'combat'|'vehicles'|'interaction'|'inventory'|'world'|'sound'
---@field description string
---@field restart? boolean ligar, desligar ou mudar campos só vale depois de reiniciar o mri_Qbox
---@field required? boolean parte da base: sempre ligado, o painel não mostra o botão de desligar
---@field page? string tela própria no painel no lugar do formulário de campos (ex.: 'vehicles')
---@field defaults table deve ter `enabled`
---@field fields? MriField[]

---@type table<string, MriModuleDef>
Mri.modules = Mri.modules or {}
---@type string[]
Mri.order = Mri.order or {}

---@param def MriModuleDef
function Mri.module(def)
    assert(type(def.id) == 'string', 'Mri.module: id obrigatório')
    def.defaults = def.defaults or {}
    if def.defaults.enabled == nil or def.required then def.defaults.enabled = true end
    def.fields = def.fields or {}
    if not Mri.modules[def.id] then Mri.order[#Mri.order + 1] = def.id end
    Mri.modules[def.id] = def
end

local function copy(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = copy(v) end
    return out
end
Mri.copy = copy

-- Padrões do módulo com os valores salvos por cima (só os campos conhecidos).
---@param id string
---@param saved table|nil
function Mri.merge(id, saved)
    local def = Mri.modules[id]
    local out = copy(def.defaults)
    if type(saved) ~= 'table' then return out end
    if type(saved.enabled) == 'boolean' and not def.required then out.enabled = saved.enabled end
    for _, field in ipairs(def.fields) do
        if saved[field.key] ~= nil then out[field.key] = copy(saved[field.key]) end
    end
    return out
end

-- Config efetiva do módulo (definida pelo lado: server/config.lua ou client/config.lua).
---@param id string
---@return table
function Mri.cfg(id)
    local current = Mri.current and Mri.current[id]
    if current then return current end
    local def = Mri.modules[id]
    return def and def.defaults or {}
end

---@param id string
---@return boolean
function Mri.enabled(id)
    return Mri.cfg(id).enabled == true
end

Mri.STATE_KEY = 'mri_Qbox:config'

-- ===== ligar e desligar sem reiniciar ====================================
-- Módulo que registra coisa ao carregar (olhinho, gancho do ox_inventory, item de
-- menu, textura) usa Mri.lifecycle: `start` roda quando ele liga (ou no load, se
-- já estiver ligado) e `stop` quando desliga. Mudou campo com ele ligado: stop e
-- start de novo, pra valer a lista ou o valor novo. Comando e tecla não dá pra
-- desregistrar no FiveM: ficam registrados e checam Mri.enabled por dentro.

local lifecycles = {}

---@param id string
---@param start fun(cfg: table)
---@param stop fun()
function Mri.lifecycle(id, start, stop)
    lifecycles[id] = lifecycles[id] or {}
    local entry = { start = start, stop = stop }
    table.insert(lifecycles[id], entry)
    if Mri.enabled(id) then
        CreateThread(function()
            local ok, err = pcall(start, Mri.cfg(id))
            if ok then entry.running = true else print(('^1[mri_Qbox] %s: falha ao ligar: %s^7'):format(id, err)) end
        end)
    end
end

local function snapshot(value)
    return json.encode(value or {})
end

-- Chamado pelo lado (server/config.lua ou client/config.lua) quando a config de
-- um módulo muda; `previous` é a config antiga.
---@param id string
---@param previous table|nil
function Mri.applyChange(id, previous)
    local list = lifecycles[id]
    if not list then return end
    local now = Mri.cfg(id)
    if snapshot(now) == snapshot(previous) then return end
    for _, entry in ipairs(list) do
        if entry.running then
            pcall(entry.stop)
            entry.running = false
        end
        if now.enabled then
            local ok, err = pcall(entry.start, now)
            if ok then entry.running = true else print(('^1[mri_Qbox] %s: falha ao ligar: %s^7'):format(id, err)) end
        end
    end
end

-- Desliga tudo quando o resource para (o olhinho e os ganchos de outros resources
-- não somem sozinhos).
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    for _, list in pairs(lifecycles) do
        for _, entry in ipairs(list) do
            if entry.running then pcall(entry.stop) end
        end
    end
end)

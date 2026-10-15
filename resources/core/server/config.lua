-- Config dos módulos no server: padrões + data/config.json, publicada em
-- GlobalState pros clients. O painel (server/panel.lua) grava por Mri.save.

local FILE = 'data/config.json'

local function load()
    local raw = LoadResourceFile(GetCurrentResourceName(), FILE)
    if not raw or raw == '' then return {} end
    local ok, data = pcall(json.decode, raw)
    if not ok or type(data) ~= 'table' then
        lib.print.warn(('[mri_Qbox] %s inválido; usando os padrões dos módulos'):format(FILE))
        return {}
    end
    return type(data.modules) == 'table' and data.modules or {}
end

local saved = load()

-- Campos que saíram de um módulo pra um módulo próprio: o que o dono já tinha mudado vai junto.
local MOVED = {
    { from = 'worldmap', to = 'clearparking', key = 'clearGenerators' },
    { from = 'worldmap', to = 'anticheat', key = 'blockedModels' },
}
for _, move in ipairs(MOVED) do
    local old = saved[move.from]
    if type(old) == 'table' and old[move.key] ~= nil and not saved[move.to] then
        saved[move.to] = { enabled = old.enabled, [move.key] = old[move.key] }
    end
end

Mri.current = {}
for _, id in ipairs(Mri.order) do
    Mri.current[id] = Mri.merge(id, saved[id])
end
GlobalState:set(Mri.STATE_KEY, Mri.current, true)

---Grava os valores do módulo (já validados) e replica.
---@param id string
---@param values table
function Mri.save(id, values)
    local previous = Mri.current[id]
    saved[id] = values
    Mri.current[id] = Mri.merge(id, values)
    Mri.applyChange(id, previous)
    SaveResourceFile(GetCurrentResourceName(), FILE, json.encode({ modules = saved }, { indent = true }), -1)
    GlobalState:set(Mri.STATE_KEY, Mri.current, true)
    TriggerEvent('mri_Qbox:configChanged', id, Mri.current[id])
end

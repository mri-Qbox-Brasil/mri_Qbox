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

-- GTA police lived in four modules: gtapolice starts with what they did (a module off meant GTA's own behavior).
local COP_PEDS = { s_m_y_ranger_01 = true, s_m_y_sheriff_01 = true, s_m_y_cop_01 = true, s_f_y_sheriff_01 = true, s_f_y_cop_01 = true, s_m_y_hwaycop_01 = true }

local function migrateGtaPolice()
    if saved.gtapolice then return end
    local police = {}
    local services, hud, map, density = saved.gtaservices, saved.hudcomponents, saved.worldmap, saved.density
    if type(services) == 'table' then
        if services.enabled == false then
            police.police, police.roadblock, police.maxWantedLevel = true, true, 5
        else
            police.police, police.roadblock, police.maxWantedLevel = services.police, services.roadblock, services.maxWantedLevel
        end
    end
    if type(hud) == 'table' then
        if hud.enabled == false then police.hideWanted = false else police.hideWanted = hud.hideWanted end
    end
    if type(density) == 'table' then
        if density.enabled == false then police.respectPlayer = false else police.respectPlayer = density.npcRespect end
    end
    if type(map) == 'table' then
        if map.enabled == false then
            police.parkedCars = true
        elseif type(map.scenarioTypes) == 'table' then
            local kept, removed = {}, false
            for _, name in ipairs(map.scenarioTypes) do
                if type(name) == 'string' and name:find('^WORLD_VEHICLE_POLICE') then removed = true else kept[#kept + 1] = name end
            end
            map.scenarioTypes = kept
            police.parkedCars = not removed
        end
    end
    -- the cops left the anticheat list for the police module, which blocks them only while the GTA police is off
    local anticheat = saved.anticheat
    if type(anticheat) == 'table' and type(anticheat.blockedModels) == 'table' then
        local kept = {}
        for _, name in ipairs(anticheat.blockedModels) do
            if not COP_PEDS[type(name) == 'string' and name:lower() or ''] then kept[#kept + 1] = name end
        end
        anticheat.blockedModels = kept
    end
    if next(police) then
        police.enabled = true
        saved.gtapolice = police
    end
end
migrateGtaPolice()

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

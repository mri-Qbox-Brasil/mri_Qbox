-- Passport = players.id, kept by qbx_core but never loaded; ox_lib resolves playerId params through it
local COMMANDS_KEY = 'mri:passportCommands'

local running = false
-- source -> passport; the statebag is for display only, a client can write its own
---@type table<integer, integer>
local passports = {}

---@param source integer
---@param passport integer?
local function setPassport(source, passport)
    passports[source] = passport
    Player(source).state:set('passport', passport, true)
end

---@param citizenId string
---@return integer?
local function fetchPassport(citizenId)
    return MySQL.scalar.await('SELECT id FROM players WHERE citizenid = ?', { citizenId })
end

---@param source integer
local function assign(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    setPassport(source, fetchPassport(player.PlayerData.citizenid))
end

-- sent by the multichar after load and after creation, when the players row already exists
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    if running then assign(source) end
end)

AddEventHandler('qbx_core:server:playerLoggedOut', function(source)
    setPassport(source, nil)
end)

AddEventHandler('playerDropped', function()
    passports[source] = nil
end)

Mri.lifecycle('passport', function(cfg)
    running = true
    GlobalState[COMMANDS_KEY] = cfg.commands == true
    for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
        assign(player.PlayerData.source)
    end
end, function()
    running = false
    GlobalState[COMMANDS_KEY] = false
    for source in pairs(passports) do
        setPassport(source, nil)
    end
end)

---@param source integer
---@return integer?
local function getPlayerPassport(source)
    return passports[tonumber(source)]
end

---@param passport integer
---@return integer? source
local function getPlayerByPassport(passport)
    passport = tonumber(passport)
    if not passport then return end
    for source, id in pairs(passports) do
        if id == passport then return source end
    end
end

-- works offline too (ban, give item to someone who left)
---@param passport integer
---@return string? citizenId
local function getCitizenIdByPassport(passport)
    passport = tonumber(passport)
    if not passport then return end
    return MySQL.scalar.await('SELECT citizenid FROM players WHERE id = ?', { passport })
end

exports('GetPlayerPassport', getPlayerPassport)
exports('GetPlayerByPassport', getPlayerByPassport)
exports('GetCitizenIdByPassport', getCitizenIdByPassport)

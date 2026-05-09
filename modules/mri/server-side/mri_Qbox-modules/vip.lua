local _raw = LoadResourceFile(GetCurrentResourceName(), 'data/vip.json')
local VipCfg = _raw and json.decode(_raw) or {}
if not VipCfg.Enable then return end

-- ─── Runtime rank table (seeded from shared/vip.json) ────────────────────────

local ranks = {}
for _, r in ipairs(VipCfg.Ranks) do
    ranks[#ranks + 1] = {
        id             = r.id,
        label          = r.label,
        color          = r.color          or '#FFD700',
        salary         = r.salary         or 0,
        salaryType     = r.salaryType     or 'cash',
        inventoryLimit = r.inventoryLimit or 0,
    }
end

local function findRank(id)
    for _, r in ipairs(ranks) do
        if r.id == id then return r end
    end
    return nil
end

-- ─── Persistência em shared/vip.json ─────────────────────────────────────────

local function persistVipConfig()
    local data = {
        Enable                  = VipCfg.Enable,
        PaycheckInterval        = VipCfg.PaycheckInterval,
        CoinType                = VipCfg.CoinType,
        ExpirationCheckInterval = VipCfg.ExpirationCheckInterval,
        Ranks                   = ranks,
    }
    local encoded = json.encode(data, { indent = true })
    local ok = SaveResourceFile(GetCurrentResourceName(), 'data/vip.json', encoded, -1)
    if not ok then
        print('[VIP] Erro: não foi possível salvar shared/vip.json')
        return false
    end
    return true
end

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function fetchPlayers()
    return MySQL.query.await("SELECT citizenid FROM players")
end

local function sendNotification(source, type, message)
    if tonumber(source) and tonumber(source) > 0 then
        lib.notify(source, { title = "VIPs", type = type, description = message })
    else
        print(string.format("[CMD] [VIP] %s: %s", type, message))
    end
end

local function updateInventoryWeight(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local rankId = player.PlayerData.metadata['vip']
    if not rankId then return end
    local rank = findRank(rankId)
    if not rank then return end
    print(string.format("[VIP] atualizando inventário → %d KG", rank.inventoryLimit))
    exports.ox_inventory:SetMaxWeight(source, rank.inventoryLimit * 1000)
end

-- ─── Verificação de expiração VIP ────────────────────────────────────────────

local function removeExpiredVip(player, isOnline, citizenid, expiredOffline)
    local rankId = player.PlayerData.metadata['vip']
    local rank   = findRank(rankId)
    local label  = rank and rank.label or rankId

    if isOnline then
        local src = player.PlayerData.source
        lib.removePrincipal(src, rankId)
        player.Functions.SetMetaData('vip', nil)
        player.Functions.SetMetaData('vip_expires', nil)
        local msg = expiredOffline
            and string.format('Seu cargo %s expirou enquanto você estava offline.', label)
            or  string.format('Seu cargo %s expirou e foi removido automaticamente.',  label)
        lib.notify(src, { title = 'VIP Expirado', type = 'warning', description = msg, duration = 10000 })
    else
        player.PlayerData.metadata['vip']         = nil
        player.PlayerData.metadata['vip_expires'] = nil
        exports.qbx_core:SaveOffline(player.PlayerData)
    end

    print(string.format('[VIP] Cargo "%s" expirado removido de %s (online: %s)',
        rankId, citizenid, tostring(isOnline)))
end

local function checkVipExpiration()
    local now     = os.time()
    local players = fetchPlayers()
    for _, v in pairs(players) do
        local online = exports.qbx_core:GetPlayerByCitizenId(v.citizenid)
        local player = online or exports.qbx_core:GetOfflinePlayer(v.citizenid)
        if not player then goto continue end

        local rankId  = player.PlayerData.metadata['vip']
        local expires = player.PlayerData.metadata['vip_expires']

        if rankId and expires and expires > 0 and now >= expires then
            removeExpiredVip(player, online ~= nil, v.citizenid, false)
        end

        ::continue::
    end
end

CreateThread(function()
    local interval = 60000 * (VipCfg.ExpirationCheckInterval or 5)
    while true do
        Wait(interval)
        checkVipExpiration()
    end
end)

-- ─── getVipPlayers ────────────────────────────────────────────────────────────

local function getMenuEntries()
    local result = {}
    local onlineVip, offlineVip = 0, 0
    local players = fetchPlayers()
    for _, v in pairs(players) do
        local online = exports.qbx_core:GetPlayerByCitizenId(v.citizenid)
        local player = online or exports.qbx_core:GetOfflinePlayer(v.citizenid)
        if player then
            local rankId = player.PlayerData.metadata['vip']
            if rankId then
                local rank     = findRank(rankId)
                local isOnline = (online ~= nil)
                if isOnline then onlineVip = onlineVip + 1
                else offlineVip = offlineVip + 1 end
                result[#result + 1] = {
                    citizenid      = v.citizenid,
                    name           = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                    rankId         = rankId,
                    expiration     = player.PlayerData.metadata['vip_expires'] or 0,
                    salary         = rank and rank.salary         or 0,
                    salaryType     = rank and rank.salaryType     or 'cash',
                    inventoryLimit = rank and rank.inventoryLimit or 0,
                    online         = isOnline,
                    source         = isOnline and player.PlayerData.source or nil,
                }
            end
        end
    end
    return { vip = result, offlineVip = offlineVip, onlineVip = onlineVip }
end

lib.callback.register('mri_Qbox:server:getVip', function(source)
    return getMenuEntries()
end)

-- ─── Comando /vipadm (legado) ─────────────────────────────────────────────────

local function executeVip(source, args)
    if not args.id   then sendNotification(source, "error", "Id não informado.")   return end
    if not args.tipo then sendNotification(source, "error", "Tipo não informado.") return end
    if args.tipo == 'add' and not args.tier then
        sendNotification(source, "error", "Vip não informado.")
        return
    end
    local player = exports.qbx_core:GetPlayer(args.id)
    if not player then
        sendNotification(source, "error", "Nenhum player encontrado.")
        return
    end
    if args.tipo == 'add' then
        lib.addPrincipal(args.id, args.tier)
        player.Functions.SetMetaData('vip', args.tier)
        sendNotification(args.id, "success", string.format("Recebeu o vip: %s", args.tier))
    elseif args.tipo == 'rem' and player.PlayerData.metadata['vip'] then
        local old = player.PlayerData.metadata['vip']
        lib.removePrincipal(args.id, old)
        player.Functions.SetMetaData('vip', nil)
        sendNotification(args.id, "info", string.format("Vip: %s removido", old))
    end
    sendNotification(source, "success",
        string.format("Permissão %s %s a: %d",
            args.tier or player.PlayerData.metadata['vip'],
            (args.tipo == 'add' and "concedida") or "revogada",
            args.id))
    updateInventoryWeight(args.id)
    return true
end

exports("VipAdm", executeVip)

lib.addCommand('vipadm', {
    help   = 'Dar permissão ao vip permanentemente',
    params = {
        { name = 'id',   type = 'playerId', help = 'Source ID do player' },
        { name = 'tipo', type = 'string',   help = 'Tipo de permissão (add ou rem)' },
        { name = 'tier', type = 'string',   help = 'Tier de vip', optional = true },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    executeVip(source, args)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    local rankId  = player.PlayerData.metadata['vip']
    if not rankId then return end
    local expires = player.PlayerData.metadata['vip_expires']
    if expires and expires > 0 and os.time() >= expires then
        removeExpiredVip(player, true, player.PlayerData.citizenid, true)
        return
    end
    print(string.format("[VIP] restaurando principal '%s' para '%s'",
        rankId, player.PlayerData.charinfo.firstname))
    lib.addPrincipal(source, rankId)
    updateInventoryWeight(source)
end)

RegisterNetEvent('mri_Qbox:server:manageVip', function(data)
    local src    = source
    local player = exports.qbx_core:GetOfflinePlayer(data.citizenId)
    if not player then return end
    local identifier   = player.PlayerData.license
    local targetSource = exports.qbx_core:GetSource(identifier)
    local targetPlayer = targetSource > 0 and exports.qbx_core:GetPlayer(targetSource)
    if data.action == 'remove' then
        local old = player.PlayerData.metadata['vip']
        player.PlayerData.metadata['vip']         = nil
        player.PlayerData.metadata['vip_expires'] = nil
        if targetSource > 0 and targetPlayer then
            if old then lib.removePrincipal(targetSource, old) end
            targetPlayer.Functions.SetMetaData('vip', nil)
            targetPlayer.Functions.SetMetaData('vip_expires', nil)
        end
    elseif data.action == 'add' then
        player.PlayerData.metadata['vip'] = data.role
        if targetSource > 0 and targetPlayer then
            lib.addPrincipal(targetSource, data.role)
            targetPlayer.Functions.SetMetaData('vip', data.role)
        end
    end
    exports.qbx_core:SaveOffline(player.PlayerData)
    sendNotification(src, "success",
        string.format("Permissão '%s' %s a: %s",
            data.role or '',
            (data.action == 'add' and "concedida") or "revogada",
            data.name or data.citizenId))
end)

-- ─── Implementações reutilizáveis ────────────────────────────────────────────

local function doCreateRank(data)
    if not data.id or data.id == '' then return false, nil end
    if findRank(data.id) then return false, nil end
    local rank = {
        id             = data.id,
        label          = data.label          or data.id,
        color          = data.color          or '#FFD700',
        salary         = data.salary         or 0,
        salaryType     = data.salaryType     or 'cash',
        inventoryLimit = data.inventoryLimit or 0,
    }
    ranks[#ranks + 1] = rank
    persistVipConfig()
    return true, rank
end

local function doUpdateRank(data)
    local rank = findRank(data.id)
    if not rank then return false end
    rank.label          = data.label          or rank.label
    rank.color          = data.color          or rank.color
    rank.salary         = data.salary         ~= nil and data.salary         or rank.salary
    rank.salaryType     = data.salaryType     or rank.salaryType
    rank.inventoryLimit = data.inventoryLimit ~= nil and data.inventoryLimit or rank.inventoryLimit
    persistVipConfig()
    return true
end

local function doDeleteRank(data)
    for i, r in ipairs(ranks) do
        if r.id == data.id then
            table.remove(ranks, i)
            persistVipConfig()
            return true
        end
    end
    return false
end

local function doAddVip(data)
    local rank = findRank(data.rankId)
    if not rank then return false, nil end
    local online = exports.qbx_core:GetPlayerByCitizenId(data.citizenID)
    local playerRow
    if online then
        local src = online.PlayerData.source
        lib.addPrincipal(src, rank.id)
        online.Functions.SetMetaData('vip', rank.id)
        if data.dataExpiracao and data.dataExpiracao > 0 then
            online.Functions.SetMetaData('vip_expires', data.dataExpiracao)
        end
        updateInventoryWeight(src)
        playerRow = {
            citizenid      = data.citizenID,
            name           = online.PlayerData.charinfo.firstname .. ' ' .. online.PlayerData.charinfo.lastname,
            rankId         = rank.id,
            expiration     = data.dataExpiracao or 0,
            salary         = rank.salary,
            salaryType     = rank.salaryType,
            inventoryLimit = rank.inventoryLimit,
            online         = true,
            source         = online.PlayerData.source,
        }
    else
        local offline = exports.qbx_core:GetOfflinePlayer(data.citizenID)
        if not offline then return false, nil end
        offline.PlayerData.metadata['vip'] = rank.id
        if data.dataExpiracao and data.dataExpiracao > 0 then
            offline.PlayerData.metadata['vip_expires'] = data.dataExpiracao
        end
        exports.qbx_core:SaveOffline(offline.PlayerData)
        playerRow = {
            citizenid      = data.citizenID,
            name           = offline.PlayerData.charinfo.firstname .. ' ' .. offline.PlayerData.charinfo.lastname,
            rankId         = rank.id,
            expiration     = data.dataExpiracao or 0,
            salary         = rank.salary,
            salaryType     = rank.salaryType,
            inventoryLimit = rank.inventoryLimit,
            online         = false,
        }
    end
    return true, playerRow
end

local function doRemoveVipPlayer(data)
    local online = exports.qbx_core:GetPlayerByCitizenId(data.citizenID)
    if online then
        local src = online.PlayerData.source
        local vip = online.PlayerData.metadata['vip']
        if vip then lib.removePrincipal(src, vip) end
        online.Functions.SetMetaData('vip', nil)
        online.Functions.SetMetaData('vip_expires', nil)
        updateInventoryWeight(src)
        return 'ok'
    else
        local offline = exports.qbx_core:GetOfflinePlayer(data.citizenID)
        if not offline then return false end
        offline.PlayerData.metadata['vip']         = nil
        offline.PlayerData.metadata['vip_expires'] = nil
        exports.qbx_core:SaveOffline(offline.PlayerData)
        return 'ok'
    end
    return 'error'
end

local function doUpdateVipPlayer(data)
    local rank = findRank(data.rankId)
    if not rank then return false, { code = 'rank_not_found' } end
    local online = exports.qbx_core:GetPlayerByCitizenId(data.citizenID)
    if online then
        local src    = online.PlayerData.source
        local oldVip = online.PlayerData.metadata['vip']
        if oldVip then lib.removePrincipal(src, oldVip) end
        lib.addPrincipal(src, rank.id)
        online.Functions.SetMetaData('vip', rank.id)
        if data.dataExpiracao and data.dataExpiracao > 0 then
            online.Functions.SetMetaData('vip_expires', data.dataExpiracao)
        end
        updateInventoryWeight(src)
    else
        local offline = exports.qbx_core:GetOfflinePlayer(data.citizenID)
        if not offline then return false, { code = 'player_not_found' } end
        offline.PlayerData.metadata['vip'] = rank.id
        if data.dataExpiracao and data.dataExpiracao > 0 then
            offline.PlayerData.metadata['vip_expires'] = data.dataExpiracao
        end
        exports.qbx_core:SaveOffline(offline.PlayerData)
    end
    return true
end

-- ─── Exports para mri_Qadmin ──────────────────────────────────────────────────

exports('getRanks',            function()     return ranks                    end)
exports('createRank',          function(data) return doCreateRank(data)       end)
exports('updateRank',          function(data) return doUpdateRank(data)       end)
exports('deleteRank',          function(data) return doDeleteRank(data)       end)
exports('getVipPlayers',       function()     return getMenuEntries()          end)
exports('addVip',              function(data) return doAddVip(data)            end)
exports('removeVipPlayer',     function(data) return doRemoveVipPlayer(data)   end)
exports('updateVipPlayer',     function(data) return doUpdateVipPlayer(data)   end)
exports('checkVipExpiration',  function()     checkVipExpiration()             end)


-- ─── Paycheck ─────────────────────────────────────────────────────────────────

local function sendPaycheck(player, rank)
    player.Functions.AddMoney(rank.salaryType, rank.salary)
    sendNotification(player.PlayerData.source, "success",
        string.format("Você recebeu seu salário VIP de %s %s", VipCfg.CoinType, rank.salary))
end

CreateThread(function()
    if VipCfg.PaycheckInterval <= 0 then return end
    local interval = 60000 * VipCfg.PaycheckInterval
    while true do
        Wait(interval)
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            local rankId = player.PlayerData.metadata['vip']
            if rankId then
                local rank = findRank(rankId)
                if rank and rank.salary > 0 then
                    sendPaycheck(player, rank)
                end
            end
        end
    end
end)

if Config.Core == 'esx' then
    ESX = exports['es_extended']:getSharedObject() 
elseif Config.Core == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

GetPlayerId = function(id)
    return Config.Core == 'esx' and ESX.GetPlayerFromId(id) or Config.Core == 'qb' and QBCore.Functions.GetPlayer(id)
end

GetSource = function(Player)
    return Config.Core == 'esx' and Player.source or Config.Core == 'qb' and Player.PlayerData.source
end

GetCoords = function(target)
    local Playerpos = GetEntityCoords(GetPlayerPed(source))
    local Targetpos = GetEntityCoords(GetPlayerPed(target))
    return #(Playerpos - Targetpos) < 3.0
end

MoneyAction = function(Player, amount, type)
    if type == 'get' then
        return Config.Core == 'esx' and Player.getAccount('money').money or Config.Core == 'qb' and Player.Functions.GetMoney('cash')
    elseif type == 'add' then
        return Config.Core == 'esx' and Player.addAccountMoney('money', amount) or Config.Core == 'qb' and Player.Functions.AddMoney('cash', amount, '')
    elseif type == 'remove' then
        return Config.Core == 'esx' and Player.removeAccountMoney('money', amount) or Config.Core == 'qb' and Player.Functions.RemoveMoney('cash', amount, '')
    end
end

lib.callback.register('ap_givecash:getPlayerMoney', function(source)
    return MoneyAction(GetPlayerId(source), nil, 'get')
end)

RegisterServerEvent('ap_givecash:sendMoney')
AddEventHandler('ap_givecash:sendMoney', function(data)
	local Player = GetPlayerId(source)
	local Target = GetPlayerId(data.target)
    if Player == nil or Target == nil then
        TriggerClientEvent('ap_givecash:sendNotify', GetSource(Player), 'ID '..GetSource(Target)..' Offline!', 'error')
        return
    end
    if Player == Target then return end
    if not GetCoords(data.target) then return end
    MoneyAction(Player, data.amount, 'remove')
    MoneyAction(Target, data.amount, 'add')
    TriggerClientEvent('ap_givecash:sendNotify', GetSource(Player), 'You given $' .. lib.math.groupdigits(data.amount) .. (data.note ~= '' and '  \nNotes : ' .. data.note or ''), 'success')
    TriggerClientEvent('ap_givecash:sendNotify', GetSource(Target), 'You receive money amounting to $' .. lib.math.groupdigits(data.amount) .. (data.note ~= '' and '  \nNotes : ' .. data.note or ''), 'success')
end)

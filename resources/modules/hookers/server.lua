local PRICES <const> = { oral = 'priceOral', sex = 'priceSex' }

lib.callback.register('mri_Qbox:hookers:pay', function(source, service)
    local cfg = Mri.cfg('hookers')
    if not cfg.enabled or not PRICES[service] then return false end
    if not cfg.payment then return true end
    local price = math.floor(tonumber(cfg[PRICES[service]]) or 0)
    if price <= 0 then return true end
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    return player.Functions.RemoveMoney(cfg.moneyType == 'bank' and 'bank' or 'cash', price, 'hookers') == true
end)

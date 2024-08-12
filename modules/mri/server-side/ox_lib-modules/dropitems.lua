if not cfg.dropitems then return end

local dropItems = cfg.dropitems_table


exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= 'newdrop' then return end

    local item = payload.fromSlot
    local items = { { item.name, payload.count, item.metadata } }
    local dropId = exports.ox_inventory:CustomDrop(item.label, items,
        GetEntityCoords(GetPlayerPed(payload.source)), 1, item.weight, nil, dropItems[item.name])

    if not dropId then return end

    CreateThread(function()
        exports.ox_inventory:RemoveItem(payload.source, item.name, payload.count, nil, item.slot)
        Wait(0)
        exports.ox_inventory:forceOpenInventory(payload.source, 'drop', dropId)
    end)

    return false
end, {
    itemFilter = dropItems,
    typeFilter = { player = true }
})
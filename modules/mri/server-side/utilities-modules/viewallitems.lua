local bannedItems = {
    ["identification"] = true
}

lib.addCommand('viewallitems', {
    help = "Views all the items thats currently on the server",
    restricted = "group.admin"
}, function(source)
    local items = exports.ox_inventory:Items()
    local showItems = {}
    local weight = 0
    local slots = 0

    for k, v in pairs(items) do
        if not bannedItems[k] then
            slots += 1
            weight += v.weight
            showItems[slots] = { k, 1 }
        end
    end

    local stash = exports.ox_inventory:CreateTemporaryStash({
        label = 'CheckItems',
        slots = slots,
        maxWeight = weight,
        items = showItems
    })

    TriggerClientEvent('ox_inventory:openInventory', source, 'stash', stash)
end)
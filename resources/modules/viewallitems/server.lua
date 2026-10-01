-- /viewallitems: abre um baú temporário com um de cada item do ox_inventory.
-- Comandos ficam registrados (o FiveM não remove comando); desligado no painel,
-- avisam e não fazem nada.
local function guarded(fn)
    return function(source, ...)
        if not Mri.enabled('viewallitems') then
            if source and source > 0 then
                lib.notify(source, { type = 'error', description = 'Comando desligado no painel do mri_Qbox.' })
            end
            return
        end
        return fn(source, ...)
    end
end

local bannedItems = {
    ["identification"] = true
}

lib.addCommand('viewallitems', {
    help = "Views all the items thats currently on the server",
    restricted = "group.admin"
}, guarded(function(source)
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
end))
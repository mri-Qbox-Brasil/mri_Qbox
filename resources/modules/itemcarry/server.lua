-- Ganchos do ox_inventory entram e saem com o módulo (Mri.lifecycle no fim).
local CARRY_ITEMS = require 'resources.modules.itemcarry.items'

local ox_inventory = exports.ox_inventory

local hooks = {}

local function registerHooks()
hooks[#hooks + 1] = ox_inventory:registerHook('createItem', function(payload)

      local carryData = CARRY_ITEMS[payload?.item?.name]
      local plyid = type(payload.inventoryId) == "number" and payload.inventoryId

      if not carryData or not plyid then return end

      local plyState = Player(plyid).state

    if plyState.carryItem then
        lib.notify(plyid, {
            title = 'Inventory',
            description = 'You are already carrying something!',
            type = 'error'
        })
        local coords = GetEntityCoords(GetPlayerPed(plyid))
        CreateThread(function()
            Wait(300)
            local success = ox_inventory:RemoveItem(plyid, payload?.item?.name, payload?.count, payload?.metadata)
            if success then
                ox_inventory:CustomDrop(payload?.item?.label, {{payload?.item?.name, payload?.count, payload?.metadata}}, coords, 1, nil, nil, carryData.prop.model)
            end
        end)
    end

end, {})

hooks[#hooks + 1] = ox_inventory:registerHook('swapItems', function(payload)
    if payload.toInventory ~= payload.fromInventory and payload.toInventory == payload.source then
        local item = payload.fromSlot
        local carryData = CARRY_ITEMS[item.name]

        if carryData then
            local plyState = Player(payload.source).state

            if plyState.carryItem then
                lib.notify(payload.source, {
                    title = 'Inventory',
                    description = 'You are already carrying something!',
                    type = 'error'
                })
                 return false
            end
        end
    end
end, {})
end

local function findCarryItem(source)
    CreateThread(function ()
        Wait(500) --wait for inventory to update after whatever hook
        local playerState = Player(source).state
        local playerItems = exports.ox_inventory:GetInventoryItems(source)
        local carryData = nil

        for i, v in pairs(playerItems) do
            local itemData = v
            if itemData and CARRY_ITEMS[itemData.name] then
                carryData = CARRY_ITEMS[itemData.name]
                break
            end
        end

        if carryData then
            playerState:set("carryItem", carryData, true)
        end

    end)
end


RegisterNetEvent("carryItem:onUpdateInventory", function()
    if not Mri.enabled('itemcarry') then return end
    findCarryItem(source)
end)

Mri.lifecycle('itemcarry', function()
    registerHooks()
    -- quem já tem item de carregar no inventário passa a carregar
    for _, src in ipairs(GetPlayers()) do findCarryItem(tonumber(src)) end
end, function()
    for _, id in ipairs(hooks) do ox_inventory:removeHooks(id) end
    hooks = {}
    for _, src in ipairs(GetPlayers()) do
        Player(tonumber(src)).state:set('carryItem', nil, true)
    end
end)

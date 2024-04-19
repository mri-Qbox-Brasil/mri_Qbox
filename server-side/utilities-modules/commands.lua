lib.addCommand('tpway', {
    help = "Teleporta você para a posição marcada no mapa",
    -- restricted = "group.admin"
}, function(source)
    TriggerClientEvent("mri_Qbox:ExecuteCommand",source,"tpm")
end)

lib.addCommand('god', {
    help = "Revive um jogador ou você mesmo",
    -- restricted = "group.admin"
    params = {
        { name = 'id', help = "Digite o id do player", type = 'playerId', optional = true },
    }
}, function(source,args)
    TriggerClientEvent("mri_Qbox:ExecuteCommand",source,"revive",args.id)
end)

-- lib.addCommand({'item'}, {
-- 	help = 'Gives an item to a player with the given id',
-- 	params = {
-- 		{ name = 'target', type = 'playerId', help = 'The player to receive the item' },
-- 		{ name = 'item', type = 'string', help = 'The name of the item' },
-- 		{ name = 'count', type = 'number', help = 'The amount of the item to give', optional = true },
-- 		{ name = 'type', help = 'Sets the "type" metadata to the value', optional = true },
-- 	},
-- 	-- restricted = 'group.admin',
-- }, function(source, args)
-- 	local item = Items(args.item)

-- 	if item then
-- 		local inventory = Inventory(args.target) --[[@as OxInventory]]
-- 		local count = args.count or 1
-- 		local success, response = Inventory.AddItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type })

-- 		if not success then
-- 			return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, args.target, response))
-- 		end

-- 		source = Inventory(source) or { label = 'console', owner = 'console' }

-- 		if server.loglevel > 0 then
-- 			lib.logger(source.owner, 'admin', ('"%s" gave %sx %s to "%s"'):format(source.label, count, item.name, inventory.label))
-- 		end
-- 	end
-- end)

lib.addCommand('generatecarlist', {
    help = 'Generate and save vehicle data for available models on the client',
    params = {
        { name = 'processAll', help = 'Include vehicles with existing data (in the event of updated vehicle stats)', optional = true }
    },
    restricted = 'group.admin'
}, function(source, args)
    local vehicleData = lib.callback.await('Renewed-Vehicleparser:client:parsevehicles', source, args.processAll)

    if vehicleData and next(vehicleData) then
        SaveResourceFile(cache.resource, 'data/items.lua', table.concat(vehicleData), -1)
    end
end)
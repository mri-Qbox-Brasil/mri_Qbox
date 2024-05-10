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
    TriggerClientEvent("mri_Qbox:ExecuteCommand",source,"revive", args.id)
end)

lib.addCommand({'item'}, {
	help = 'Dá o item para o player id',
	params = {
        { name = 'item', type = 'string', help = 'O nome do item' },
        { name = 'count', type = 'number', help = 'A quantidade de item para enviar', optional = true },
		{ name = 'target', type = 'playerId', help = 'O player que irá receber o item', optional = true },
		{ name = 'type', help = 'Define o "type" de metadados do item', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = true --Items(args.item)

	if item then
        -- local inventory = Inventory(args.target) --[[@as OxInventory]]
        local inventory = args.target or source
        local count = args.count or 1
        local success, response = exports.ox_inventory:AddItem(inventory, args.item, count, args.type and { type = tonumber(args.type) or args.type })

        if not success then
            return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, args.target, response))
        end

        -- source = Inventory(source) or { label = 'console', owner = 'console' }

        -- if server.loglevel > 0 then
        --     lib.logger(source.owner, 'admin', ('"%s" gave %sx %s to "%s"'):format(source.label, count, item.name, inventory.label))
        -- end
	end
end)

lib.addCommand('tuning', {
    help = 'Tune seu veículo',
    restricted = 'group.admin'
}, function(source)
    lib.callback("vehtuning", source)
end)

lib.addCommand('menu_admin', {
    help = 'Abrir menu Admin (atalho F10)',
    restricted = 'group.admin'
}, function(source)
    lib.callback('AbrirMenuAdmin', source)
end)

lib.addCommand('customs', {
    help = 'Tunar seu veículo atual',
    restricted = 'group.admin'
}, function(source)
    lib.callback('mri_Qbox:customs:client', source)
end)
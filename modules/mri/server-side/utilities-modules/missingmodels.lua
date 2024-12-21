lib.addCommand('models', {
    help = 'List all missing models',
    restricted = 'group.admin'
}, function(source)
    local models = GetAllVehicleModels()
    local missingVehicles = {}
    for i = 1, #models do
        if not VehicleList[models[i]] then
            missingVehicles[#missingVehicles+1] = models[i]
        end
    end
    lib.setClipboard(json.encode(missingVehicles))
end)
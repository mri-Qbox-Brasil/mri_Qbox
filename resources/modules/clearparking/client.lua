Mri.lifecycle('clearparking', function(cfg)
    for _, area in ipairs(type(cfg.clearGenerators) == 'table' and cfg.clearGenerators or {}) do
        local x, y, z, r = tonumber(area.x), tonumber(area.y), tonumber(area.z), tonumber(area.radius) or 300
        if x and y and z then RemoveVehiclesFromGeneratorsInArea(x - r, y - r, z - r, x + r, y + r, z + r) end
    end
end, function() end)

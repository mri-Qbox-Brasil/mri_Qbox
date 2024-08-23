cfg_itemcollection = {}
for _, data in pairs(exports.ox_inventory:Items()) do
    if data.prop and type(data.prop) == "table" then
        for i=1, #data.prop do
            local prop = data.prop[i]
            cfg_itemcollection[prop] = data.name
        end
    elseif data.prop then
        cfg_itemcollection[data.prop] = data.name
    end
end
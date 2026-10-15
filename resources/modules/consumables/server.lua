-- Same as qbx_consumables, event, callback and export names included (exports under the old qbx_smallresources name).
-- qbx_core has no way to unregister a usable item, so each callback checks the module and its lists when used.

local DRUGS = {
    joint = 'consumables:client:UseJoint',
    cokebaggy = 'consumables:client:Cokebaggy',
    crack_baggy = 'consumables:client:Crackbaggy',
    xtcbaggy = 'consumables:client:EcstasyBaggy',
    oxy = 'consumables:client:oxy',
    meth = 'consumables:client:meth',
}
local LOCKPICKS = { lockpick = false, advancedlockpick = true }

local function option(key)
    return Mri.enabled('consumables') and Mri.cfg('consumables')[key] == true
end

local function isFiniteNumber(value)
    return type(value) == 'number' and value == value and value > -math.huge and value < math.huge
end

-- the statebag and the metadata both, like the qbx_core issue #470 hotfix
local function setNeed(source, meta, amount)
    amount = lib.math.clamp(amount, 0, 100)
    Player(source).state[meta] = amount
    local player = exports.qbx_core:GetPlayer(source)
    if player then player.Functions.SetMetaData(meta, amount) end
end

local function setHunger(source, amount) setNeed(source, 'hunger', amount) end
local function addHunger(source, amount) setNeed(source, 'hunger', (Player(source).state.hunger or 0) + amount) end
local function setThirst(source, amount) setNeed(source, 'thirst', amount) end
local function addThirst(source, amount) setNeed(source, 'thirst', (Player(source).state.thirst or 0) + amount) end

local function relieveStress(source, relief)
    local default = Mri.cfg('consumables').defaultStressRelief or { min = 0, max = 4 }
    local min = type(relief) == 'table' and type(relief.min) == 'number' and relief.min or default.min
    local max = type(relief) == 'table' and relief.max or default.max
    local amount = math.random(min, max)
    local state = Player(source).state
    state:set('stress', lib.math.clamp((state.stress or 0) - amount, 0, 100), true)
    if amount < 0 then
        exports.qbx_core:Notify(source, 'Sentindo mais estresse!', 'inform', 2500, nil, nil, { '#141517', '#ffffff' }, 'brain', '#C53030')
    else
        exports.qbx_core:Notify(source, 'Sentindo menos estresse!', 'inform', 2500, nil, nil, { '#141517', '#ffffff' }, 'brain', '#0F52BA')
    end
end

-- category -> client callback and which need it fills
local KINDS = {
    alcohol = { callback = 'consumables:client:DrinkAlcohol', fill = addThirst },
    drink = { callback = 'consumables:client:Drink', fill = addThirst },
    food = { callback = 'consumables:client:Eat', fill = addHunger },
}

local registered = {}

local function useConsumable(source, item)
    local cfg = Mri.cfg('consumables')
    for kind, info in pairs(KINDS) do
        local params = type(cfg[kind]) == 'table' and cfg[kind][item.name]
        if params then
            local done
            if kind == 'alcohol' then
                done = lib.callback.await(info.callback, source, params.alcoholLevel, params.anim, params.prop)
            else
                done = lib.callback.await(info.callback, source, params.anim, params.prop)
            end
            if not done or not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end
            relieveStress(source, params.stressRelief)
            info.fill(source, math.random(params.min, params.max))
            if item.name == 'water_bottle' and cfg.emptyBottle then
                if exports.ox_inventory:CanCarryItem(source, 'empty_water_bottle', 1) then
                    exports.ox_inventory:AddItem(source, 'empty_water_bottle', 1)
                else
                    exports.qbx_core:Notify(source, 'You can´t carry any more items', 'error')
                end
            end
            return
        end
    end
end

local function registerConsumables(cfg)
    for kind in pairs(KINDS) do
        for name in pairs(type(cfg[kind]) == 'table' and cfg[kind] or {}) do
            if not registered[name] then
                registered[name] = true
                exports.qbx_core:CreateUseableItem(name, function(source, item)
                    if Mri.enabled('consumables') then useConsumable(source, item) end
                end)
            end
        end
    end
end

Mri.lifecycle('consumables', registerConsumables, function() end)

for name, event in pairs(DRUGS) do
    exports.qbx_core:CreateUseableItem(name, function(source)
        if option('drugs') then TriggerClientEvent(event, source) end
    end)
end

-- contract of qb lockpick scripts: the client and server both get the event
for name, advanced in pairs(LOCKPICKS) do
    exports.qbx_core:CreateUseableItem(name, function(source)
        if not option('lockpick') then return end
        TriggerClientEvent('lockpicks:UseLockpick', source, advanced)
        TriggerEvent('lockpicks:UseLockpick', source, advanced)
    end)
end

lib.callback.register('consumables:server:usedItem', function(source, item)
    if not DRUGS[item] or not exports.qbx_core:GetPlayer(source) then return end
    return exports.ox_inventory:RemoveItem(source, item, 1)
end)

AddEventHandler('consumables:server:setHunger', function(amount)
    if isFiniteNumber(amount) then setHunger(source, amount) end
end)

-- ox_inventory's QB bridge sends the final value through the add events
AddEventHandler('consumables:server:addHunger', function(amount)
    if not isFiniteNumber(amount) then return end
    if GetInvokingResource() == 'ox_inventory' then setHunger(source, amount) else addHunger(source, amount) end
end)

AddEventHandler('consumables:server:setThirst', function(amount)
    if isFiniteNumber(amount) then setThirst(source, amount) end
end)

AddEventHandler('consumables:server:addThirst', function(amount)
    if not isFiniteNumber(amount) then return end
    if GetInvokingResource() == 'ox_inventory' then setThirst(source, amount) else addThirst(source, amount) end
end)

local LEGACY = { SetHunger = setHunger, AddHunger = addHunger, SetThirst = setThirst, AddThirst = addThirst }
for name, fn in pairs(LEGACY) do
    for _, exportName in ipairs({ name, name:sub(1, 1):lower() .. name:sub(2) }) do
        AddEventHandler(('__cfx_export_qbx_smallresources_%s'):format(exportName), function(setCB) setCB(fn) end)
    end
end

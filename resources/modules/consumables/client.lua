-- Same as qbx_consumables on the client: progress bars, drug effects, the alcohol counter and the evidence events.
-- The joint emote uses rpemotes-reborn: qbx_consumables called scully_emotemenu, which this base does not ship.

local alcoholCount = 0
local relieveCount = 0
local healing = false
local smokingWeed = false

local function canceled()
    exports.qbx_core:Notify('Cancelado...', 'error')
end

local function progress(label, duration, anim, prop)
    return lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = false, mouse = false, combat = true },
        anim = anim,
        prop = prop,
    })
end

local function healOxy()
    if healing then return end
    healing = true
    for _ = 1, 9 do
        Wait(1000)
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 6)
    end
    healing = false
end

local function playPostFx(name, inWait, loopWait)
    AnimpostfxPlay(name .. 'In', 3.0, false)
    Wait(inWait)
    AnimpostfxPlay(name, 3.0, false)
    Wait(loopWait)
    AnimpostfxPlay(name .. 'Out', 3.0, false)
    AnimpostfxStop(name .. 'In')
    AnimpostfxStop(name)
    AnimpostfxStop(name .. 'Out')
end

local function trevorEffect()
    playPostFx('DrugsTrevorClownsFight', 3000, 3000)
end

local function alienEffect()
    playPostFx('DrugsMichaelAliensFight', math.random(5000, 8000), math.random(5000, 8000))
end

local function ragdollIfRunning()
    if IsPedRunning(cache.ped) then
        SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
    end
end

local function methBagEffect()
    trevorEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.49)
    for _ = 1, 8 do
        Wait(1000)
        if math.random(5, 100) < 10 then RestorePlayerStamina(cache.playerId, 1.0) end
        if math.random(5, 100) < 51 then trevorEffect() end
    end
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function ecstasyEffect()
    SetFlash(0, 0, 500, 7000, 500)
    for _ = 1, 30 do
        Wait(1000)
        RestorePlayerStamina(cache.playerId, 1.0)
        if math.random(1, 100) < 51 then
            SetFlash(0, 0, 500, 7000, 500)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08)
        end
    end
    ragdollIfRunning()
end

local function crackBaggyEffect()
    alienEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.3)
    for _ = 1, 8 do
        Wait(1000)
        if math.random(1, 100) < 10 then RestorePlayerStamina(cache.playerId, 1.0) end
        if math.random(1, 100) < 60 and IsPedRunning(cache.ped) then
            SetPedToRagdoll(cache.ped, math.random(1000, 2000), math.random(1000, 2000), 3, false, false, false)
        end
        if math.random(1, 100) < 51 then alienEffect() end
    end
    ragdollIfRunning()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function cokeBaggyEffect()
    alienEffect()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.1)
    for _ = 1, 20 do
        Wait(1000)
        if math.random(1, 100) < 20 then RestorePlayerStamina(cache.playerId, 1.0) end
        if math.random(1, 100) < 10 and IsPedRunning(cache.ped) then
            SetPedToRagdoll(cache.ped, math.random(1000, 3000), math.random(1000, 3000), 3, false, false, false)
        end
        if math.random(1, 300) < 10 then
            alienEffect()
            Wait(math.random(3000, 6000))
        end
    end
    ragdollIfRunning()
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
end

local function smokeWeed()
    if smokingWeed then return end
    smokingWeed = true
    CreateThread(function()
        while smokingWeed do
            Wait(10000)
            TriggerServerEvent('hud:server:RelieveStress', math.random(15, 18))
            relieveCount += 1
            if relieveCount == 6 then
                if GetResourceState('rpemotes-reborn') == 'started' then exports['rpemotes-reborn']:EmoteCancel() end
                smokingWeed = false
                relieveCount = 0
            end
        end
    end)
end

-- one drink at a time lowers the counter every 15 minutes
local function alcoholTimer()
    CreateThread(function()
        while alcoholCount > 0 do
            Wait(1000 * 60 * 15)
            alcoholCount -= 1
        end
    end)
end

lib.callback.register('consumables:client:Eat', function(anim, prop)
    if progress('Comendo...', 5000,
        anim or { clip = 'mp_player_int_eat_burger', dict = 'mp_player_inteat@burger', flag = 49 },
        prop or { { model = 'prop_cs_burger_01', bone = 18905, pos = { x = 0.13, y = 0.05, z = 0.02 }, rot = { x = -50.0, y = 16.0, z = 60.0 } } }) then
        return true
    end
    canceled()
    return false
end)

lib.callback.register('consumables:client:Drink', function(anim, prop)
    if progress('Bebendo...', 5000,
        anim or { clip = 'loop_bottle', dict = 'mp_player_intdrink', flag = 49 },
        prop or { { model = 'prop_ld_flow_bottle', bone = 18905, pos = { x = 0.12, y = 0.008, z = 0.03 }, rot = { x = 240.0, y = -60.0, z = 0.0 } } }) then
        return true
    end
    canceled()
    return false
end)

lib.callback.register('consumables:client:DrinkAlcohol', function(alcoholLevel, anim, prop)
    if not progress('Bebendo bebida alcoólica...', math.random(3000, 6000),
        anim or { clip = 'loop_bottle', dict = 'mp_player_intdrink', flag = 49 },
        prop or { { model = 'prop_amb_beer_bottle', bone = 18905, pos = { x = 0.12, y = 0.008, z = 0.03 }, rot = { x = 240.0, y = -60.0, z = 0.0 } } }) then
        canceled()
        return false
    end
    local wasSober = alcoholCount <= 0
    alcoholCount += alcoholLevel or 1
    if wasSober then alcoholTimer() end
    if alcoholCount > 1 and alcoholCount < 4 then
        TriggerEvent('evidence:client:SetStatus', 'alcohol', 200)
    elseif alcoholCount >= 4 then
        TriggerEvent('evidence:client:SetStatus', 'heavyalcohol', 200)
    end
    return true
end)

local SMOKE = { dict = 'switch@trevor@trev_smoking_meth', clip = 'trev_smoking_meth_loop', flag = 49 }
local PILL = { dict = 'mp_suicide', clip = 'pill', flag = 49 }

-- event, item, progress label, duration, animation and what runs once the item is spent
local DRUGS = {
    { 'consumables:client:Cokebaggy', 'cokebaggy', 'Engolindo comprimidos...', function() return math.random(5000, 8000) end, SMOKE, function()
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 200)
        cokeBaggyEffect()
    end },
    { 'consumables:client:Crackbaggy', 'crack_baggy', 'Fumando crack...', function() return math.random(7000, 10000) end, SMOKE, function()
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
        crackBaggyEffect()
    end },
    { 'consumables:client:EcstasyBaggy', 'xtcbaggy', 'Engolindo comprimidos...', function() return 3000 end, PILL, ecstasyEffect },
    { 'consumables:client:oxy', 'oxy', 'Curando...', function() return 2000 end, PILL, function()
        ClearPedBloodDamage(cache.ped)
        healOxy()
    end },
    { 'consumables:client:meth', 'meth', 'Fumando metanfetamina...', function() return 1500 end, SMOKE, function()
        TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
        TriggerEvent('evidence:client:SetStatus', 'agitated', 300)
        methBagEffect()
    end },
    { 'consumables:client:UseJoint', 'joint', 'Acendendo baseado...', function() return 1500 end, nil, function()
        if GetResourceState('rpemotes-reborn') == 'started' then exports['rpemotes-reborn']:EmoteCommandStart('joint') end
        TriggerEvent('evidence:client:SetStatus', 'weedsmell', 300)
        smokeWeed()
    end },
}

for _, drug in ipairs(DRUGS) do
    local event, item, label, duration, anim, effect = table.unpack(drug)
    RegisterNetEvent(event, function()
        if not progress(label, duration(), anim) then return canceled() end
        if not lib.callback.await('consumables:server:usedItem', false, item) then return end
        effect()
    end)
end

-- exports of qbx_consumables, answered under the old resource name
local LEGACY = {
    TrevorEffect = trevorEffect,
    MethBagEffect = methBagEffect,
    EcstasyEffect = ecstasyEffect,
    AlienEffect = alienEffect,
    CrackBaggyEffect = crackBaggyEffect,
    CokeBaggyEffect = cokeBaggyEffect,
}
for name, fn in pairs(LEGACY) do
    AddEventHandler(('__cfx_export_qbx_smallresources_%s'):format(name), function(setCB) setCB(fn) end)
end

-- Same as qbx_afk: one check per second, kicked after `seconds` standing on the exact same spot.

-- seconds left when the player is warned, and in which unit
local WARNINGS = {
    [900] = 'minutes', [600] = 'minutes', [300] = 'minutes', [150] = 'minutes', [60] = 'minutes',
    [30] = 'seconds', [20] = 'seconds', [10] = 'seconds',
}

local loggedIn, checkUser, previousPos, time = {}, {}, {}, {}

local function updateCheckUser(source)
    local ignored = {}
    for _, group in ipairs(Mri.cfg('afk').exemptGroups or {}) do ignored[group] = true end
    for permission in pairs(exports.qbx_core:GetPermission(source) or {}) do
        if ignored[permission] then
            checkUser[source] = false
            return
        end
    end
    checkUser[source] = true
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    loggedIn[source] = true
    updateCheckUser(source)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    loggedIn[source] = false
    checkUser[source] = false
end)

AddEventHandler('QBCore:Server:OnPermissionUpdate', function(source)
    updateCheckUser(source)
end)

AddEventHandler('playerDropped', function()
    loggedIn[source], checkUser[source], previousPos[source], time[source] = nil, nil, nil, nil
end)

CreateThread(function()
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        loggedIn[src] = Player(src).state.isLoggedIn
        checkUser[src] = true
        if loggedIn[src] then updateCheckUser(src) end
    end
    while true do
        Wait(1000)
        if Mri.enabled('afk') then
            local limit = math.floor(tonumber(Mri.cfg('afk').seconds) or 1000)
            for _, id in ipairs(GetPlayers()) do
                local src = tonumber(id)
                if loggedIn[src] and checkUser[src] then
                    local currentPos = GetEntityCoords(GetPlayerPed(src))
                    time[src] = time[src] or limit
                    if previousPos[src] and currentPos == previousPos[src] then
                        if time[src] > 0 then
                            local unit = WARNINGS[time[src]]
                            if unit == 'minutes' then
                                exports.qbx_core:Notify(src, 'You are AFK and will be kicked in ' .. math.ceil(time[src] / 60) .. ' minute(s)!', 'error', 10000)
                            elseif unit == 'seconds' then
                                exports.qbx_core:Notify(src, 'You are AFK and will be kicked in ' .. time[src] .. ' seconds!', 'error', 10000)
                            end
                            time[src] -= 1
                        else
                            DropPlayer(tostring(src), 'You have been kicked for being AFK')
                        end
                    else
                        time[src] = limit
                    end
                    previousPos[src] = currentPos
                end
            end
        end
    end
end)

-- Reports: F9 entry and window for the player; the staff tab (html/reports.html) uses the same bridge.
local OPS <const> = {
    mine = true, get = true, nearby = true, snapshot = true, create = true, reply = true, close = true, screenshot = true, media = true,
    list = true, claim = true, reopen = true, delete = true, visit = true, bring = true, location = true, gotoPerson = true, capture = true,
}

-- Street names only exist on the client, so the snapshot carries the one the player is on.
local function streetHere()
    local coords = GetEntityCoords(cache.ped)
    local street, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local name = GetStreetNameFromHashKey(street)
    if crossing ~= 0 then name = ('%s / %s'):format(name, GetStreetNameFromHashKey(crossing)) end
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    return zone ~= 'NULL' and ('%s, %s'):format(name, zone) or name
end

local open = false

local function setOpen(state)
    if open == state then return end
    open = state
    Mri.focus('reports', state)
    SendNUIMessage({ action = state and 'openReports' or 'closeReports' })
end

-- The server checks permission on every operation.
RegisterNUICallback('reports', function(data, cb)
    local op = type(data) == 'table' and data.op
    if not OPS[op] then return cb({ success = false, message = 'invalid' }) end
    local payload = op == 'snapshot' and { street = streetHere() } or data.data
    cb(lib.callback.await('mri_Qbox:reports:call', false, op, payload) or { success = false })
end)

RegisterNUICallback('reportsClose', function(_, cb)
    cb(true)
    setOpen(false)
end)

RegisterNetEvent('mri_Qbox:reports:changed', function(id)
    SendNUIMessage({ action = 'reportsChanged', data = id })
end)

local MENU_TITLE <const> = 'Reports'

Mri.lifecycle('reports', function()
    exports[cache.resource]:AddPlayerMenu({
        title = MENU_TITLE,
        icon = 'flag',
        description = 'Falar com a staff: dúvida, bug ou denúncia',
        onSelectFunction = function() setOpen(true) end,
    })
end, function()
    exports[cache.resource]:RemovePlayerMenu(MENU_TITLE)
    setOpen(false)
end)

local MENU_TITLE = 'Gravação'
-- StartRecording modes: 1 records until stopped, 0 keeps a rolling buffer of the last seconds
local MODES = { manual = 1, replay = 0 }

local open = false
---@type 'manual'|'replay'|nil
local mode

local function push()
    SendNUIMessage({ action = 'recording', data = { open = open, mode = mode } })
end

local function setOpen(value)
    open = value
    Mri.focus('recording', value)
    push()
end

local ACTIONS = {
    start = function() StartRecording(MODES.manual); mode = 'manual' end,
    replay = function() StartRecording(MODES.replay); mode = 'replay' end,
    save = function()
        if not mode then return end
        StopRecordingAndSaveClip()
        mode = nil
        lib.notify({ type = 'success', description = 'Clipe salvo. Ele aparece no Rockstar Editor.' })
    end,
    discard = function()
        if not mode then return end
        StopRecordingAndDiscardClip()
        mode = nil
    end,
    editor = function()
        setOpen(false)
        NetworkSessionLeaveSinglePlayer()
        ActivateRockstarEditor()
    end,
    close = function() setOpen(false) end,
}

RegisterNUICallback('recording', function(data, cb)
    cb({ success = true })
    local action = type(data) == 'table' and ACTIONS[data.action]
    if not action or not Mri.enabled('recording') then return end
    action()
    if open then push() end
end)

Mri.lifecycle('recording', function()
    exports[cache.resource]:AddPlayerMenu({
        title = MENU_TITLE,
        icon = 'video',
        description = 'Gravar clipes pro Rockstar Editor',
        onSelectFunction = function() setOpen(true) end,
    })
end, function()
    exports[cache.resource]:RemovePlayerMenu(MENU_TITLE)
    if open then setOpen(false) end
end)

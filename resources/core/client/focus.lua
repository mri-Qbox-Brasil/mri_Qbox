-- Shared NUI focus: each owner (panel, soundtrack player) releases only its own hold.
local owners = {}

---@param owner string
---@param on boolean
function Mri.focus(owner, on)
    owners[owner] = on and true or nil
    local any = next(owners) ~= nil
    SetNuiFocus(any, any)
end

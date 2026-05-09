local _raw = LoadResourceFile(GetCurrentResourceName(), 'data/vip.json')
local VipCfg = _raw and json.decode(_raw) or {}
if not VipCfg.Enable then return end

-- Exports mantidos para compatibilidade com outros resources.
-- O gerenciamento via UI é feito pelo mri_Qadmin via RegisterNuiCallback → server exports.

local function addVip(args)
    if args.vipData.offline then
        TriggerServerEvent("mri_Qbox:server:manageVip", {
            citizenId = args.vipData.citizenId,
            name      = args.vipData.name,
            role      = args.newRole,
            action    = 'add',
        })
    else
        ExecuteCommand(string.format("vipadm %d add %s", args.vipData.source, args.newRole))
    end
    if args['callback'] then args.callback() end
end

exports("addVip", addVip)

local function removeVip(args)
    if args.vipData.offline then
        TriggerServerEvent("mri_Qbox:server:manageVip", {
            citizenId = args.vipData.citizenId,
            action    = 'remove',
            name      = args.vipData.name,
            role      = args.vipData.role,
        })
        Wait(500)
    else
        ExecuteCommand(string.format("vipadm %d rem %s", args.vipData.source, args.vipData.role))
    end
    if args['callback'] then args.callback() end
end

exports("removeVip", removeVip)

local function setPlayerJob(targetPlayer)
    if not targetPlayer then return end
    local jobs = exports.qbx_core:GetJobs()
    local options = {}

    for k, v in pairs(jobs) do
        options[#options + 1] = {
            label = string.format('%s (%s)', v.label, k),
            value = k
        }
    end

    local group = lib.inputDialog('Escolher o Job', {
        { type = 'select', label = 'Jobs disponíveis:', options = options, required = true, searchable = true, clearable = true }
    })
    if not group then return end

    local jobgrades = jobs[group[1]].grades

    local options = {}
    for k, v in pairs(jobgrades) do
        options[#options + 1] = {
            label = string.format('[%s] %s', k, v.name),
            value = k
        }
    end

    local grade = lib.inputDialog('Escolher o Cargo', {
        { type = 'select', label = 'Cargos disponíveis:', options = options, required = true, searchable = true, clearable = true }
    })
    if not grade then return end

    TriggerServerEvent("mri_Qadmin:server:SetJob", targetPlayer, group[1], tonumber(grade[1]))
end
exports("setPlayerJob", setPlayerJob)

local function setPlayerGang(targetPlayer)
    if not targetPlayer then return end
    local jobs = exports.qbx_core:GetGangs()
    local options = {}

    for k, v in pairs(jobs) do
        options[#options + 1] = {
            label = string.format('%s (%s)', v.label, k),
            value = k
        }
    end

    local group = lib.inputDialog('Escolher a Gang', {
        { type = 'select', label = 'Gangs disponíveis:', options = options, required = true, searchable = true, clearable = true }
    })
    if not group then return end

    local jobgrades = jobs[group[1]].grades

    local options = {}
    for k, v in pairs(jobgrades) do
        options[#options + 1] = {
            label = string.format('[%s] %s', k, v.name),
            value = k
        }
    end

    local grade = lib.inputDialog('Escolher o Cargo', {
        { type = 'select', label = 'Cargos disponíveis:', options = options, required = true, searchable = true, clearable = true }
    })
    if not grade then return end

    TriggerServerEvent("mri_Qadmin:server:SetGang", targetPlayer, group[1], tonumber(grade[1]))
end
exports("setPlayerGang", setPlayerGang)

RegisterCommand("setargang", function(src, args)
    setPlayerGang(tonumber(args[1]))
end)

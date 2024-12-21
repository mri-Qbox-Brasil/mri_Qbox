local function setPlayerJob(targetPlayer, job)
    if not targetPlayer then return end
    local groups = exports.qbx_core:GetJobs()
    local options = {}

    for k, v in pairs(groups) do
        options[#options + 1] = {
            label = string.format('%s (%s)', v.label, k),
            value = k
        }
    end

    if not job then 
        job = lib.inputDialog('Escolher o Job', {
            { type = 'select', label = 'Jobs disponíveis:', options = options, required = true, searchable = true, clearable = true }
        })
        if not job then return end
    end

    if not groups[job[1]] then
        lib.notify({
            title = 'Erro',
            description = 'Job inválido ou inexistente',
            type = 'error'
        })
        return
    end

    local jobgrades = groups[job[1]].grades

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

    if GetResourceState("mri_Qadmin") == "started" then
        TriggerServerEvent("mri_Qadmin:server:SetJob", targetPlayer, job[1], tonumber(grade[1]))
    else
        TriggerServerEvent("ps-adminmenu:server:SetJob", "set_job", {
            ["Player"] = {value = targetPlayer},
            ["Job"] = {value = job[1]},
            ["Grade"] = {value = tonumber(grade[1])}
        })
    end
end
exports("setPlayerJob", setPlayerJob)

local function setPlayerGang(targetPlayer, gang)
    if not targetPlayer then return end
    local groups = exports.qbx_core:GetGangs()
    local options = {}

    for k, v in pairs(groups) do
        options[#options + 1] = {
            label = string.format('%s (%s)', v.label, k),
            value = k
        }
    end

    if not gang then 
        local gang = lib.inputDialog('Escolher a Gang', {
            { type = 'select', label = 'Gangs disponíveis:', options = options, required = true, searchable = true, clearable = true }
        })
        if not gang then return end
    end

    if not groups[gang[1]] then
        lib.notify({
            title = 'Erro',
            description = 'Gang inválida ou inexistente',
            type = 'error'
        })
        return
    end

    local jobgrades = groups[gang[1]].grades

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

    if GetResourceState("mri_Qadmin") == "started" then
        TriggerServerEvent("mri_Qadmin:server:SetGang", targetPlayer, gang[1], tonumber(grade[1]))
    else
        TriggerServerEvent("ps-adminmenu:server:SetGang", "set_gang", {
            ["Player"] = {value = targetPlayer},
            ["Gang"] = {value = gang[1]},
            ["Grade"] = {value = tonumber(grade[1])}
        })
    end
end
exports("setPlayerGang", setPlayerGang)

RegisterCommand("setargang", function(src, args)
    setPlayerGang(tonumber(args[1]))
end)

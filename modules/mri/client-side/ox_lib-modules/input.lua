local function setPlayerJob(targetPlayer)
    if not targetPlayer then return end
    local jobs = exports.qbx_core:GetJobs()
    local options = {}

    for k, v in pairs(jobs) do
        print(k)
        options[#options + 1] = {
            label = string.format('%s (%s)', v.label, k),
            value = k
        }
    end

    local group = lib.inputDialog('Escolher o Job', {
        { type = 'select', label = 'Jobs disponíveis:', options = options, required = true }
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
        { type = 'select', label = 'Cargos disponíveis:', options = options, required = true}
    })
    if not grade then return end

    print(targetPlayer, group[1], grade[1])

    TriggerServerEvent("mri_Qadmin:server:SetJob", targetPlayer, group[1], tonumber(grade[1]))


    
    lib.notify({
        title = 'Setar job',
        description = 'Setou o job',
        type = 'success'
    })
end


RegisterCommand("setarjob", function(source, args, raw)
    print(source, json.encode(args), raw)
    print("TESTEEE: ", args[1])
    if not args then return end
    setPlayerJob(args[1])
end, false)
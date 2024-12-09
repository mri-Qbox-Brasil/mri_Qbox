local relaseInfoUrl = "https://github.com/%s/%s/releases/latest"
local fileDownloadUrl = "https://raw.githubusercontent.com/%s/%s/%s/%s"
local gitUser = "mri-Qbox-Brasil"

local path = GetResourcePath(GetCurrentResourceName())
local destination = ''--GetResourcePath('progressbar'):gsub("/progressbar", "")
print(destination)
exports['mri_Qbox']:ExtractZip(path .. '/progressbar.zip', destination)

local function updateResource(source, args)
    if not args.hasUpdate then
        return
    end
    local fileList = {}
    print(json.encode(args.repoInfo))
    exports['mri_Qbox']:ExtractZip('', '')
    local splittedUrl = Split(args.repoInfo.update_url, "/")
    local url = string.format(string.format(fileDownloadUrl, gitUser, splittedUrl[2], args.repoInfo.tag_name,
        'file_list.txt'))
    if cfg.AutoUpdater.Debug then
        SendNotification(source, "debug",
            string.format("[%s] Baixando lista de arquivos, url: %s", args.resourceName, url))
    end
    PerformHttpRequest(url, function(reponseCode, resultData, resultHeaders, errorData)
        if reponseCode ~= 200 or resultData == nil then
            SendNotification(source, "error",
                string.format("[%s] Erro ao obter lista de arquivos: %s, %s", args.resourceName, reponseCode,
                    json.encode(errorData, {
                        indent = true
                    })), cfg.WebHook, cfg.AutoUpdater.KeepOnConsole)
            return
        end
        fileList = Split(resultData, "\n")
        -- Acho que da pra implementar um controle do download dos arquivos arquivos
        -- Usariamos pcall para capturar algum erro e callback para incrementar o contador
        -- dessa forma, se houver uma falha, conseguiremos aletar o usuário e também teremos a notificação no término.
        for k, v in pairs(fileList) do
            if v ~= nil and v ~= '' then
                if cfg.AutoUpdater.Debug then
                    SendNotification(source, "debug", string.format("[%s] Baixando: %s", args.resourceName, v))
                end
                PerformHttpRequest(string.format(fileDownloadUrl, gitUser, splittedUrl[2], args.repoInfo.tag_name, v),
                    function(reponseCode, resultData, resultHeaders, errorData)
                        if reponseCode ~= 200 or resultData == nil then
                            SendNotification(source, "error",
                                string.format("[%s] Erro ao baixar: %s, %s", args.resourceName, v,
                                    json.encode(errorData, {
                                        indent = true
                                    })), cfg.WebHook, cfg.AutoUpdater.KeepOnConsole)
                            return
                        end
                        if cfg.AutoUpdater.Debug then
                            SendNotification(source, "debug", string.format("[%s] Baixado: %s", args.resourceName, v))
                        end
                        if string.find(v, 'fxmanifest') then
                            resultData = resultData:gsub("MRIQBOX_VERSION", tostring(args.newVersion))
                        end
                        SaveResourceFile(args.resourceName, v, resultData, #resultData)
                    end, 'GET')
            end
        end
    end, 'GET')
    Wait(5000)
    SendNotification(source, "success",
        string.format("[%s] Atualização concluída, reinicie o servidor para aplicar as alterações!",
            args.resourceName, args.repoInfo.tag_name), cfg.WebHook, cfg.AutoUpdater.KeepOnConsole)
    return true
end

exports('UpdateResource', updateResource)

local function checkForUpdates(source, args)
    local repoInfo = nil
    local fxmanifest = LoadResourceFile(args.resource, "fxmanifest.lua")
    local version = string.match(fxmanifest, 'version%s*"%d+%.%d+%.%d+"') or
                        string.match(fxmanifest, "version%s*'%d+%.%d+%.%d+'")
    if version then
        version = version:match('%d+%.%d+%.%d+')
    end
    if cfg.AutoUpdater.Debug then
        SendNotification(source, "debug", string.format("[%s] Verificando atualização...", args.resource))
    end
    PerformHttpRequest(string.format(relaseInfoUrl, gitUser, args.resource),
        function(reponseCode, resultData, resultHeaders, errorData)
            if reponseCode == 200 and resultData ~= nil then
                repoInfo = json.decode(resultData)
            else
                SendNotification(source, "error",
                    string.format("[%s] Erro ao obter informações do repositório: %s, %s", args.resource,
                        reponseCode, json.encode(errorData, {
                            indent = true
                        })))
                return
            end
        end, 'GET', '', {
            ['Content-Type'] = 'application/json',
            ['Accept'] = 'application/json'
        })

    while repoInfo == nil do
        Wait(10)
    end

    local ind1, ind2, ver = string.find(repoInfo.tag_name, "v(%d.%d.%d)")
    if not ver then
        ind1, ind2, ver = string.find(repoInfo.tag_name, "(%d+%.%d+%.%d+)")
    end

    if ver > version then
        SendNotification(source, "info",
            string.format("[%s] Nova versão encontrada: %s", args.resource, repoInfo.tag_name), cfg.WebHook,
            cfg.AutoUpdater.KeepOnConsole)
    else
        if cfg.AutoUpdater.Debug then
            SendNotification(source, "debug", string.format("[%s] Nenhuma nova versão encontrada", args.resource),
                cfg.WebHook, cfg.AutoUpdater.KeepOnConsole)
        end
    end
    return {
        resourceName = args.resource,
        repoInfo = repoInfo,
        oldVersion = version,
        newVersion = ver,
        hasUpdate = ver > version
    }
end

exports('CheckForUpdates', checkForUpdates)

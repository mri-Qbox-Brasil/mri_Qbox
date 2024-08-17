local mysqlConvar = "mysql_connection_string"
local xamppPath = 'C:/xampp'
local xamppMysqlDumpPath = xamppPath .. '/mysql/bin/mysqldump.exe'

local function dirExists(dir)
    local ok, err, code = os.rename(dir, dir)
    if not ok then
        -- Código 13 significa que o diretório existe, mas sem permissões de leitura
        return code == 13
    end
    return false
end

local function createDir(dir)
    os.execute(string.format('mkdir "%s"', dir))
end

local function sendNotification(source, type, message)
    local msgColor = '^2'
    local title = 'Sucesso'
    if type == 'error' then
        msgColor = '^1'
        title = 'Erro'
    elseif type == 'debug' then
        msgColor = '^5'
        title = 'Debug'
    elseif type == 'warn' then
        msgColor = '^3'
        title = 'Aviso'
    end
    if (source > 0) and (type ~= 'debug') then
        lib.notify(source, {
            title = title,
            type = type,
            description = message
        })
    end
    print(string.format("%s[CMD] %s: %s^7", msgColor, title, message))
end

local function setupBackupFolder(path)
    local resources_pos = path:find("resources")
    if not resources_pos then
        return
    end
    local last_slash_before_resources = path:sub(1, resources_pos):match(".*/")
    local result = last_slash_before_resources:match("(.*/mri_Qbox)/")
    if not result then
        return
    end
    local backupDir = result .. '/backup'
    if not dirExists(backupDir) then
        createDir(backupDir)
    end
    return backupDir
end

local function isWindows()
    local file = io.popen("cd")
    local output = file:read("*a")
    file:close()

    return output:match("^%a:")
end

local function normalizePath(path)
    if isWindows() then
        return path:gsub('/', '\\')
    else
        return path:gsub('\\', '/')
    end
end

local function isXAMPP(source)
    local file = io.open(xamppMysqlDumpPath, "r")
    if file ~= nil then
        io.close(file)
        if cfg.Debug then
            sendNotification(source, 'debug', 'IsXAMPP: Sim')
        end
        sendNotification(source, 'warn',
            'Este servidor está executando o XAMPP. Se for um servidor de produção, EVITE usar esta ferramenta.')
        return true
    end
end

local function extractDbConfig(source)
    local patternWithPw = "mysql://(.-):(.-)@(.-)/(.-)%?"
    local patternWithoutPw = "mysql://(.-)@(.-)/(.-)%?"
    local connectionString = GetConvar(mysqlConvar, '')
    if cfg.Debug then
        sendNotification(source, 'debug', 'ConnectionString: ' .. connectionString)
    end
    if connectionString == '' then
        return
    end
    local user, password, host, database = string.match(connectionString, patternWithPw)
    if not user then
        user, host, database = string.match(connectionString, patternWithoutPw)
        if user then
            sendNotification(source, 'warn', string.format('"%s" deve ter uma senha.', mysqlConvar))
        end
    end
    if cfg.Debug then
        sendNotification(source, 'debug', string.format(
            'ExtractDbConfig: Usuário: %s, Senha: %s, Servidor: %s, Banco: %s', user, password, host, database))
    end
    return user, password, host, database
end

local function backupDatabase(source)
    local mysqldumpPath = 'mysqldump'
    local user, password, host, database = extractDbConfig(source)
    if not user then
        sendNotification(source, 'error', string.format('"%s" não configurado.', mysqlConvar))
        return
    end
    if isXAMPP(source) then
        mysqldumpPath = xamppMysqlDumpPath
    end
    mysqldumpPath = normalizePath(mysqldumpPath)
    local backupDir = setupBackupFolder(GetResourcePath(GetCurrentResourceName()))
    local backupFile = string.format('%s/%s_%s.sql', backupDir, database, os.date('%Y-%m-%d_%H-%M-%S'))
    local backupCmd = ''
    if password and password ~= '' then
        backupCmd = string.format('%s -u%s -p%s -h%s %s --result-file="%s"', mysqldumpPath, user, password, host,
            database, normalizePath(backupFile))
    else
        backupCmd = string.format('%s -u%s -h%s %s --result-file="%s"', mysqldumpPath, user, host, database,
            normalizePath(backupFile))
    end

    CreateThread(function()
        local cmd = string.format('%s', backupCmd)
        if cfg.Debug then
            sendNotification(source, 'debug', string.format('CMD: %s', cmd))
        end

        if os.execute(cmd) then
            sendNotification(source, 'success', string.format('Backup de "%s" concluído com sucesso.', database))
        else
            sendNotification(source, 'error', string.format('Erro ao criar o backup de "%s".', database))
        end
    end)
end

RegisterNetEvent('onResourceStart', function(resource)
    if "qbx_core" == resource and cfg.SqlBackup.Active and cfg.SqlBackup.BackupOnStart then
        backupDatabase(0)
    end
end)

if cfg.SqlBackup.Active and cfg.SqlBackup.BackupCommand then
    lib.addCommand(cfg.SqlBackup.BackupCommand, {
        help = 'Cria um backup do banco de dados (Somente Admin)',
        restricted = 'group.admin'
    }, function(source, args, raw)
        local src = source
        backupDatabase(src)
    end)
end

CreateThread(function()
    while true do
        if cfg.SqlBackup.Active and cfg.SqlBackup['ExecuteOnTime'] then
            local now = os.date("*t", os.time)
            if now.min == cfg.SqlBackup.ExecuteOnTime.min and now.hour == cfg.SqlBackup.ExecuteOnTime.hour then
                backupDatabase(0)
            end
        end
        Wait(50000)
    end
end)

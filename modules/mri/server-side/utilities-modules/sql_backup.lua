-- Configurações Gerais
local config = {
    mysqlConvar = "mysql_connection_string",
    xamppPath = "C:/xampp",
    backupDir = "backup",
    debug = cfg.SqlBackup.Debug,
    notificationType = {
        success = "success",
        error = "error",
        warn = "warn",
        debug = "debug"
    }
}

config.xamppMysqlDumpPath = config.xamppPath .. "/mysql/bin/mysqldump.exe"

-- Funções Auxiliares
local function dirExists(dir)
    local ok, _, code = os.rename(dir, dir)
    return ok or code == 13
end

local function createDir(dir)
    os.execute(string.format('mkdir "%s"', dir))
end

local function setupBackupFolder()
    if not dirExists(config.backupDir) then
        createDir(config.backupDir)
    end
    return config.backupDir
end

local function isWindows()
    return package.config:sub(1, 1) == "\\"
end

local function normalizePath(path)
    return isWindows() and path:gsub("/", "\\") or path:gsub("\\", "/")
end

local function sendNotification(source, type, message)
    SendNotification(source, type, message)
end

-- Verifica se é XAMPP
local function isXAMPP(source)
    local file = io.open(config.xamppMysqlDumpPath, "r")
    if file then
        io.close(file)
        sendNotification(source, config.notificationType.warn,
            "Este servidor está executando o XAMPP. Se for um servidor de produção, EVITE usar esta ferramenta.")
        return true
    end
    return false
end

-- Extrai Configuração do Banco
local function extractDbConfig(source)
    local connectionString = GetConvar(config.mysqlConvar, "")
    if config.debug then
        sendNotification(source, config.notificationType.debug, "ConnectionString: " .. connectionString)
    end

    if connectionString == "" then return end

    local patternWithPw = "mysql://(.-):(.-)@(.-)/(.-)%?"
    local patternWithoutPw = "mysql://(.-)@(.-)/(.-)%?"

    local user, password, host, database = connectionString:match(patternWithPw)
    if not user then
        user, host, database = connectionString:match(patternWithoutPw)
        if user then
            sendNotification(source, config.notificationType.warn,
                string.format('"%s" deve ter uma senha.', config.mysqlConvar))
        end
    end

    return user, password, host, database
end

-- Backup do Banco
local function backupDatabase(source)
    local mysqldumpPath = isXAMPP(source) and config.xamppMysqlDumpPath or "mysqldump"
    mysqldumpPath = normalizePath(mysqldumpPath)

    local user, password, host, database = extractDbConfig(source)
    if not user then
        sendNotification(source, config.notificationType.error,
            string.format('"%s" não configurado.', config.mysqlConvar))
        return
    end

    local backupDir = setupBackupFolder()
    local backupFile = string.format("%s/%s_%s.sql", backupDir, database, os.date("%Y-%m-%d_%H-%M-%S"))
    local backupCmd

    if password and password ~= "" then
        backupCmd = string.format('%s -u%s -p%s -h%s %s --result-file="%s"',
            mysqldumpPath, user, password, host, database, normalizePath(backupFile))
    else
        backupCmd = string.format('%s -u%s -h%s %s --result-file="%s"',
            mysqldumpPath, user, host, database, normalizePath(backupFile))
    end

    CreateThread(function()
        if config.debug then
            sendNotification(source, config.notificationType.debug, "CMD: " .. backupCmd)
        end

        if os.execute(backupCmd) then
            sendNotification(source, config.notificationType.success,
                string.format('Backup de "%s" concluído com sucesso.', database))
        else
            sendNotification(source, config.notificationType.error,
                string.format('Erro ao criar o backup de "%s".', database))
        end
    end)
end

-- Eventos e Comandos
RegisterNetEvent("onResourceStart", function(resource)
    if GetCurrentResourceName() == resource and cfg.SqlBackup.Active and cfg.SqlBackup.BackupOnStart then
        backupDatabase(0)
    end
end)

if cfg.SqlBackup.Active and cfg.SqlBackup.BackupCommand then
    lib.addCommand(cfg.SqlBackup.BackupCommand, {
        help = "Cria um backup do banco de dados (Somente Admin)",
        restricted = "group.admin"
    }, function(source)
        backupDatabase(source)
    end)
end

CreateThread(function()
    while cfg.SqlBackup.Active and cfg.SqlBackup.ExecuteOnTime do
        local now = os.date("*t", os.time())
        if now.min == cfg.SqlBackup.ExecuteOnTime.min and now.hour == cfg.SqlBackup.ExecuteOnTime.hour then
            backupDatabase(0)
        end
        Wait(50000)
    end
end)

return {
    Active = false, -- Ativa o backup
    Debug = false, -- Mostra informações sobre debug
    BackupCommand = "backupdb", -- Nome do comando para execução manual
    BackupOnStart = false -- Backup ao iniciar mri_Qbox(esse resource)
    -- ExecuteOnTime = {                    -- Executar backup automaticamente no horário
    --     hour = 3,
    --     min = 40
    -- }
}

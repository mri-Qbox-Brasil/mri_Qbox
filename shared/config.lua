cfg = {}

-----------------------------------------------------------------------------------------
---- UTILITIES-MODULES
-----------------------------------------------------------------------------------------
cfg.printidentifiers = true -- true para mostrar os identificadores no console

cfg.indestructibleProps = true -- true para ativar as props indestrutíveis

cfg.dropitems = true           -- true para ativar o drop de items como props
cfg.dropitems_table = {
    money = 'prop_cash_pile_02',
    burger = 'prop_cs_burger_01',
    water = 'prop_ld_flow_bottle',
    speaker = 'gordela_boombox3',
    phone = 'prop_phone_ing_02_lod',
    WEAPON_MINISMG = 'w_sb_minismg',
    ['ammo-9'] = 'prop_ld_ammo_pack_01',
    ['ammo-rifle'] = 'prop_ld_ammo_pack_03',
    ['ammo-rifle2'] = 'prop_ld_ammo_pack_02',
}

cfg.SqlBackup = {
    Active = false,             -- Ativa o backup
    Debug = false,              -- Mostra informações sobre debug
    BackupCommand = 'backupdb', -- Nome do comando para execução manual
    BackupOnStart = false,      -- Backup ao iniciar mri_Qbox(esse resource)
    -- ExecuteOnTime = {                    -- Executar backup automaticamente no horário
    --     hour = 3,
    --     min = 40
    -- }
}

cfg.AutoUpdater = {
    Debug = true,         -- Mostra informações sobre debug
    WebHook = nil,        -- Enviar os avisos de atualizações para um WebHook(discord,...)
    KeepOnConsole = false -- Manter os avisos no console mesmo ao enviar para um WebHook
}
-----------------------------------------------------------------------------------------
---- TARGET-MODULES
-----------------------------------------------------------------------------------------

cfg.entervehicle = {
    toggle = true, -- true para ativar entrar na porta que você estiver olhando pelo target
}

cfg.dumpsters = {
    toggle = true,
    HideProps = {
        Model = { 218085040, 666561306, -58485588, -206690185, 1511880420, 682791951 },
    },
    TrashProps = {
        Model = { 218085040, 666561306, -58485588, -206690185, 1511880420, 682791951, -1426008804 },
    }
}

-----------------------------------------------------------------------------------------
---- COMBAT-MODULES
-----------------------------------------------------------------------------------------
cfg.disablefreepunch = {
    toggle = false,
}

cfg.forcedfirstperson = {
    twopov = false,
    invehicle = {
        ativar = false,
        hold = false,
    }
}

cfg.disablecombatroll = {
    toggle = false,
}

cfg.damageragdoll = {
    toggle = false,
}

cfg.disableblindfiring = {
    toggle = false,
}

cfg.realisticrecoil = {
    hideCrosshair = false,
    drunkAiming = false,
    verticalRecoil = false,
    disableAimPunching = false,
    disableHeadshots = false,
    drunkAimingPower = 0.20,
    whitelistedWeapons = {
        ["WEAPON_SNIPERRIFLE"] = true,
        ["WEAPON_HEAVYSNIPER"] = true,
        ["WEAPON_HEAVYSNIPER_MK2"] = true,
        ["WEAPON_MARKSMANRIFLE"] = true,
        ["WEAPON_MARKSMANRIFLE_MK2"] = true,
    },
    recoilMultipliers = {
        ["PISTOL"]   = 0.3,
        ["SMG"]      = 0.8,
        ["RIFLE"]    = 1.3,
        ["LMG"]      = 1.6,
        ["SHOTGUN"]  = 2.3,
        ["SNIPER"]   = 5.5,
        ["VEHICLE"]  = 0.8
    },
}

-----------------------------------------------------------------------------------------
---- VEHICLES-MODULES
-----------------------------------------------------------------------------------------
cfg.wheelbreak = {
    toggle = false,
    mode = "impact",
    impactDamage = 80.0,
    minImpactSpeed = 20.0,
    impactDeltaSpeed = 35.0,
    cooldown = 5000,
    speed = 85,
}

cfg.savewheelpos = {
    toggle = false,
}

cfg.disableaircontrol = {
    toggle = false,
}

cfg.carexplosion = {
    toggle = false,
    height = 40,
}

cfg.drift = {
    toggle = true,
    points = false,
    speed = 80,
}

cfg.mercosulplates = {
    toggle = false,
}

return cfg

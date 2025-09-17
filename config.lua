cfg = {}

-----------------------------------------------------------------------------------------
---- UTILITIES-MODULES
-----------------------------------------------------------------------------------------
cfg.printidentifiers = true                 -- true para mostrar os identificadores no console

cfg.vipmenu = {
    Enable = true,
    PaycheckInterval = 30,
    CashType = 'bank', -- money, bank, crypto
    CoinType = "R$",
    Roles = {
        nenhum = {
            label = "Sem vip",
            payment = 0,
            inventory = 100, -- 100 KG
        },
        tier1 = {
            label = "Tier 1",
            payment = 5000,
            inventory = 200 , -- 200 KG
        }
    }
}

cfg.indestructibleProps = true              -- true para ativar as props indestrutíveis

cfg.dropitems = true                        -- true para ativar o drop de items como props
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
    Active = false,                         -- Ativa o backup
    Debug = false,                          -- Mostra informações sobre debug
    BackupCommand = 'backupdb',             -- Nome do comando para execução manual
    BackupOnStart = false,                  -- Backup ao iniciar mri_Qbox(esse resource)
    -- ExecuteOnTime = {                    -- Executar backup automaticamente no horário
    --     hour = 3,
    --     min = 40
    -- }
}

cfg.AutoUpdater = {
    Debug = true,                           -- Mostra informações sobre debug
    WebHook = nil,                          -- Enviar os avisos de atualizações para um WebHook(discord,...)
    KeepOnConsole = false                   -- Manter os avisos no console mesmo ao enviar para um WebHook
}
-----------------------------------------------------------------------------------------
---- TARGET-MODULES
-----------------------------------------------------------------------------------------

cfg.entervehicle = {
    toggle = true,                          -- true para ativar entrar na porta que você estiver olhando pelo target
}

cfg.dumpsters = {
    toggle = true,                          -- true para ativar as lixeiras para abrir no olhinho
    HideProps = { -- props para esconder-se
        Model = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951 }, -- modelo da lixeira
    },
    TrashProps = { -- props para vasculhar
        Model = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951, -1426008804}, -- modelo da lixeira
    }
}

-----------------------------------------------------------------------------------------
---- COMBAT-MODULES
-----------------------------------------------------------------------------------------
cfg.disablefreepunch = {
    toggle = false,                         -- true para desativar o soco se não estiver mirando com o botão direito (corrige bug da galera iniciante se bater sem querer usando o olhinho em tarefas aleatórias)
}

cfg.forcedfirstperson = {
    twopov = false,                         -- true para forçar apenas 2 tipos de VISÕES (PRIMEIRA PESSOA E TERCEIRA PESSOA) - ao invés daquelas 4 opções de câmera padrão
    invehicle = {
        ativar = false,                     -- true se quiser ativar forçar primeira pessoa no carro
        hold = false,                       -- true se quiser que só fique em primeira pessoa se estiver segurando a arma
    }
}

cfg.disablecombatroll = {
    toggle = false,                         -- true para desativar o rolamento e não ser uma cidade Pvpas
}

cfg.damageragdoll = {
    toggle = false,                         -- true para ativar cair/tropeçar ao tomar tiro na perna
}

cfg.disableblindfiring = {
    toggle = false,                         -- true para desativar o tiro cego quando estiver pegando cover em paredes
}

cfg.realisticrecoil = {
    hideCrosshair = false,                  -- Hide builtin GTA crosshair while aiming?
    drunkAiming = false,                    -- Enable "drunk" aiming?
    verticalRecoil = false,                 -- Enable realistic vertical recoil while shooting?
    disableAimPunching = false,             -- Disables punching with [R] and other keys while aiming
    disableHeadshots = false,               -- Disables one-shots to head
    drunkAimingPower = 0.20,                -- Higher number = Higher screen shake
    whitelistedWeapons = {                  -- Table of weapons with no recoil
        ["WEAPON_SNIPERRIFLE"] = true,
        ["WEAPON_HEAVYSNIPER"] = true,
        ["WEAPON_HEAVYSNIPER_MK2"] = true,
        ["WEAPON_MARKSMANRIFLE"] = true,
        ["WEAPON_MARKSMANRIFLE_MK2"] = true,
    -- Add more weapons if needed
    },
    recoilMultipliers = {                   -- [ONLY FOR VERTICAL RECOIL] Edit the power of the recoil for each weapon type
                                            -- 0.0 = none (default)
        ["PISTOL"] = 0.3,
        ["SMG"] = 0.8,
        ["RIFLE"] = 1.3,
        ["LMG"] = 1.6,
        ["SHOTGUN"] = 2.3,
        ["SNIPER"] = 5.5,
        ["VEHICLE"] = 0.8                   -- Recoil while in vehicle
    },
}

-----------------------------------------------------------------------------------------
---- VEHICLES-MODULES
-----------------------------------------------------------------------------------------
cfg.wheelbreak = {
    toggle = false,                         -- true para ativar as rodas quebrarem/soltarem ao bater o veículo
    speed = 150,                            -- velocidade em km/h que a roda vai quebrar/soltar (100 = hardcore)
}

cfg.savewheelpos = {
    toggle = false,                         -- true para ativar a roda ficar parada em um ângulo específico ao sair do veículo
}

cfg.disableaircontrol = {
    toggle = false,                         -- true para ativar a roda ficar parada em um ângulo específico ao sair do veículo
}

cfg.carexplosion = {
    toggle = false,                         -- true para ativar a Explosão de veículos ao cair de uma certa altura
    height = 40,                            -- qual altura você quer para ativar a explosão
}

cfg.drift = {
    toggle = true,                          -- ativar drift usando shift
    points = false,                         -- ativar drift points nui
    speed = 80,                             -- velocidade máxima que pode usar o drift
}

cfg.mercosulplates = {
    toggle = false,                          -- (deprecated, use a versão do gordela: mri_Qcarplates) true para ativar placas do mercosul nos veículos
}

return cfg

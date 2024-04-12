cfg = {}


-----------------------------------------------------------------------------------------
---- TARGET-MODULES
-----------------------------------------------------------------------------------------

cfg.entervehicle = {
    toggle = true,                       -- true para ativar entrar na porta que você estiver olhando pelo target
}

cfg.dumpsters = {
    toggle = true,                      -- true para ativar as lixeiras para abrir no olhinho
    TrashCans = {
        Model = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951}, -- modelo da lixeira
    }
}

-----------------------------------------------------------------------------------------
---- COMBAT-MODULES
-----------------------------------------------------------------------------------------
cfg.disablefreepunch = {
    toggle = false,                      -- true para desativar o soco se não estiver mirando com o botão direito (corrige bug da galera iniciante se bater sem querer usando o olhinho em tarefas aleatórias)
}

cfg.forcedfirstperson = {
    twopov = false,                      -- true para forçar apenas 2 tipos de VISÕES (PRIMEIRA PESSOA E TERCEIRA PESSOA) - ao invés daquelas 4 opções de câmera padrão
    invehicle = {
        ativar = false,                  -- true se quiser ativar forçar primeira pessoa no carro
        hold = true,                    -- true se quiser que só fique em primeira pessoa segurando a arma
    }
}

cfg.disablecombatroll = {
    toggle = false,                      -- true para desativar o rolamento e não ser uma cidade Pvpas
}

cfg.damageragdoll = {
    toggle = false,                      -- true para ativar cair/tropeçar ao tomar tiro na perna
}

cfg.disableblindfiring = {
    toggle = false,                      -- true para desativar o tiro cego quando estiver pegando cover em paredes
}

cfg.realisticrecoil = { 
    hideCrosshair = false, -- Hide builtin GTA crosshair while aiming?
    drunkAiming = false, -- Enable "drunk" aiming?
    verticalRecoil = false, -- Enable realistic vertical recoil while shooting?
    disableAimPunching = false, -- Disables punching with [R] and other keys while aiming
    disableHeadshots = false, -- Disables one-shots to head
    drunkAimingPower = 0.20, -- Higher number = Higher screen shake
    whitelistedWeapons = {  -- Table of weapons with no recoil
    ["WEAPON_SNIPERRIFLE"] = true,
    ["WEAPON_HEAVYSNIPER"] = true,
    ["WEAPON_HEAVYSNIPER_MK2"] = true,
    ["WEAPON_MARKSMANRIFLE"] = true,
    ["WEAPON_MARKSMANRIFLE_MK2"] = true,
    -- Add more weapons if needed
    },
    recoilMultipliers = {   -- [ONLY FOR VERTICAL RECOIL] Edit the power of the recoil for each weapon type
                            -- 0.0 = none (default)
        ["PISTOL"] = 0.3,
        ["SMG"] = 0.8,
        ["RIFLE"] = 1.3,
        ["LMG"] = 1.6,
        ["SHOTGUN"] = 2.3,
        ["SNIPER"] = 5.5,
        ["VEHICLE"] = 0.8   -- Recoil while in vehicle
    },
}

-----------------------------------------------------------------------------------------
---- VEHICLES-MODULES
-----------------------------------------------------------------------------------------
cfg.wheelbreak = {
    toggle = false,                      -- true para ativar as rodas quebrarem/soltarem ao bater o veículo
    speed = 150,                        -- velocidade em km/h que a roda vai quebrar/soltar (100 = hardcore)
}

cfg.savewheelpos = {
    toggle = false,                      -- true para ativar a roda ficar parada em um ângulo específico ao sair do veículo
}

cfg.disableaircontrol = {
    toggle = false,                      -- true para ativar a roda ficar parada em um ângulo específico ao sair do veículo
}

cfg.carexplosion = {
    toggle = false,                      -- true para ativar a Explosão de veículos ao cair de uma certa altura
    height = 40,                        -- qual altura você quer para ativar a explosão
}

return cfg
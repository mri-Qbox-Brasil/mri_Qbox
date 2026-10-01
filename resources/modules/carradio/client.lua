-- Rádio do carro sob controle do jogador: /mri_carradio emudece ou devolve as
-- estações do GTA, e a escolha acompanha o jogador de um veículo pro outro.

local muted = Mri.cfg('carradio').startMuted == true

local function silence(vehicle)
    SetVehRadioStation(vehicle, 'OFF')
    SetUserRadioControlEnabled(false)
end

local function release()
    SetUserRadioControlEnabled(true)
end

-- Estado do rádio pro veículo atual (ou só destrava, a pé).
local function sync()
    local vehicle = cache.vehicle
    if muted and vehicle and vehicle ~= 0 then
        silence(vehicle)
    else
        release()
    end
end

RegisterCommand('mri_carradio', function()
    if not Mri.enabled('carradio') or not cache.vehicle then return end
    muted = not muted
    sync()
    lib.notify({
        type = muted and 'error' or 'success',
        description = muted and 'Rádio do carro desligado' or 'Rádio do carro ligado',
    })
end, false)

-- Sem tecla padrão a não ser que o painel defina uma (o F9 é do menu do jogador).
RegisterKeyMapping('mri_carradio', 'Rádio do carro: ligar/desligar', 'keyboard', Mri.cfg('carradio').key or '')

lib.onCache('vehicle', function()
    if Mri.enabled('carradio') then
        -- o cache troca antes do ped terminar de entrar; um frame depois o rádio obedece
        SetTimeout(0, sync)
    end
end)

Mri.lifecycle('carradio', sync, release)

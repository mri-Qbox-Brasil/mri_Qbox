-- Trilha sonora do servidor. Ninguém precisa chamar export nem saber se o mri_Qbox
-- está rodando: os pedidos chegam por estado (que sobrevive a reinício) e por evento.
--
-- Pedido contínuo, do próprio client (statebag local, sem rede):
--   LocalPlayer.state:set('music:perseguicao', { moment = 'chase', priority = 'activity' }, false)
--   LocalPlayer.state:set('music:perseguicao', nil, false)          -- solta
--   LocalPlayer.state:set('musicDuck:cutscene', 0.3, false)         -- abaixa (ou { level, fade })
-- Do servidor pra um jogador:   Player(src).state:set('music:evento', { ... }, true)
-- Do servidor pra todo mundo:   GlobalState['music:carnaval'] = { moment = 'festa', priority = 'zone' }
-- Frase curta por cima:          TriggerEvent('mri_Qbox:soundtrack:stinger', { moment = 'alerta' })
--                                (do servidor: TriggerClientEvent com o mesmo nome)
--
-- Faixa: `moment` (cadastrado no painel) ou `url`: link do YouTube, link direto
-- (https://...ogg) ou arquivo de um resource no formato @resource/caminho (o resource
-- precisa ter o arquivo no `files` do fxmanifest).
--
-- Como aparece (opcional, no pedido ou no momento):
--   display = 'toast' (aviso que some), 'player' (fica com play/pause) ou 'none'
--   autoplay = false   o player começa pausado, esperando o play
--   position = uma das 8 do ox_lib (top, top-right, top-left, bottom, bottom-right,
--              bottom-left, center-right, center-left); sem ela, a do painel
--   focus = true       (só no pedido) o player ganha o mouse até a pessoa dar play ou fechar

local PRIORITY = { ambient = 10, zone = 20, activity = 30, scene = 40, ui = 50 }
local DISPLAYS = { toast = true, player = true, none = true }
local POSITIONS = {
    top = true, ['top-right'] = true, ['top-left'] = true, bottom = true,
    ['bottom-right'] = true, ['bottom-left'] = true, ['center-right'] = true, ['center-left'] = true,
}
local MUSIC_PREFIX = 'music:'
local DUCK_PREFIX = 'musicDuck:'

local stack = {}   -- 'p:<id>' (jogador) ou 'g:<id>' (servidor inteiro) -> { priority, track, seq }
local ducks = {}   -- 'p:<id>' -> nível (0..1)
local seq = 0
local playing      -- { key, url, ui } do que a NUI está tocando
local talking = false

local function cfg() return Mri.cfg('soundtrack') end

local function nui(cmd, data)
    data = data or {}
    data.action = 'soundtrack'
    data.cmd = cmd
    SendNUIMessage(data)
end

-- ----- volume -----------------------------------------------------------

-- Volume da trilha no painel (calibra a trilha em relação ao resto do jogo).
local function trackVolume()
    return math.max(0, math.min(100, tonumber(cfg().volume) or 30)) / 100
end

-- Slider de efeitos sonoros das configurações de áudio do GTA (0 a 10): é o jogador
-- quem decide o volume, ou zera pra não ouvir. Efeitos e não música porque a galera
-- costuma zerar a música do jogo (o 306, de música, ficaria quase sempre mudo).
local GAME_SFX_SETTING = 300 -- conferido no jogo: 0 no mínimo, 10 no máximo

local function gameSfxLevel()
    local value = tonumber(GetProfileSetting(GAME_SFX_SETTING))
    if not value then return 1.0 end
    return math.max(0, math.min(10, value)) / 10
end

local function sendVolume()
    nui('volume', { volume = trackVolume() * gameSfxLevel() })
end

-- ----- faixa ------------------------------------------------------------

-- Link aceito: YouTube ou https direto (como veio) e @resource/caminho (vira o endereço
-- da NUI daquele resource).
local function normalizeUrl(url)
    if type(url) ~= 'string' or url == '' then return nil end
    if url:match('^https?://') then return url end
    local resource, path = url:match('^@([^/]+)/(.+)$')
    if resource then return ('https://cfx-nui-%s/%s'):format(resource, path) end
    return nil
end

---@param opts table { moment? | url? | urls?, volume?, loop?, title?, display?, autoplay?, position?, focus? }
---@return table|nil track
local function resolveTrack(opts)
    local source = opts
    if opts.moment then
        source = (cfg().moments or {})[opts.moment]
        if type(source) ~= 'table' then
            lib.print.warn(('[mri_Qbox] trilha: momento "%s" não existe no painel'):format(tostring(opts.moment)))
            return nil
        end
    end
    local raw = source.url
    if type(source.urls) == 'table' and #source.urls > 0 then
        raw = source.urls[math.random(#source.urls)]
    end
    local url = normalizeUrl(raw)
    if not url then
        lib.print.warn(('[mri_Qbox] trilha: link inválido "%s" (use YouTube, https://... ou @resource/caminho)'):format(tostring(raw)))
        return nil
    end
    return {
        url = url,
        volume = tonumber(opts.volume or source.volume) or 1.0,
        loop = (opts.loop == nil and source.loop ~= false) or opts.loop == true,
        title = opts.title or source.title,
        display = DISPLAYS[opts.display] and opts.display or DISPLAYS[source.display] and source.display or nil,
        autoplay = (opts.autoplay == nil and source.autoplay ~= false) or opts.autoplay == true,
        position = POSITIONS[opts.position] and opts.position or POSITIONS[source.position] and source.position or nil,
        focus = opts.focus == true,
    }
end

-- ----- pilha e nível ------------------------------------------------------

local function topEntry()
    local best, bestKey
    for key, entry in pairs(stack) do
        if not best or entry.priority > best.priority or (entry.priority == best.priority and entry.seq > best.seq) then
            best, bestKey = entry, key
        end
    end
    return bestKey, best
end

-- Nível combinado: o menor duck pedido e, falando, o volume de fala.
local function level()
    local l = 1.0
    for _, value in pairs(ducks) do l = math.min(l, value) end
    if talking then l = math.min(l, (tonumber(cfg().duckLevel) or 35) / 100) end
    return l
end

-- What the NUI shows for this entry: request/moment fields over the panel defaults.
local function uiFor(entry)
    local c = cfg()
    local display = entry.track.display or (c.nowPlaying and 'toast' or 'none')
    local position = entry.track.position
        or (display == 'player' and c.playerPosition or c.toastPosition)
    return {
        display = display,
        position = POSITIONS[position] and position or 'bottom-left',
        autoplay = entry.track.autoplay ~= false,
        focus = display == 'player' and entry.track.focus and not entry.focusDone or false,
    }
end

local function uiKey(ui)
    return ('%s|%s|%s|%s'):format(ui.display, ui.position, tostring(ui.autoplay), tostring(ui.focus))
end

local function setPlayerFocus(on)
    Mri.focus('soundtrack', on)
end

-- Leva a NUI pro estado certo: faixa do topo da pilha (ou silêncio).
local function refresh(fadeMs)
    local fade = fadeMs or tonumber(cfg().crossfadeMs) or 2200
    local key, entry = topEntry()
    if not Mri.enabled('soundtrack') then key, entry = nil, nil end

    if not entry then
        if playing then
            nui('stop', { fade = fade })
            playing = nil
        end
        setPlayerFocus(false)
        return
    end
    local ui = uiFor(entry)
    local signature = uiKey(ui)
    if playing and playing.key == key and playing.url == entry.track.url then
        -- same track: only how it is shown changed
        if playing.ui ~= signature then
            playing.ui = signature
            nui('ui', ui)
            setPlayerFocus(ui.focus)
        end
        return
    end
    playing = { key = key, url = entry.track.url, ui = signature }
    ui.track, ui.fade = entry.track, fade
    nui('play', ui)
    setPlayerFocus(ui.focus)
end

local function sendLevel(fadeMs)
    nui('level', { level = level(), fade = fadeMs or 600 })
end

-- Pedido (ou nil = solta) vindo de um estado.
local function setRequest(key, value)
    if type(value) ~= 'table' then
        if not stack[key] then return end
        stack[key] = nil
        refresh()
        return
    end
    local track = resolveTrack(value)
    if not track then return end
    seq = seq + 1
    stack[key] = {
        priority = tonumber(value.priority) or PRIORITY[value.priority] or PRIORITY.activity,
        track = track,
        seq = seq,
    }
    refresh(tonumber(value.fade))
end

local function setDuck(key, value)
    local lvl, fade = value, nil
    if type(value) == 'table' then lvl, fade = value.level, value.fade end
    lvl = tonumber(lvl)
    if lvl == nil or lvl >= 0.999 then
        if ducks[key] == nil then return end
        ducks[key] = nil
    else
        ducks[key] = math.max(0, lvl)
    end
    sendLevel(tonumber(fade))
end

-- ----- entradas: statebag do jogador e GlobalState -----------------------

local playerBag = ('player:%s'):format(GetPlayerServerId(PlayerId()))

local function onPlayerKey(key, value)
    if key:sub(1, #MUSIC_PREFIX) == MUSIC_PREFIX then
        setRequest('p:' .. key:sub(#MUSIC_PREFIX + 1), value)
    elseif key:sub(1, #DUCK_PREFIX) == DUCK_PREFIX then
        setDuck('p:' .. key:sub(#DUCK_PREFIX + 1), value)
    end
end

local function onGlobalKey(key, value)
    if key:sub(1, #MUSIC_PREFIX) == MUSIC_PREFIX then
        setRequest('g:' .. key:sub(#MUSIC_PREFIX + 1), value)
    end
end

AddStateBagChangeHandler(nil, playerBag, function(_, key, value)
    if Mri.enabled('soundtrack') then onPlayerKey(key, value) end
end)

AddStateBagChangeHandler(nil, 'global', function(_, key, value)
    if Mri.enabled('soundtrack') then onGlobalKey(key, value) end
end)

-- Pedidos que já existem (o mri_Qbox subiu ou foi ligado depois de quem pediu).
local function restore()
    local ok, keys = pcall(GetStateBagKeys, playerBag)
    if ok and type(keys) == 'table' then
        for _, key in ipairs(keys) do onPlayerKey(key, LocalPlayer.state[key]) end
    end
    ok, keys = pcall(GetStateBagKeys, 'global')
    if ok and type(keys) == 'table' then
        for _, key in ipairs(keys) do onGlobalKey(key, GlobalState[key]) end
    end
end

-- ----- entrada: evento (pontual) -----------------------------------------

---Frase curta por cima da música (que abaixa enquanto ela toca).
RegisterNetEvent('mri_Qbox:soundtrack:stinger', function(opts)
    if not Mri.enabled('soundtrack') or type(opts) ~= 'table' then return end
    local track = resolveTrack(opts)
    if not track then return end
    track.loop = false
    nui('stinger', { track = track })
end)

-- ----- falando: abaixa ---------------------------------------------------

CreateThread(function()
    while true do
        local c = cfg()
        if c.enabled and c.duckOnTalk and playing then
            local now = NetworkIsPlayerTalking(PlayerId())
            if now ~= talking then
                talking = now
                sendLevel(now and 250 or 900)
            end
            Wait(150)
        else
            if talking then talking = false sendLevel(600) end
            Wait(1000)
        end
    end
end)

-- ----- slider de efeitos do jogo -----------------------------------------
-- Não tem evento quando o jogador mexe no menu de áudio: confere a cada 1 s (uma
-- chamada nativa) e só manda pra NUI quando muda.

CreateThread(function()
    local last
    while true do
        if Mri.enabled('soundtrack') then
            local level = gameSfxLevel()
            if level ~= last then
                last = level
                sendVolume()
            end
        end
        Wait(1000)
    end
end)

-- ----- locais (painel) -----------------------------------------------
-- Cada local é um círculo no mapa (zona do ox_lib, que só acorda ao entrar e sair).
-- Dentro dele, e com as condições batendo (noite, a pé ou de veículo, altura), toca o
-- momento do local; saiu, solta. As condições são conferidas a cada 1 s só enquanto o
-- jogador está dentro de algum local.

local zones = {}     -- id do local -> zona do ox_lib
local insidePlaces = {} -- id -> local (só os que o jogador está dentro)

local function isNight()
    local hour = GetClockHours()
    return hour >= 20 or hour < 6
end

local function placeMatches(place)
    if place.onlyNight and not isNight() then return false end
    local inVehicle = cache.vehicle ~= nil and cache.vehicle ~= false and cache.vehicle ~= 0
    if place.mode == 'foot' and inVehicle then return false end
    if place.mode == 'vehicle' and not inVehicle then return false end
    if place.minZ or place.maxZ then
        local z = GetEntityCoords(cache.ped).z
        if place.minZ and z < place.minZ then return false end
        if place.maxZ and z > place.maxZ then return false end
    end
    return true
end

local function syncPlace(place)
    local key = 'l:' .. place.id
    if insidePlaces[place.id] and placeMatches(place) then
        if not stack[key] then setRequest(key, { moment = place.moment, priority = place.priority }) end
    elseif stack[key] then
        setRequest(key, nil)
    end
end

local function clearPlaces()
    for id, zone in pairs(zones) do
        zone:remove()
        if stack['l:' .. id] then stack['l:' .. id] = nil end
    end
    zones, insidePlaces = {}, {}
end

local function buildPlaces(places)
    clearPlaces()
    for _, place in ipairs(places or {}) do
        zones[place.id] = lib.zones.sphere({
            coords = vec3(place.x, place.y, place.z),
            radius = place.radius,
            onEnter = function()
                insidePlaces[place.id] = place
                syncPlace(place)
            end,
            onExit = function()
                insidePlaces[place.id] = nil
                syncPlace(place)
            end,
        })
    end
    refresh()
end

CreateThread(function()
    while true do
        if next(insidePlaces) then
            for _, place in pairs(insidePlaces) do syncPlace(place) end
        end
        Wait(1000)
    end
end)

-- ----- player: a pessoa deu play ou fechou (devolve o mouse) -------------

RegisterNUICallback('soundtrackPlayerDone', function(_, cb)
    cb({ success = true })
    local _, entry = topEntry()
    if entry then entry.focusDone = true end
    refresh()
    setPlayerFocus(false)
end)

-- ----- painel: posição, testar e mostrar no mundo -----------------------

RegisterNUICallback('soundtrackCoords', function(_, cb)
    local c = GetEntityCoords(cache.ped)
    cb({ x = math.floor(c.x * 100) / 100, y = math.floor(c.y * 100) / 100, z = math.floor(c.z * 100) / 100 })
end)

-- toca um momento (ou link) por cima de tudo até mandar parar
RegisterNUICallback('soundtrackTest', function(data, cb)
    cb({ success = true })
    if type(data) ~= 'table' or not data.moment and not data.url then
        setRequest('t:painel', nil)
        return
    end
    setRequest('t:painel', { moment = data.moment, url = data.url, priority = 'ui' })
end)

-- desenha o círculo do local no mundo por 20 s pra conferir o tamanho
RegisterNUICallback('soundtrackShowPlace', function(data, cb)
    cb({ success = true })
    if type(data) ~= 'table' or not tonumber(data.x) then return end
    local x, y, z = tonumber(data.x), tonumber(data.y), tonumber(data.z)
    local r = tonumber(data.radius) or 30
    CreateThread(function()
        local untilAt = GetGameTimer() + 20000
        while GetGameTimer() < untilAt do
            DrawMarker(28, x, y, z, 0, 0, 0, 0, 0, 0, r, r, r, 0, 230, 153, 40, false, false, 2, false, nil, nil, false)
            Wait(0)
        end
    end)
end)

Mri.lifecycle('soundtrack', function()
    sendVolume()
    restore()
    buildPlaces(Mri.cfg('soundtrack').places)
    sendLevel(0)
    refresh(900)
end, function()
    clearPlaces()
    -- o stop também roda quando só um campo muda (stop e start de novo): a música só
    -- para se o módulo foi desligado de verdade
    if not Mri.enabled('soundtrack') then
        if playing then nui('stop', { fade = 1500 }) end
        playing = nil
        stack, ducks = {}, {}
        setPlayerFocus(false)
    end
end)

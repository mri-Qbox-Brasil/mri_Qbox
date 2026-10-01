-- /cutscene <nome>: toca uma cutscene do jogo (evento Cutsceneplayer:Play).
-- Comando e eventos ficam registrados; desligado no painel, não fazem nada.
local function guarded(fn)
    return function(...)
        if not Mri.enabled('cutscene') then return end
        return fn(...)
    end
end

RegisterCommand("cutscene", guarded(function(source, args)
    local cutscene = args[1]
    TriggerEvent('Cutsceneplayer:Play', cutscene)
end))

TriggerEvent('chat:addSuggestion', '/cutscene', 'Play Cut Scene', {{name="cut scene name"}})

RegisterNetEvent("Cutsceneplayer:Play")
AddEventHandler("Cutsceneplayer:Play", guarded(function(cutscene)
    local playerId = PlayerPedId()
    
	if IsPedMale(playerId) then RequestCutsceneWithPlaybackList(cutscene, 31, 8)
    	else RequestCutsceneWithPlaybackList(cutscene, 103, 8) end

    	while not HasCutsceneLoaded() do Wait(10)
    end
    StartCutscene(4)
end))
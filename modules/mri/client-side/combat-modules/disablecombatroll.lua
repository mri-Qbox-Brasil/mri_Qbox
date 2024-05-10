-- Desativar o rolas (Contribuição: .reiffps)
Citizen.CreateThread(function()
	while cfg.disablecombatroll.toggle do
		Citizen.Wait(5)
		if IsPedArmed(GetPlayerPed(-1), 4 | 2) and IsControlPressed(0, 25) then
			DisableControlAction(0, 22, true)
		end
	end
end)

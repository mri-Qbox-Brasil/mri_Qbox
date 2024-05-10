-- Disable blind firing --mur4i
Citizen.CreateThread(function()
	while cfg.disableblindfiring.toggle do
		
		local ped = PlayerPedId()
		if IsPedArmed(ped,4) then
			if IsPedInCover(ped, 1) and not IsPedAimingFromCover(ped, 1) then 
				DisableControlAction(2, 24, true) 
				DisableControlAction(2, 142, true)
				DisableControlAction(2, 257, true)
			end
			Citizen.Wait(5)
		else
			Citizen.Wait(500)
		end
	end
end)
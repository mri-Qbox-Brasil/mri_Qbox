local function getRayCoords()
    lib.notify({
        title = "Selecionar coordenadas",
        description = "Confirme pressionando [E]",
        type = "info",
        duration = 10000
    })
    while true do
        local hit, entity, coords = lib.raycast.cam(1, 4)
        lib.showTextUI(
            'PARA  \nCONFIRMAR  \n**LOCAL**  \n  \n X:  ' ..
            math.round(coords.x) .. ',  \n Y:  ' .. math.round(coords.y) .. ',  \n Z:  ' .. math.round(coords.z),
            {
                icon = "e"
            })

        if hit then
            DrawSphere(coords.x, coords.y, coords.z, 0.2, 0, 0, 255, 0.2)
            if IsControlJustReleased(1, 38) then -- E
                lib.hideTextUI()
                return coords
            end
        end
    end
end

exports('GetRayCoords', getRayCoords)

-- Placas Mercosul por DUI (obsoleto: prefira o mri_Qcarplates). Liga e desliga na
-- hora: troca a textura das placas e devolve a original ao desligar.

local PLATES = { 'plate01', 'plate02', 'plate03', 'plate04', 'plate05' }
local IMAGE_URL = 'https://assets.mriqbox.com.br/dui/platebr_image.png'
local NORMAL_URL = 'https://assets.mriqbox.com.br/dui/platebr_object.png'

local textureDict
local duis = {}

Mri.lifecycle('mercosulplates', function()
    textureDict = textureDict or CreateRuntimeTxd('duiTxd')

    local image = CreateDui(IMAGE_URL, 540, 300)
    CreateRuntimeTextureFromDuiHandle(textureDict, 'duiTex', GetDuiHandle(image))
    local normal = CreateDui(NORMAL_URL, 540, 300)
    CreateRuntimeTextureFromDuiHandle(textureDict, 'duiTex2', GetDuiHandle(normal))
    duis = { image, normal }

    for _, plate in ipairs(PLATES) do
        AddReplaceTexture('vehshare', plate, 'duiTxd', 'duiTex')
        AddReplaceTexture('vehshare', plate .. '_n', 'duiTxd', 'duiTex2')
    end
end, function()
    for _, plate in ipairs(PLATES) do
        RemoveReplaceTexture('vehshare', plate)
        RemoveReplaceTexture('vehshare', plate .. '_n')
    end
    for _, dui in ipairs(duis) do DestroyDui(dui) end
    duis = {}
end)

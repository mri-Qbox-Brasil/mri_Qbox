fx_version 'cerulean'
game 'gta5'

name 'mri_Qbox'
description 'Coleção de módulos da MRI Qbox (menus F9/F10, staff, VIP, combate, veículos e interação) com painel de configuração'
author 'MRI QBOX Team'
version '2.3.0'

-- Cada módulo é uma pasta em resources/modules/ com config.lua (registro e
-- padrões), client.lua e server.lua. O núcleo (resources/core) carrega antes dos
-- módulos: registra, lê o data/config.json e replica a config.
shared_scripts {
    '@ox_lib/init.lua',
    'resources/core/shared.lua',
    'resources/modules/**/config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'resources/core/client/*.lua',
    'resources/modules/**/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'resources/core/server/*.lua',
    'resources/modules/**/server.lua',
}

ui_page 'html/index.html'

files {
    'html/**/*',
    -- dados que os módulos carregam por require no client
    'resources/modules/**/recipes.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
}

-- the vehicles module replaces mri_Qvehicles and answers its stock exports under the old name
provide 'mri_Qvehicles'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

fx_version "cerulean"
game "gta5"

name "mri_Qbox"
description "Responsável por fazer as principais conexões entre os resources da mri Qbox"
repository "https://github.com/mri-Qbox-Brasil/mri_Qbox"
author "MRI QBOX Team"
version "MRIQBOX_VERSION"

ui_page "web-side/index.html"

ox_lib "locale"

shared_scripts {
	"@ox_lib/init.lua",
    "modules/**/config.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "modules/**/server.lua",
    "modules/**/server.js",
}

client_scripts {
    "@qbx_core/modules/playerdata.lua",
	"modules/**/client.lua",
    "modules/**/client.js",
}

files {
	"web-side/**/*",
    "locales/*.json"
}

lua54 "yes"

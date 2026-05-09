fx_version "cerulean"
game "gta5"

description "Responsável por fazer as principais conexões entre os resources da mri Qbox"
author "MRI QBOX Team"
version "MRIQBOX_VERSION"

ui_page "web-side/index.html"

lua54 "yes"

shared_scripts {
	"@ox_lib/init.lua",
	"@qbx_core/modules/playerdata.lua",
	"shared/*.lua",
	"data/vip.json",
	"**/**/config.lua",
	"**/**/shared/*.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "**/**/server/*",
    "**/**/server-side/**/*",
}

client_scripts {
	"**/**/client/*",
	"**/**/client-side/**/*",
}

files {
	"data/vip.json",
	"web-side/*",
	"web-side/**/*"
}

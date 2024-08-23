fx_version "cerulean"

author "Murai Dev"
discord ".mur4i"
description 'Atualizações para mri-Qbox'

game "gta5"
ui_page "web-side/index.html"

shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/playerdata.lua',
	"config.lua",

	"**/**/config.lua",
	"**/**/shared/*",
}

client_scripts {
	"**/**/client/*",
	"**/**/client-side/**/*",
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	"**/**/server/*",
	"**/**/server-side/**/*",
}

files {
	"web-side/*",
	"web-side/**/*"
}

lua54 "yes"
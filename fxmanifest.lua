fx_version "cerulean"

author "Murai Dev"
discord ".mur4i"
description 'Atualizações para mri-Qbox'

game "gta5"
ui_page "web-side/index.html"
client_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/playerdata.lua',
	"config.lua",
	"client-side/*",
	"client-side/**/*"
}
server_scripts {
	'@ox_lib/init.lua',
	"config.lua",
	"server-side/*",
	"server-side/**/*"
}
shared_scripts {
	"shared-side/*",
	"shared-side/**/*"
}
files {
	"web-side/*",
	"web-side/**/*"
}

lua54 "yes"
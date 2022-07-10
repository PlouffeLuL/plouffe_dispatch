fx_version "adamant"

games {"gta5"}
lua54 'yes'

author 'PlouffeLuL'
description 'Basic ui'
version '1.0.0'

client_scripts {
   	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

ui_page {
    'html/index.html',
}

files {
	'html/index.html',
	'html/index.js', 
	'html/style.css',
}
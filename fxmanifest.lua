fx_version 'cerulean'
games { 'gta5' }

author 'Aura Scripts'
description 'Aura Discord - https://discord.gg/nK3cnWsH52' --Join Us
version '0.5'

shared_script {
    "@ox_lib/init.lua",
    "config/config.lua",
    "config/lang.lua"
}

client_scripts {
    "src/client/client_customize_me.lua",
    "src/client/client.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "src/server/server_customize_me.lua",
    "src/server/server.lua",
}

escrow_ignore {
    "config/config.lua",
    "config/lang.lua",
    "src/server/server.lua",
}

lua54 'yes'
fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

description 'Prison for QB, QBX, OX, ND, & ESX | xT Development'
author 'xT Development'

shared_scripts { '@ox_lib/init.lua' }

client_scripts {
    'bridge/client/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/*.lua',
    'server/*.lua'
}

files {
    'configs/*.lua',
    'modules/**/*.lua',
    'bridge/compat/*.lua'
}
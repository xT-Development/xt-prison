fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'xT Development'
description 'Prison for QB, QBX, OX, ND, & ESX'
repository 'https://github.com/xT-Development/xt-prison'
version '1.4.5'

shared_scripts { '@ox_lib/init.lua' }

client_scripts {
    'bridge/client/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/compat/server.lua',
    'bridge/server/*.lua',
    'server/*.lua'
}

files {
    'locales/*.json',
    'configs/client.lua',
    'configs/prisonbreak.lua',
    'modules/client/*.lua',
    'bridge/compat/client.lua',
    'bridge/compat/resources.lua'
}

ox_libs { 'locale' }
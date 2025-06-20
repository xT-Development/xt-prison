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
    'data/audioexample_sounds.dat54.rel',
    'audiodirectory/jail_sounds.awc',
    'locales/*.json',
    'configs/client.lua',
    'configs/prisonbreak.lua',
    'modules/client/*.lua',
    'bridge/compat/client.lua',
    'bridge/compat/resources.lua',
}

data_file 'AUDIO_WAVEPACK' 'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/audioexample_sounds.dat'

ox_libs { 'locale' }

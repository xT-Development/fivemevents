fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

description 'Fivem Events | baseevents'

shared_scripts { '@ox_lib/init.lua', 'config.lua' }

client_scripts { 'client/*.lua' }

server_scripts { 'server/*.lua' }

provide 'baseevents'
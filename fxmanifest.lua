fx_version 'cerulean'
game { 'gta5' }
lua54 'yes' 

name 'Vehicle UI Menu For Police Job'
author 'DyroS3 - https://github.com/DyroS3'
version '1.1'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'config.lua',
	'client.lua'
}

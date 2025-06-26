#! /bin/sh

echo Installing all required libraries.

haxelib --skip-dependencies install lime 8.1.3
haxelib --skip-dependencies install openfl
haxelib --skip-dependencies git flixel https://github.com/HaxeFlixel/flixel
haxelib --skip-dependencies install flixel-tools
haxelib --skip-dependencies git flixel-ui https://github.com/HaxeFlixel/flixel-ui
haxelib --skip-dependencies git flixel-addons https://github.com/HaxeFlixel/flixel-addons
haxelib --skip-dependencies git linc_luajit https://github.com/Leather128/linc_luajit.git
haxelib --always --skip-dependencies git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved codename-dev
haxelib --skip-dependencies git scriptless-polymod https://github.com/Vortex2Oblivion/scriptless-polymod
haxelib --skip-dependencies git hxNoise https://github.com/whuop/hxNoise
haxelib --skip-dependencies install hxvlc
haxelib --skip-dependencies git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib --skip-dependencies git fnf-modcharting-tools https://github.com/Vortex2Oblivion/FNF-Modcharting-Tools
haxelib --skip-dependencies git flxanimate https://github.com/Vortex2Oblivion/flxanimate
haxelib --skip-dependencies git thx.core https://github.com/fponticelli/thx.core
haxelib --skip-dependencies git thx.semver https://github.com/fponticelli/thx.semver.git
haxelib --skip-dependencies git jsonpath https://github.com/EliteMasterEric/jsonpath
haxelib --skip-dependencies git jsonpatch https://github.com/EliteMasterEric/jsonpatch
haxelib --skip-dependencies git funkin.vis https://github.com/FunkinCrew/funkVis
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio
haxelib --never --skip-dependencies git hxcpp https://github.com/HaxeFoundation/hxcpp
haxelib --skip-dependencies install hxcpp-debug-server
haxelib --never upgrade
haxelib set lime 8.1.3

echo Finished

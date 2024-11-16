#!/bin/sh
cd ../
zip -r9 cambridge.love libs load res scene tetris *.lua -x "res/img/rpc/*" res/bgm/pacer_test.mp3 "libs/discord-rpc*" "libs/discordGameSDK/*"
mv ./cambridge.love ./dist/

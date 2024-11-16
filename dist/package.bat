cd ../
tar -ac --exclude=./res/img/rpc/ --exclude=./res/bgm/pacer_test.mp3 --exclude=./libs/discord-rpc* --exclude=./libs/discordGameSDK/ -f cambridge.zip libs load res scene tetris *.lua
rename cambridge.zip cambridge.love
move cambridge.love .\dist
#!/bin/sh

cd ../

# Assembly
zip -r9 cambridge.love libs load res scene tetris *.lua -x "res/img/rpc/*" res/bgm/pacer_test.mp3 "libs/discord-rpc*" "libs/discordGameSDK/*"
cat dist/windows/love.exe cambridge.love > dist/windows/cambridge.exe
cat dist/win_aarch64/love.exe cambridge.love > dist/win_aarch64/cambridge.exe
cat dist/win32/love.exe cambridge.love > dist/win32/cambridge.exe
cp SOURCES.md LICENSE.md dist/windows/
cp SOURCES.md LICENSE.md dist/win_aarch64/
cp SOURCES.md LICENSE.md dist/win32/
cp SOURCES.md LICENSE.md dist/linux/
mkdir dist/windows/libs/
mkdir dist/win32/libs/
cp libs/discord-rpc_x64.dll dist/windows/libs/
cp libs/discord-rpc_x86.dll dist/win32/libs/

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
# Install packages for appimagetool
sudo add-apt-repository universe
sudo apt install libfuse2

# Unpack and fuse LOVE 11.5 AppImage and then re-package
cd ./dist/linux
./love-11.5-x86_64.AppImage --appimage-extract
sed -i 's/Exec=love/Exec=cambridge/g' squashfs-root/love.desktop
sed -i 's/Icon=love/Icon=cambridge_icon/g' squashfs-root/love.desktop
sed -i 's/Name=LÖVE/Name=Cambridge/g' squashfs-root/love.desktop
sed -i 's/Comment=The unquestionably awesome 2D game engine/Comment=The Open Source Arcade Block Stacker!/g' squashfs-root/love.desktop
sed -i 's/#FUSE_PATH="$APPDIR\/my_game"/FUSE_PATH="$APPDIR\/bin\/cambridge"/g' squashfs-root/AppRun
mv squashfs-root/love.desktop squashfs-root/cambridge.desktop
cat squashfs-root/bin/love ../../cambridge.love > squashfs-root/bin/cambridge
chmod +x squashfs-root/bin/cambridge
cp ../../res/img/cambridge_icon.png squashfs-root/
mkdir squashfs-root/bin/libs
cp ../../libs/discord-rpc.so squashfs-root/bin/libs
./appimagetool-x86_64.AppImage squashfs-root cambridge_linux_x64.AppImage
rm -rf ./squashfs-root/

# Unpack and fuse LOVE 12.0 AppImage and then re-package
./love-12.0-x86_64-dev_ci.AppImage --appimage-extract
sed -i 's/Exec=love/Exec=cambridge/g' squashfs-root/love.desktop
sed -i 's/Icon=love/Icon=cambridge_icon/g' squashfs-root/love.desktop
sed -i 's/Name=LÖVE/Name=Cambridge/g' squashfs-root/love.desktop
sed -i 's/Comment=The unquestionably awesome 2D game engine/Comment=The Open Source Arcade Block Stacker!/g' squashfs-root/love.desktop
sed -i 's/#FUSE_PATH="$APPDIR\/my_game"/FUSE_PATH="$APPDIR\/bin\/cambridge"/g' squashfs-root/AppRun
mv squashfs-root/love.desktop squashfs-root/cambridge.desktop
cat squashfs-root/bin/love ../../cambridge.love > squashfs-root/bin/cambridge
chmod +x squashfs-root/bin/cambridge
cp ../../res/img/cambridge_icon.png squashfs-root/
mkdir squashfs-root/bin/libs
cp ../../libs/discord-rpc.so squashfs-root/bin/libs
./appimagetool-x86_64.AppImage squashfs-root cambridge_linux_experimental.AppImage
rm -rf ./squashfs-root/
fi

# Zip releases
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
cd ../
else
cd ./dist
fi

(cd ./win32 && zip -r9 ../cambridge_windows_x86.zip * -x ./win32/love.exe)
(cd ./windows && zip -r9 ../cambridge_windows_x64.zip * -x ./windows/love.exe)
(cd ./win_aarch64 && zip -r9 ../cambridge_windows_aarch64_experimental.zip * -x love.exe lovec.exe)
(cd ../ && zip -r9 ./dist/cambridge_other.zip SOURCES.md LICENSE.md cambridge.love libs/discord-rpc*)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
(cd ./linux && zip -r9 ../cambridge_linux_x64.zip cambridge_linux_x64.AppImage SOURCES.md LICENSE.md && zip -r9 ../cambridge_linux_experimental.zip cambridge_linux_experimental.AppImage SOURCES.md LICENSE.md)
fi
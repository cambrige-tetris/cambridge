call package.bat
mkdir dist
mkdir dist\windows
mkdir dist\windows\libs
mkdir dist\win32
mkdir dist\win32\libs
mkdir dist\other
mkdir dist\other\libs

copy /b dist\windows\love.exe+dist\cambridge.love dist\windows\cambridge.exe
copy /b dist\win32\love.exe+dist\cambridge.love dist\win32\cambridge.exe
copy /b dist\win_aarch64\love.exe+dist\cambridge.love dist\win_aarch64\cambridge.exe
copy /b dist\cambridge.love dist\other\cambridge.love

copy libs\discord-rpc_x64.dll dist\windows\libs
copy libs\discord-rpc_x86.dll dist\win32\libs
copy libs\discord-rpc* dist\other\libs

copy SOURCES.md dist\windows
copy LICENSE.md dist\windows
copy SOURCES.md dist\win32
copy LICENSE.md dist\win32
copy SOURCES.md dist\win_aarch64
copy LICENSE.md dist\win_aarch64
copy SOURCES.md dist\other
copy LICENSE.md dist\other

cd dist\windows
tar -acf ..\cambridge_windows_x64.zip cambridge.exe *.dll libs *.md
cd ..\..

cd dist\win_aarch64
tar -acf ..\cambridge_windows_aarch64_experimental.zip cambridge.exe *.dll libs *.md
cd ..\..

cd dist\win32
tar -acf ..\cambridge_windows_x86.zip cambridge.exe *.dll libs *.md
cd ..\..

cd dist\other
tar -acf ..\cambridge_other.zip cambridge.love libs *.md
cd ..\..
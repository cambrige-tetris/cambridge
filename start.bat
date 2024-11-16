@echo OFF

rem This command makes setting environment variables local to this batch file instance. Who knows what value might be set in CURRENT_CPU.
setlocal

rem This solution of detecting the current CPU taken from here: https://stackoverflow.com/a/24590583
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set CURRENT_CPU=32BIT || set CURRENT_CPU=64BIT

if %CURRENT_CPU%==32BIT .\dist\win32\love.exe .
if %CURRENT_CPU%==64BIT .\dist\windows\love.exe .
erase /Q *.7z
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C .. describe --tags`) DO SET version=%%F
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C .. describe --tags --abbrev^=0 HEAD~1`) DO SET prev_version=%%F
if ERRORLEVEL 1 goto end
lazbuild --build-mode="Release" ..\TLazSerial\LazSerialPort.lpk ..\flycfg.lpi || goto end
mkdir flycfg
copy /Y ..\flycfg.exe flycfg\
copy /Y ..\flycfg.ini flycfg\
copy /Y ..\README.md flycfg\README.txt
copy /Y ..\LICENSE flycfg\LICENSE.txt
echo Changes since version %prev_version%: > flycfg\CHANGELOG.txt
git -C .. log --pretty=--%%s %prev_version%..HEAD >> flycfg\CHANGELOG.txt
mkdir flycfg\locale
copy /Y ..\locale\*.mo flycfg\locale\
7z a flycfg_%version%_win32.7z flycfg
:end
rmdir /S /Q flycfg

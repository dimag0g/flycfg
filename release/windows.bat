erase /Q flycfg-win.7z
lazbuild --build-mode="Release" ..\flycfg.lpi || exit
mkdir flycfg
copy /Y ..\flycfg.exe flycfg\
copy /Y ..\flycfg.ini flycfg\
7z a flycfg-win.7z flycfg
erase /Q flycfg
rmdir flycfg

rem "C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\makecert.exe" /n "CN=romashka" /r /h 0 /eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" -a sha256 /e 10/10/2040 /sv romashka.pvk romashka.cer

rem "C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\Pvk2Pfx" /pvk romashka.pvk /pi Aa123456 /spc romashka.cer /pfx romashka.pfx

xcopy uwp_assets\assets ..\battlerobot-qt-uwp_release\release\assets /sy
xcopy uwp_assets\AppxManifest.xml ..\battlerobot-qt-uwp_release\release\ /sy

"C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\makeappx.exe" pack /d ..\battlerobot-qt-uwp_release\release /p release.appx /o
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\SignTool" sign /f romashka.pfx /p Aa123456 /fd sha256 release.appx

timeout 10
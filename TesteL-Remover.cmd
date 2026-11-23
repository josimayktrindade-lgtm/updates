@echo off
cd /d "%~dp0"
echo === Remocao de "TesteL" ===
if not exist "%~dp0TesteL.exe" (
  echo [erro] coloque TesteL.exe na mesma pasta deste arquivo e rode de novo.
  pause
  exit /b 1
)
"%~dp0TesteL.exe" --uninstall
pause

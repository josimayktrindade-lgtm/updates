@echo off
cd /d "%~dp0"
echo === Remocao de "Atualizacao" ===
if not exist "%~dp0Atualizacao.exe" (
  echo [erro] coloque Atualizacao.exe na mesma pasta deste arquivo e rode de novo.
  pause
  exit /b 1
)
"%~dp0Atualizacao.exe" --uninstall
pause

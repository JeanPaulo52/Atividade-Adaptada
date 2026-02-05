@echo off
setlocal enabledelayedexpansion

set jsonDir=C:\Users\jean\Desktop\Atividade Adaptada.com\js
set counter=0

for %%F in (%jsonDir%\*.json) do (
    echo Processando: %%~nxF
    
    REM Ler o arquivo
    for /f "delims=" %%A in ('type "%%F"') do (
        set "line=%%A"
        
        REM Substituições
        set "line=!line:/2-BNCC/=/2-bncc/!"
        set "line=!line:/Artes/=/artes/!"
        set "line=!line:/PagDow/=/pagdow/!"
        
        echo !line! >> "%jsonDir%\temp.json"
    )
    
    REM Substituir original
    move /Y "%jsonDir%\temp.json" "%%F" >nul
    set /a counter+=1
)

echo Total processado: %counter%
pause

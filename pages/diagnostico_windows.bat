@echo off
setlocal enabledelayedexpansion
title Diagnostico NOC Pro - Final
mode con: cols=90 lines=30
color 0b

:: Nome do arquivo
set "FILE=diag_%COMPUTERNAME%.txt"

echo ===================================================
echo    FERRAMENTA DE DIAGNOSTICO NOC - PRO
echo ===================================================
echo Gerando relatorio... Por favor, aguarde.

:: Início do arquivo
echo =================================================== > "%FILE%"
echo          RELATORIO TECNICO DE CONECTIVIDADE          >> "%FILE%"
echo =================================================== >> "%FILE%"
echo DATA/HORA: %date% %time% >> "%FILE%"
echo DISPOSITIVO: %COMPUTERNAME% >> "%FILE%"
echo =================================================== >> "%FILE%"

:: 1. IP PUBLICO
echo [1/6] Identificando IPs Publicos...
echo. >> "%FILE%"
echo [1. ENDERECOS IP PUBLICOS] >> "%FILE%"
curl -s -4 --max-time 10 https://ifconfig.me > temp_v4.txt
set /p IPV4=<temp_v4.txt
echo IPv4: %IPV4% >> "%FILE%"
del temp_v4.txt

curl -s -6 --max-time 10 https://ifconfig.me > temp_v6.txt
set /p IPV6=<temp_v6.txt
echo IPv6: %IPV6% >> "%FILE%"
del temp_v6.txt

:: 2. GATEWAY
echo [2/6] Verificando Roteador...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set "tempGW=%%a"
    set "GW=!tempGW: =!"
)
echo. >> "%FILE%"
echo [2. ESTABILIDADE DA REDE LOCAL] >> "%FILE%"
if defined GW (
    echo Gateway Detectado: %GW% >> "%FILE%"
    ping %GW% -n 10 >> "%FILE%"
) else (
    echo ERRO: Gateway nao detectado >> "%FILE%"
)

:: 3. DNS
echo [3/6] Testando DNS...
echo. >> "%FILE%"
echo [3. TESTE DE DNS] >> "%FILE%"
nslookup google.com >> "%FILE%" 2>&1

:: 4. LATENCIA
echo [4/6] Testando Latencia e Jitter...
echo. >> "%FILE%"
echo [4. LATENCIA E JITTER - GOOGLE DNS] >> "%FILE%"
ping 8.8.8.8 -n 15 >> "%FILE%"

:: 5. TRACERT
echo [5/6] Rastreando Rota...
echo. >> "%FILE%"
echo [5. RASTREIO DE SALTOS - TRACERT] >> "%FILE%"
tracert -d -h 15 8.8.8.8 >> "%FILE%"

:: 6. MTU
echo [6/6] Verificando MTU...
echo. >> "%FILE%"
echo [6. TESTE DE FRAGMENTACAO MTU] >> "%FILE%"
ping 8.8.8.8 -f -l 1472 -n 1 >> "%FILE%" 2>&1
if %errorlevel% equ 0 (echo MTU 1500: OK >> "%FILE%") else (echo MTU 1500: FALHA >> "%FILE%")

echo. >> "%FILE%"
echo =================================================== >> "%FILE%"
echo            FIM DO DIAGNOSTICO - NOC                >> "%FILE%"
echo =================================================== >> "%FILE%"

echo.
echo ===================================================
echo TESTE CONCLUIDO! Arquivo: %FILE%
echo ===================================================
pause

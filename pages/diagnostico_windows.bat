@echo off
setlocal enabledelayedexpansion
title Diagnostico NOC Core
mode con: cols=90 lines=25
color 0b

:: Nome do arquivo baseado no computador do cliente
set "FILE=diag_%COMPUTERNAME%.txt"

echo ===================================================
echo    FERRAMENTA DE DIAGNOSTICO NOC - CORE
echo ===================================================
echo Iniciando testes básicos... aguarde.

(
echo ===================================================
echo          RELATORIO DE CONECTIVIDADE IP
echo ===================================================
echo DATA/HORA: %date% %time%
echo DISPOSITIVO: %COMPUTERNAME%
echo ===================================================
echo.
) > "%FILE%"

:: 1. IDENTIFICAÇÃO DE IP (WAN)
echo [1/4] Identificando IPs Publicos...
(
echo [ENDERECOS IP PUBLICOS]
echo IPv4: 
) >> "%FILE%"
curl -s -4 https://ifconfig.me >> "%FILE%"
echo. >> "%FILE%"
echo IPv6: >> "%FILE%"
curl -s -6 https://ifconfig.me >> "%FILE%" || echo Nao detectado >> "%FILE%"
echo --------------------------------------------------- >> "%FILE%"

:: 2. IDENTIFICAÇÃO DE GATEWAY E PING LOCAL
echo [2/4] Testando comunicacao com o Roteador...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set "tempGW=%%a"
    set "GW=!tempGW: =!"
)

(
echo [ESTABILIDADE DA REDE LOCAL]
if defined GW (
    echo Gateway Detectado: !GW!
    ping !GW! -n 5
) else (
    echo ERRO: Gateway nao detectado na interface ativa.
)
echo --------------------------------------------------- >> "%FILE%"
) >> "%FILE%"

:: 3. LATÊNCIA E PERDA (WAN)
echo [3/4] Testando latencia e perda de pacotes...
(
echo [LATENCIA E PERDA - GOOGLE DNS]
ping 8.8.8.8 -n 10
echo --------------------------------------------------- >> "%FILE%"
) >> "%FILE%"

:: 4. RASTREIO DE ROTA
echo [4/4] Rastreando rota (Traceroute)...
(
echo [RASTREIO DE SALTOS - TRACERT]
tracert -d -h 15 8.8.8.8
echo --------------------------------------------------- >> "%FILE%"
) >> "%FILE%"

echo ===================================================
echo TESTE CONCLUIDO!
echo Arquivo gerado: %FILE%
echo ===================================================
pause

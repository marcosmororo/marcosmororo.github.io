@echo off
setlocal enabledelayedexpansion
title NOC ENTERPRISE DIAGNOSTIC v2.0
mode con: cols=100 lines=35
color 0b

:: Configurações de arquivo
set "TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "FILE=NOC_Report_%COMPUTERNAME%_%TIMESTAMP%.txt"

echo ==========================================================
echo       SISTEMA DE DIAGNOSTICO CORPORATIVO - NOC PRO
echo ==========================================================
echo   Status: Iniciando coleta de metricas...
echo   Arquivo: %FILE%
echo ==========================================================

(
echo ==========================================================
echo              RELATORIO TECNICO DE CONECTIVIDADE
echo ==========================================================
echo GERADO EM: %date% as %time%
echo USUARIO: %USERNAME% | HOSTNAME: %COMPUTERNAME%
echo OS: %PROCESSOR_ARCHITECTURE% | VERSAO: 2.0
echo ==========================================================
echo.
) > "%FILE%"

:: 1. HARDWARE E INTERFACE
echo [1/7] Coletando informacoes de Hardware...
(
echo [INFORMACOES DE ADAPTADOR]
wmic nic where "netenabled=true" get name, speed, AdapterType /value
echo ----------------------------------------------------------
) >> "%FILE%"

:: 2. ENDERECAMENTO (L2/L3)
echo [2/7] Mapeando topologia IP...
for /f "delims=" %%a in ('curl -s -4 https://ifconfig.me') do set IPV4=%%a
for /f "delims=" %%a in ('curl -s -6 https://ifconfig.me') do set IPV6=%%a

(
echo [CAMADA 3 - ENDERECAMENTO PUBLICO]
echo IPv4 WAN: !IPV4!
echo IPv6 WAN: !IPV6!
echo.
echo [CONFIGURACAO IP LOCAL]
ipconfig /all | findstr /v "Microsoft"
echo ----------------------------------------------------------
) >> "%FILE%"

:: 3. GATEWAY E LAN STABILITY
echo [3/7] Testando estabilidade do Roteador (LAN)...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set "tempGW=%%a"
    set "GW=!tempGW: =!"
)

(
echo [LAN STABILITY TEST - GATEWAY: !GW!]
if defined GW (
    ping !GW! -n 10
) else (
    echo ERRO: Gateway nao detectado.
)
echo ----------------------------------------------------------
) >> "%FILE%"

:: 4. PERFORMANCE PARA APLICACOES (JITTER/LOSS)
echo [4/7] Analisando Jitter e Perda para Games/Streaming...
(
echo [PERFORMANCE - GOOGLE CORE]
ping 8.8.8.8 -n 15
echo.
echo [PERFORMANCE - RIOT GAMES/VALVE BR]
ping 104.160.152.3 -n 15
echo ----------------------------------------------------------
) >> "%FILE%"

:: 5. ANALISE DE CAMADA 7 (WEB RESPONSE)
echo [5/7] Medindo tempo de resposta HTTP/DNS...
(
echo [RESPOSTA DE APLICACAO WEB]
powershell -Command "$urls = @('http://google.com', 'http://cloudflaredns.com'); foreach($url in $urls){ $t = (Measure-Command { iwr -Uri $url -Method Head -TimeoutSec 5 }).TotalMilliseconds; echo \"$url : $t ms\" }"
echo.
echo [DNS RESOLUTION]
nslookup google.com
echo ----------------------------------------------------------
) >> "%FILE%"

:: 6. RASTREIO E MTU (FRAGMENTACAO)
echo [6/7] Verificando Rota e Fragmentacao (MTU)...
(
echo [TRACEROUTE CORPORATIVO]
tracert -d -h 20 8.8.8.8
echo.
echo [TESTE DE FRAGMENTACAO MTU - PADRAO 1500]
ping 8.8.8.8 -f -l 1472 -n 1
if !errorlevel! equ 0 (echo MTU 1500 OK) else (echo Possivel necessidade de ajuste de MTU)
echo ----------------------------------------------------------
) >> "%FILE%"

:: 7. FINALIZACAO
echo [7/7] Gerando sumario final...
(
echo.
echo ==========================================================
echo              FIM DO RELATORIO - NOC ENTERPRISE
echo ==========================================================
) >> "%FILE%"

echo.
echo ==========================================================
echo   DIAGNOSTICO CONCLUIDO!
echo   Arquivo gerado na pasta atual: 
echo   %FILE%
echo ==========================================================
echo   Pressione qualquer tecla para encerrar...
pause >nul

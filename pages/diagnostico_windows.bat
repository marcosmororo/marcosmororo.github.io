@echo off
setlocal enabledelayedexpansion
title NOC ENTERPRISE DIAGNOSTIC v2.1
mode con: cols=100 lines=35
color 0b

:: Configurações de arquivo (Gera um nome limpo sem espaços)
set "MYDATE=%date:~-4%%date:~3,2%%date:~0,2%"
set "MYTIME=%time:~0,2%%time:~3,2%"
set "MYTIME=%MYTIME: =0%"
set "FILE=NOC_Report_%COMPUTERNAME%_%MYDATE%_%MYTIME%.txt"

echo ==========================================================
echo       SISTEMA DE DIAGNOSTICO CORPORATIVO - NOC PRO
echo ==========================================================
echo   Status: Iniciando coleta de metricas...
echo   Arquivo: %FILE%
echo ==========================================================

:: Criando o cabeçalho do arquivo
echo ========================================================== > "%FILE%"
echo              RELATORIO TECNICO DE CONECTIVIDADE          >> "%FILE%"
echo ========================================================== >> "%FILE%"
echo GERADO EM: %date% as %time% >> "%FILE%"
echo USUARIO: %USERNAME% >> "%FILE%"
echo HOSTNAME: %COMPUTERNAME% >> "%FILE%"
echo OS: %PROCESSOR_ARCHITECTURE% >> "%FILE%"
echo ========================================================== >> "%FILE%"
echo. >> "%FILE%"

:: 1. HARDWARE E INTERFACE
echo [1/7] Coletando informacoes de Hardware...
echo [INFORMACOES DE ADAPTADOR] >> "%FILE%"
wmic nic where "netenabled=true" get name, speed, AdapterType /value >> "%FILE%" 2>nul
echo ---------------------------------------------------------- >> "%FILE%"

:: 2. ENDERECAMENTO (L2/L3)
echo [2/7] Mapeando topologia IP...
echo [CAMADA 3 - ENDERECAMENTO PUBLICO] >> "%FILE%"
for /f "delims=" %%a in ('curl -s -4 https://ifconfig.me') do echo IPv4 WAN: %%a >> "%FILE%"
for /f "delims=" %%a in ('curl -s -6 https://ifconfig.me') do echo IPv6 WAN: %%a >> "%FILE%"
echo. >> "%FILE%"
echo [CONFIGURACAO IP LOCAL] >> "%FILE%"
ipconfig /all >> "%FILE%"
echo ---------------------------------------------------------- >> "%FILE%"

:: 3. GATEWAY E LAN STABILITY
echo [3/7] Testando estabilidade do Roteador (LAN)...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set "tempGW=%%a"
    set "GW=!tempGW: =!"
)
echo [LAN STABILITY TEST] >> "%FILE%"
if defined GW (
    echo Testando Gateway: !GW! >> "%FILE%"
    ping !GW! -n 10 >> "%FILE%"
) else (
    echo ERRO: Gateway nao detectado >> "%FILE%"
)
echo ---------------------------------------------------------- >> "%FILE%"

:: 4. PERFORMANCE (JITTER/LOSS)
echo [4/7] Analisando Jitter e Perda (Games/Streaming)...
echo [PERFORMANCE - GOOGLE ^& RIOT] >> "%FILE%"
ping 8.8.8.8 -n 15 >> "%FILE%"
ping 104.160.152.3 -n 15 >> "%FILE%"
echo ---------------------------------------------------------- >> "%FILE%"

:: 5. ANALISE WEB
echo [5/7] Medindo tempo de resposta HTTP...
echo [RESPOSTA DE APLICACAO WEB] >> "%FILE%"
powershell -Command "try { $t = (Measure-Command { iwr -Uri http://google.com -Method Head -TimeoutSec 5 }).TotalMilliseconds; echo \"Google.com : $t ms\" } catch { echo \"Google.com : Erro na conexao\" }" >> "%FILE%"
echo. >> "%FILE%"
nslookup google.com >> "%FILE%"
echo ---------------------------------------------------------- >> "%FILE%"

:: 6. ROTA E MTU
echo [6/7] Verificando Rota e Fragmentacao (MTU)...
echo [TRACEROUTE CORPORATIVO] >> "%FILE%"
tracert -d -h 15 8.8.8.8 >> "%FILE%"
echo. >> "%FILE%"
echo [TESTE DE FRAGMENTACAO MTU] >> "%FILE%"
ping 8.8.8.8 -f -l 1472 -n 1 >> "%FILE%" 2>nul
if !errorlevel! equ 0 (echo MTU 1500 OK >> "%FILE%") else (echo Sugestao: Verificar MTU da rede >> "%FILE%")
echo ---------------------------------------------------------- >> "%FILE%"

echo [7/7] Finalizando...
echo. >> "%FILE%"
echo ========================================================== >> "%FILE%"
echo              FIM DO RELATORIO - NOC ENTERPRISE           >> "%FILE%"
echo ========================================================== >> "%FILE%"

echo.
echo ==========================================================
echo   DIAGNOSTICO CONCLUIDO! Arquivo: %FILE%
echo ==========================================================
pause

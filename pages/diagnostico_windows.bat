@echo off
setlocal enabledelayedexpansion
title Diagnostico NOC Pro
mode con: cols=90 lines=30
color 0b

:: Nome do arquivo dinâmico
set "FILE=diag_%COMPUTERNAME%.txt"

echo ===================================================
echo    FERRAMENTA DE DIAGNOSTICO NOC - PRO
echo ===================================================
echo Iniciando testes... Este processo leva cerca de 1 minuto.

(
echo ===================================================
echo          RELATORIO TECNICO DE CONECTIVIDADE
echo ===================================================
echo DATA/HORA: %date% %time%
echo DISPOSITIVO: %COMPUTERNAME%
echo ===================================================
echo.
) > "%FILE%"

:: 1. IDENTIFICAÇÃO DE IP (WAN/INTERNET)
echo [1/6] Identificando IPs Publicos (v4 e v6)...
(
echo [1. ENDERECOS IP PUBLICOS]
echo IPv4: 
) >> "%FILE%"
curl -s -4 https://ifconfig.me >> "%FILE%" || echo Nao detectado >> "%FILE%"
echo. >> "%FILE%"
echo IPv6: >> "%FILE%"
curl -s -6 https://ifconfig.me >> "%FILE%" || echo Nao detectado >> "%FILE%"
echo. >> "%FILE%"

:: 2. TESTE DE REDE LOCAL (WI-FI VS CABO)
echo [2/6] Verificando estabilidade do Roteador...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set "tempGW=%%a"
    set "GW=!tempGW: =!"
)
(
echo [2. ESTABILIDADE DA REDE LOCAL]
if defined GW (
    echo Gateway Detectado: !GW!
    echo (Dica: Pings acima de 10ms indicam problema no Wi-Fi ou Cabo)
    ping !GW! -n 10
) else (
    echo ERRO: Gateway nao detectado.
)
echo.
) >> "%FILE%"

:: 3. ANALISE DE DNS (RESOLUÇÃO DE NOMES)
echo [3/6] Testando tempo de resposta do DNS...
(
echo [3. TESTE DE DNS]
nslookup google.com
echo.
) >> "%FILE%"

:: 4. LATÊNCIA E JITTER (ESTABILIDADE)
echo [4/6] Testando latencia e Jitter (15 disparos)...
(
echo [4. LATENCIA E JITTER - GOOGLE DNS]
echo (Dica: Variacao alta entre os tempos indica Jitter/Instabilidade)
ping 8.8.8.8 -n 15
echo.
) >> "%FILE%"

:: 5. RASTREIO DE ROTA (TRACEROUTE)
echo [5/6] Rastreando rota de saida...
(
echo [5. RASTREIO DE SALTOS - TRACERT]
tracert -d -h 15 8.8.8.8
echo.
) >> "%FILE%"

:: 6. TESTE DE MTU (FRAGMENTAÇÃO DE PACOTE)
echo [6/6] Verificando integridade de pacotes (MTU)...
(
echo [6. TESTE DE FRAGMENTACAO MTU]
echo (Dica: Se falhar, pacotes grandes estao sendo bloqueados)
ping 8.8.8.8 -f -l 1472 -n 1
if !errorlevel! equ 0 (echo MTU 1500: OK) else (echo MTU 1500: FALHA/FRAGMENTADO)
echo.
) >> "%FILE%"

(
echo ===================================================
echo            FIM DO DIAGNOSTICO - NOC
echo ===================================================
) >> "%FILE%"

echo ===================================================
echo TESTE CONCLUIDO COM SUCESSO!
echo Arquivo gerado: %FILE%
echo Envie este arquivo para o tecnico responsavel.
echo ===================================================
pause

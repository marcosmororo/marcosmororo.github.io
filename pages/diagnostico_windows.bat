@echo off
setlocal enabledelayedexpansion
title Diagnostico NOC PRO + Games
mode con: cols=90 lines=30
color 0b

set FILE=resultado_diagnostico_win.txt

echo ===================================================
echo    DIAGNOSTICO DE REDE NOC PRO (GAMES ^& ROUTER)
echo ===================================================

echo Gerando relatorio completo... aguarde.
echo ======================================== > "%FILE%"
echo RELATORIO DE REDE - WINDOWS >> "%FILE%"
echo Data/Hora: %date% %time% >> "%FILE%"
echo ======================================== >> "%FILE%"

echo 1. VERIFICANDO IPS PUBLICOS...
echo [IPS PUBLICOS] >> "%FILE%"
:: Captura IPv4
for /f "delims=" %%a in ('curl -s -4 https://ifconfig.me') do set IPV4=%%a
:: Captura IPv6
for /f "delims=" %%a in ('curl -s -6 https://ifconfig.me') do set IPV6=%%a

if not defined IPV4 set IPV4=Nao detectado
if not defined IPV6 set IPV6=Nao detectado ou sem suporte

echo IPv4: %IPV4%
echo IPv4: %IPV4% >> "%FILE%"
echo IPv6: %IPV6%
echo IPv6: %IPV6% >> "%FILE%"

echo. >> "%FILE%"
echo 2. IDENTIFICANDO ROTEADOR E TESTANDO REDE LOCAL...
:: Metodo mais robusto para pegar o Gateway (via IPCONFIG)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Gateway Padrão Default.Gateway"') do (
    set tempGW=%%a
    set GW=!tempGW: =!
)

if not defined GW (
    echo [!] Erro: Gateway nao encontrado. Verifique sua conexao.
    echo [ERRO] Gateway nao detectado >> "%FILE%"
) else (
    echo Gateway detectado: !GW!
    echo [TESTE ROTEADOR LOCAL - !GW!] >> "%FILE%"
    ping !GW! -n 5 >> "%FILE%"
)

echo. >> "%FILE%"
echo 3. TESTE DE ESTABILIDADE PARA JOGOS...
echo [PING GAMES - GOOGLE ^& RIOT BR] >> "%FILE%"
echo Testando Google DNS...
ping 8.8.8.8 -n 10 >> "%FILE%"
echo Testando Riot Games (BR)...
ping 104.160.152.3 -n 10 >> "%FILE%"

echo 4. VERIFICANDO DNS...
echo [NSLOOKUP] >> "%FILE%"
nslookup google.com >> "%FILE%"

echo 5. RASTREANDO ROTA...
echo [TRACEROUTE] >> "%FILE%"
tracert -d -h 15 8.8.8.8 >> "%FILE%"

echo 6. TEMPO DE RESPOSTA HTTP...
echo [HTTP RESPONSE TIME] >> "%FILE%"
powershell -Command "$t = Measure-Command { iwr -Uri http://www.google.com -Method Head -TimeoutSec 5 }; $t.TotalMilliseconds" >> "%FILE%"
echo ms >> "%FILE%"

echo ======================================== >> "%FILE%"
echo FIM DO DIAGNOSTICO >> "%FILE%"

echo.
echo ===================================================
echo CONCLUIDO! Arquivo gerado: %FILE%
echo Envie este arquivo para o suporte tecnico.
echo ===================================================
pause

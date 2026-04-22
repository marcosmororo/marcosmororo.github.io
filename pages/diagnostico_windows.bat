@echo off
title Diagnostico NOC PRO + Games - Windows
mode con: cols=90 lines=30
color 0b

set FILE=resultado_diagnostico_win.txt

echo ===================================================
echo    DIAGNOSTICO DE REDE NOC PRO (GAMES & ROUTER)
echo ===================================================

echo Gerando relatorio completo... aguarde.
echo ======================================== > %FILE%
echo RELATORIO DE REDE - WINDOWS >> %FILE%
echo Data/Hora: %date% %time% >> %FILE%
echo ======================================== >> %FILE%

echo 1. VERIFICANDO IPS PUBLICOS...
echo [IPS PUBLICOS] >> %FILE%
for /f "delims=" %%a in ('curl -s -4 https://ifconfig.me') do set IPV4=%%a
for /f "delims=" %%a in ('curl -s -6 https://ifconfig.me') do set IPV6=%%a
echo IPv4: %IPV4% | echo IPv4: %IPV4% >> %FILE%
echo IPv6: %IPV6% | echo IPv6: %IPV6% >> %FILE%

echo 2. IDENTIFICANDO ROTEADOR E TESTANDO REDE LOCAL...
:: Pega o Gateway Padrão via WMIC
for /f "tokens=2 delims==" %%a in ('wmic nicconfig where "DefaultIPGateway is not null" get DefaultIPGateway /value ^| findstr "{"') do set GATEWAY=%%a
set GATEWAY=%GATEWAY:{"=%
set GATEWAY=%GATEWAY:"}=%
set GATEWAY=%GATEWAY:,= %
for /f "tokens=1" %%g in ("%GATEWAY%") do set GW=%%g

echo Gateway detectado: %GW%
echo [TESTE ROTEADOR LOCAL - %GW%] >> %FILE%
ping %GW% -n 5 >> %FILE%

echo 3. TESTE DE ESTABILIDADE PARA JOGOS (STRESS TEST)...
echo [PING GAMES - VALVE/RIOT/GOOGLE] >> %FILE%
echo -- Google DNS (Referencia) -- >> %FILE%
ping 8.8.8.8 -n 10 >> %FILE%
echo -- Servidor de Jogo (Exemplo Riot/Valve) -- >> %FILE%
ping 104.160.152.3 -n 10 >> %FILE%

echo 4. VERIFICANDO DNS...
echo [NSLOOKUP] >> %FILE%
nslookup google.com >> %FILE%

echo 5. RASTREANDO ROTA (TRACEROUTE)...
echo [TRACEROUTE] >> %FILE%
tracert -d -h 15 8.8.8.8 >> %FILE%

echo 6. TEMPO DE RESPOSTA HTTP (ABERTURA DE SITE)...
echo [HTTP RESPONSE TIME] >> %FILE%
powershell -Command "$t = Measure-Command { iwr -Uri http://www.google.com -Method Head -TimeoutSec 5 }; $t.TotalMilliseconds" >> %FILE%
echo ms >> %FILE%

echo ======================================== >> %FILE%
echo FIM DO DIAGNOSTICO >> %FILE%

echo.
echo ===================================================
echo CONCLUIDO! Arquivo: %FILE%
echo Analise o PING LOCAL para ver se o Wi-Fi esta ruim.
echo ===================================================
pause

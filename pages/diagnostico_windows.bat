@echo off
title Diagnostico NOC PRO - Windows
mode con: cols=80 lines=25
color 0b

set FILE=resultado_diagnostico_win.txt

echo ===================================================
echo    DIAGNOSTICO DE REDE NOC - INICIANDO...
echo ===================================================

echo Gerando relatorio... aguarde.
echo ======================================== > %FILE%
echo RELATORIO DE REDE - WINDOWS >> %FILE%
echo Data/Hora: %date% %time% >> %FILE%
echo ======================================== >> %FILE%

echo 1. VERIFICANDO IPS PUBLICOS...
echo [IPS PUBLICOS] >> %FILE%

:: Captura IPv4
for /f "delims=" %%a in ('curl -s -4 https://ifconfig.me') do set IPV4=%%a
echo IPv4: %IPV4%
echo IPv4 Publico: %IPV4% >> %FILE%

:: Captura IPv6 (Se houver suporte na rede)
for /f "delims=" %%a in ('curl -s -6 https://ifconfig.me') do set IPV6=%%a
if "%IPV6%"=="" set IPV6=Nao detectado ou sem suporte
echo IPv6: %IPV6%
echo IPv6 Publico: %IPV6% >> %FILE%

echo. >> %FILE%
echo 2. TESTANDO LATENCIA (Google)...
echo [PING 8.8.8.8] >> %FILE%
ping 8.8.8.8 -n 5 >> %FILE%

echo 3. TESTANDO DNS...
echo [NSLOOKUP] >> %FILE%
nslookup google.com >> %FILE%

echo 4. RASTREANDO ROTA (Pode demorar)...
echo [TRACEROUTE] >> %FILE%
tracert -d -h 15 8.8.8.8 >> %FILE%

echo 5. VELOCIDADE DE ABERTURA HTTP...
echo [HTTP RESPONSE TIME] >> %FILE%
powershell -Command "$t = Measure-Command { iwr -Uri http://www.google.com -Method Head }; $t.TotalMilliseconds" >> %FILE%
echo ms >> %FILE%

echo ======================================== >> %FILE%
echo FIM DO DIAGNÓSTICO >> %FILE%

echo.
echo ===================================================
echo CONCLUIDO! Arquivo: %FILE%
echo ===================================================
pause

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

echo 1. VERIFICANDO IP PUBLICO...
echo [IP PUBLICO] >> %FILE%
for /f "delims=" %%a in ('curl -s https://ifconfig.me') do set IP=%%a
echo Seu IP Publico e: %IP%
echo IP Publico: %IP% >> %FILE%

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
echo FIM DO DIAGNOSTICO >> %FILE%

echo.
echo ===================================================
echo CONCLUIDO!
echo Arquivo gerado: %FILE%
echo Envie este arquivo para o suporte.
echo ===================================================
pause

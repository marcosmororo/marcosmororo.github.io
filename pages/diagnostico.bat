@echo off
title Diagnostico NOC PRO - Windows
color 0b
set FILE=resultado_diagnostico.txt

echo ======================================== > %FILE%
echo RELATORIO DE REDE - WINDOWS >> %FILE%
echo Data/Hora: %date% %time% >> %FILE%
echo ======================================== >> %FILE%

echo Executando Ping (Google DNS)...
echo [PING 8.8.8.8] >> %FILE%
ping 8.8.8.8 -n 5 >> %FILE%

echo Executando DNS Lookup...
echo [NSLOOKUP] >> %FILE%
nslookup google.com >> %FILE%

echo Executando Rota (Traceroute)...
echo [TRACEROUTE] >> %FILE%
tracert -d -h 15 8.8.8.8 >> %FILE%

echo Testando Tempo de Abertura (Web)...
echo [CURL HTTP] >> %FILE%
powershell -Command "(Measure-Command {Invoke-WebRequest -Uri 'http://google.com' -Method Head}).TotalMilliseconds" >> %FILE%
echo ms >> %FILE%

echo.
echo ========================================
echo TESTE CONCLUIDO!
echo O arquivo 'resultado_diagnostico.txt' foi gerado.
echo Envie este arquivo para o suporte tecnico.
echo ========================================
pause

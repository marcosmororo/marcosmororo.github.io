#!/bin/bash
FILE="resultado_diagnostico.txt"

echo "========================================" > $FILE
echo "RELATORIO DE REDE - LINUX/MAC" >> $FILE
echo "Data/Hora: $(date)" >> $FILE
echo "========================================" >> $FILE

echo "Executando Ping..."
echo "[PING]" >> $FILE
ping -c 5 8.8.8.8 >> $FILE

echo "Executando DNS Lookup..."
echo "[NSLOOKUP]" >> $FILE
nslookup google.com >> $FILE

echo "Executando Rota (Traceroute)..."
echo "[TRACEROUTE]" >> $FILE
if command -v traceroute &> /dev/null; then
    traceroute -m 15 8.8.8.8 >> $FILE
else
    mtr -rw c 1 8.8.8.8 >> $FILE
fi

echo "Testando Tempo de Abertura (Web)..."
echo "[TIME CURL]" >> $FILE
curl -o /dev/null -s -w "%{time_total}s\n"  http://www.google.com >> $FILE

echo "========================================"
echo "TESTE CONCLUIDO!"
echo "Envie o arquivo 'resultado_diagnostico.txt' para o suporte."

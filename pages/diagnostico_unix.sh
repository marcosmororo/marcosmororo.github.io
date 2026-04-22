#!/bin/bash

# Garante que o script rode na pasta onde ele está salvo
cd "$(dirname "$0")"

FILE="resultado_diagnostico_mac.txt"

# Limpa a tela do terminal do usuário
clear
echo "==================================================="
echo "    DIAGNOSTICO DE REDE NOC - macOS"
echo "==================================================="

echo "Gerando relatório... Isso pode levar 1 minuto."

echo "========================================" > "$FILE"
echo "RELATÓRIO DE REDE - macOS" >> "$FILE"
echo "Data/Hora: $(date)" >> "$FILE"
echo "========================================" >> "$FILE"

echo "1. VERIFICANDO IP PÚBLICO..."
IP_PUB=$(curl -s https://ifconfig.me)
echo "[IP PÚBLICO]: $IP_PUB" >> "$FILE"
echo "Seu IP Público é: $IP_PUB"

echo "2. TESTANDO LATÊNCIA..."
echo "[PING 8.8.8.8]" >> "$FILE"
ping -c 5 8.8.8.8 >> "$FILE"

echo -e "\n3. TESTANDO DNS..." >> "$FILE"
echo "[NSLOOKUP]" >> "$FILE"
nslookup google.com >> "$FILE"

echo -e "\n4. RASTREANDO ROTA..."
echo "[TRACEROUTE]" >> "$FILE"
traceroute -m 15 -n 8.8.8.8 >> "$FILE"

echo -e "\n5. TEMPO DE RESPOSTA HTTP..."
echo "[CURL TIME]" >> "$FILE"
curl -o /dev/null -s -w "Tempo total: %{time_total}s\n" http://www.google.com >> "$FILE"

echo -e "\n========================================" >> "$FILE"
echo "FIM DO DIAGNÓSTICO" >> "$FILE"

echo ""
echo "==================================================="
echo "TESTE CONCLUÍDO!"
echo "Arquivo gerado: $FILE"
echo "Pode fechar esta janela e enviar o arquivo ao técnico."
echo "==================================================="

# Comando para manter aberto até o usuário ler
exec $SHELL

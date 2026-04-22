#!/bin/bash

# Define que o script rodará na pasta onde o arquivo está salvo
cd "$(dirname "$0")"

FILE="resultado_diagnostico_mac.txt"

echo "========================================" > "$FILE"
echo "RELATÓRIO DE REDE - macOS" >> "$FILE"
echo "Data/Hora: $(date)" >> "$FILE"
echo "Modelo: $(sysctl -n hw.model)" >> "$FILE"
echo "========================================" >> "$FILE"

echo "1. Testando Latência (Ping)..."
echo "[PING 8.8.8.8]" >> "$FILE"
ping -c 5 8.8.8.8 >> "$FILE"

echo -e "\n2. Testando Resolução DNS..." >> "$FILE"
echo "[NSLOOKUP google.com]" >> "$FILE"
nslookup google.com >> "$FILE"

echo -e "\n3. Rastreando Rota (Traceroute)..."
echo "[TRACEROUTE 8.8.8.8]" >> "$FILE"
# -m 15 limita a 15 saltos para ser mais rápido
traceroute -m 15 -n 8.8.8.8 >> "$FILE"

echo -e "\n4. Tempo de Abertura de Página (HTTP)..."
echo "[CURL - LATÊNCIA WEB]" >> "$FILE"
# Mede o tempo total para conectar e receber o primeiro byte
curl -o /dev/null -s -w "Tempo total: %{time_total}s\nConexão: %{time_connect}s\n" http://www.google.com >> "$FILE"

echo -e "\n========================================" >> "$FILE"
echo "FIM DO DIAGNÓSTICO" >> "$FILE"

echo "------------------------------------------------"
echo "TESTE CONCLUÍDO COM SUCESSO!"
echo "O arquivo '$FILE' foi criado na sua Mesa ou pasta atual."
echo "Envie este arquivo para o técnico responsável."
echo "------------------------------------------------"

# Mantém a janela aberta para o usuário ver que terminou
read -p "Pressione Enter para fechar esta janela..."

#!/bin/bash
cd "$(dirname "$0")"
FILE="resultado_diagnostico_mac.txt"

# Garante que a janela fique aberta
trap 'echo ""; echo "Pressione qualquer tecla para sair..."; read -n 1 -s' EXIT

clear
echo "==================================================="
echo "    DIAGNÓSTICO DE REDE NOC - macOS"
echo "==================================================="

echo "========================================" > "$FILE"
echo "RELATÓRIO DE REDE - macOS" >> "$FILE"
echo "Data/Hora: $(date)" >> "$FILE"
echo "========================================" >> "$FILE"

echo "1. VERIFICANDO IPS PÚBLICOS..."
IPV4=$(curl -s -4 https://ifconfig.me || echo "Nao detectado")
IPV6=$(curl -s -6 https://ifconfig.me || echo "Nao detectado ou sem suporte")

echo "IPv4: $IPV4"
echo "IPv6: $IPV6"

echo "[IPV4]: $IPV4" >> "$FILE"
echo "[IPV6]: $IPV6" >> "$FILE"

echo -e "\n2. TESTANDO LATÊNCIA..."
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

echo "==================================================="
echo "CONCLUÍDO! Arquivo: $FILE"
echo "==================================================="

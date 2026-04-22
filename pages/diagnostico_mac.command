#!/bin/bash

# 1. Tenta dar permissão de execução a si mesmo (caso o usuário tenha movido o arquivo)
chmod +x "$0" 2>/dev/null

# 2. Garante que o script rode no diretório onde o arquivo está salvo
cd "$(dirname "$0")"

FILE="resultado_diagnostico_mac.txt"

# Função para manter a janela aberta em caso de erro ou fim do script
finalizar() {
    echo ""
    echo "---------------------------------------------------"
    echo "Sessão finalizada."
    echo "Pressione qualquer tecla para fechar esta janela..."
    read -n 1 -s
    exit
}
trap finalizar EXIT

clear
echo "==================================================="
echo "    DIAGNÓSTICO DE REDE NOC - macOS"
echo "==================================================="
echo "Aguarde, os testes estão sendo executados..."
echo ""

# Início do Relatório
echo "========================================" > "$FILE"
echo "RELATÓRIO DE REDE - macOS" >> "$FILE"
echo "Data/Hora: $(date)" >> "$FILE"
echo "========================================" >> "$FILE"

echo "1. VERIFICANDO IP PÚBLICO..."
# Tenta pegar o IP de 3 fontes diferentes para garantir o resultado
IP_PUB=$(curl -s https://ifconfig.me || curl -s https://api.ipify.org || echo "Não foi possível obter o IP")
echo "Seu IP Público é: $IP_PUB"
echo "[IP PÚBLICO]: $IP_PUB" >> "$FILE"

echo "2. TESTANDO LATÊNCIA (PING)..."
echo "[PING 8.8.8.8]" >> "$FILE"
ping -c 5 8.8.8.8 >> "$FILE"
echo "Concluído..."

echo "3. TESTANDO RESOLUÇÃO DNS..."
echo "[NSLOOKUP google.com]" >> "$FILE"
nslookup google.com >> "$FILE"
echo "Concluído..."

echo "4. RASTREANDO ROTA (TRACEROUTE)..."
echo "[TRACEROUTE]" >> "$FILE"
# -m 15 (máximo 15 saltos) e -n (sem resolver nomes para ser mais rápido)
traceroute -m 15 -n 8.8.8.8 >> "$FILE"
echo "Concluído..."

echo "5. TESTE DE CONEXÃO WEB (HTTP)..."
echo "[CURL TIME]" >> "$FILE"
curl -o /dev/null -s -w "Tempo total de resposta: %{time_total}s\n" http://www.google.com >> "$FILE"
echo "Concluído..."

echo -e "\n========================================" >> "$FILE"
echo "FIM DO DIAGNÓSTICO" >> "$FILE"

echo ""
echo "==================================================="
echo "SUCESSO!"
echo "O arquivo '$FILE' foi gerado nesta pasta."
echo "Envie este arquivo para o suporte técnico."
echo "==================================================="

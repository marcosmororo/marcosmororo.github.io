do shell script "
cat << 'EOF' > /tmp/diag_noc.sh
#!/bin/bash
FILE=\"$HOME/Desktop/resultado_diagnostico_mac.txt\"
echo \"========================================\" > \"$FILE\"
echo \"RELATÓRIO DE REDE - macOS\" >> \"$FILE\"
echo \"Data/Hora: \$(date)\" >> \"$FILE\"
echo \"========================================\" >> \"$FILE\"

echo \"1. VERIFICANDO IPS PÚBLICOS...\"
echo \"[IPV4]: \$(curl -s -4 https://ifconfig.me || echo 'Falha')\" >> \"$FILE\"
echo \"[IPV6]: \$(curl -s -6 https://ifconfig.me || echo 'Sem suporte')\" >> \"$FILE\"

echo \"2. TESTANDO LATÊNCIA...\"
ping -c 5 8.8.8.8 >> \"$FILE\"

echo \"3. TESTANDO DNS...\"
nslookup google.com >> \"$FILE\"

echo \"4. RASTREANDO ROTA...\"
traceroute -m 15 -n 8.8.8.8 >> \"$FILE\"

echo \"5. TEMPO HTTP...\"
curl -o /dev/null -s -w \"%{time_total}s\" http://www.google.com >> \"$FILE\"
EOF

chmod +x /tmp/diag_noc.sh
/tmp/diag_noc.sh
" with administrator privileges

display dialog "Diagnóstico concluído com sucesso! O arquivo 'resultado_diagnostico_mac.txt' foi salvo na sua Mesa (Desktop)." buttons {"OK"} default button "OK" with icon note

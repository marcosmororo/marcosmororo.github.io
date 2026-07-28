from netmiko import ConnectHandler
import re
import getpass

# Dados da OLT
ip = input("IP da OLT: ")
usuario = input("Usuário: ")
senha = getpass.getpass("Senha: ")

olt = {
    "device_type": "nokia_sros",
    "host": ip,
    "username": usuario,
    "password": senha,
}

conexao = ConnectHandler(**olt)

print("Conectado na OLT...")

# Remove alarmes da saída
conexao.send_command_timing("environment inhibit-alarms")

# Busca ONUs DOWN
output = conexao.send_command_timing(
    "show equipment ont status pon | match exact:down"
)

conexao.disconnect()

onts = []

for linha in output.splitlines():
    if re.match(r"^\d+/\d+/\d+/\d+", linha):
        col = linha.split()
        onts.append(col[1])

# Gera arquivo TXT com comandos
with open("remover_onus.txt", "w") as arquivo:

    for ont in onts:
        arquivo.write(f"configure equipment ont interface {ont} admin-state down\n")
        arquivo.write("exit\n")
        arquivo.write(f"no interface {ont}\n")
        arquivo.write("exit all\n\n")

print("Total ONUs DOWN:", len(onts))
print("Arquivo criado: remover_onus.txt")

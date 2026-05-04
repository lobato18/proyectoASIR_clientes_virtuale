#!/bin/bash

# --- SELECCIÓN DE INTERFAZ DE RED ---
echo "--- DETECTANDO INTERFACES DISPONIBLES ---"
# Listamos las interfaces y las mostramos con un número
INTERFACES=($(ls /sys/class/net | grep -v lo))

echo "Interfaces encontradas:"
count=1
for i in "${INTERFACES[@]}"; do
    echo "$count) $i"
    ((count++))
done

echo ""
read -p "Escribe el NOMBRE de la interfaz que quieres usar (ej: br0): " IFACE_NAME

# Validamos que la interfaz existe y tiene IP
IP_SERV=$(ip -4 addr show "$IFACE_NAME" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

if [ -z "$IP_SERV" ]; then
    echo "❌ Error: La interfaz '$IFACE_NAME' no es válida o no tiene IP asignada."
    exit 1
fi

echo "✅ Interfaz seleccionada: $IFACE_NAME con IP: $IP_SERV"
sleep 1

# --- VARIABLES DEL DOMINIO ---
REALM="TECNOLOBATO.LOCAL"
DOMAIN="TECNOLOBATO"
ADMIN_PASS='TecnoLobato2026!'

echo "--- CONFIGURANDO CONTROLADOR DE DOMINIO (SAMBA AD DC) ---"
sleep 1

# 1. Identidad del sistema
hostnamectl set-hostname servidor
sed -i '/servidor/d' /etc/hosts
echo "$IP_SERV servidor.$REALM servidor" >> /etc/hosts

# 2. Instalación de paquetes
apt update
DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-config krb5-user smbclient

# 3. Limpieza
systemctl stop smbd nmbd winbind samba-ad-dc 2>/dev/null
[ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
rm -rf /var/lib/samba/private/*

# 4. Provisión del Dominio
samba-tool domain provision \
  --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL \
  --realm=$REALM --domain=$DOMAIN --adminpass="$ADMIN_PASS"

# 5. Configuración de Kerberos y Activación
ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc

# 6. Creación de Objetos (OU y Usuario)
echo "⏳ Esperando 10 segundos a que el AD DC levante..."
sleep 10
samba-tool ou create "OU=tecnolobato,DC=${DOMAIN,,},DC=local"
samba-tool user add "usuario_test" "$ADMIN_PASS" --userou="OU=tecnolobato"

echo "------------------------------------------------------------"
echo "🚀 ¡DOMINIO LISTO!"
echo "Interfaz: $IFACE_NAME | IP: $IP_SERV"
echo "Dominio: $REALM"
echo "------------------------------------------------------------"

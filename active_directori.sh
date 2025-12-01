#!/bin/bash
# -----------------------------------------------------------
# SCRIPT DE PROVISIONAMIENTO AUTOMÁTICO DE SAMBA AD DOMAIN CONTROLLER
# Autor: Gemini
# -----------------------------------------------------------

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Este script debe ejecutarse con sudo o como root."
  exit 1
fi

echo "======================================================="
echo "  🚀 CONFIGURACIÓN DE SAMBA ACTIVE DIRECTORY (AD DC)  "
echo "======================================================="

# --- 1. SOLICITAR PARÁMETROS ---

read -p "Ingrese el nombre de DOMINIO FQDN (ej: empresa.local): " DOMAIN_FQDN
if [ -z "$DOMAIN_FQDN" ]; then
    echo "❌ Error: El nombre de dominio no puede estar vacío."
    exit 1
fi

# Convertir a Realm (Mayúsculas)
REALM=$(echo "$DOMAIN_FQDN" | tr '[:lower:]' '[:upper:]')
DOMAIN_NAME=$(echo "$DOMAIN_FQDN" | cut -d'.' -f1)

# Solicitar la contraseña de administrador (se usa para la promoción y debe ser compleja)
read -s -p "Ingrese la CONTRASEÑA para el Administrador del Dominio: " ADMIN_PASS
echo
if [ -z "$ADMIN_PASS" ]; then
    echo "❌ Error: La contraseña no puede estar vacía."
    exit 1
fi

# --- 2. CONFIGURACIÓN PREVIA DEL SISTEMA ---

echo "--- 2.1 Actualizando e instalando paquetes necesarios..."
apt update
# Instalación sin preguntar (assume yes -y)
apt install -y samba krb5-user winbind chrony

# Configurar el Realm por defecto de Kerberos (para evitar diálogos interactivos)
echo "Configurando Kerberos por defecto..."
KERB_CONF="/etc/krb5.conf"
cat << EOF > "$KERB_CONF"
[libdefaults]
        default_realm = $REALM
        dns_lookup_realm = false
        dns_lookup_kdc = true
        
[realms]
        $REALM = {
                kdc = samba.local
                admin_server = samba.local
        }
        
[domain_realm]
        .$DOMAIN_FQDN = $REALM
        $DOMAIN_FQDN = $REALM
EOF

# --- 3. PROVISIÓN DEL DOMINIO ---

echo "--- 3.1 Limpiando configuración antigua de Samba..."
# Mover la configuración antigua para que Samba pueda crear la nueva
if [ -f "/etc/samba/smb.conf" ]; then
    mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
    echo "smb.conf existente renombrado a smb.conf.bak"
fi

echo "--- 3.2 Iniciando la promoción del Controlador de Dominio (provision)..."
# Usamos un archivo de comandos (expect) para inyectar la contraseña y respuestas automáticamente
# Parámetros: --use-rfc2307 (para integración Unix), --host-ip (IP del servidor)

# Obtener la IP del servidor (esto puede necesitar ajuste si tienes múltiples interfaces)
HOST_IP=$(hostname -I | awk '{print $1}')

if [ -z "$HOST_IP" ]; then
    echo "⚠️ ADVERTENCIA: No se pudo obtener la IP del host. Usando 127.0.0.1. Ajuste manualmente si es necesario."
    HOST_IP="127.0.0.1"
fi

# La tubería '|' inyecta las respuestas: REALM, DOMAIN_NAME, dc, SAMBA_INTERNAL, contraseña
(
    echo "$REALM" 
    echo "$DOMAIN_NAME" 
    echo "dc" 
    echo "SAMBA_INTERNAL" 
    echo "$ADMIN_PASS"
) | sudo samba-tool domain provision --use-rfc2307 --host-ip="$HOST_IP"

# --- 4. CONFIGURACIÓN POST-PROVISIÓN ---

echo "--- 4.1 Configurando DNS del sistema y moviendo archivos krb5.conf..."
# 4.1.1 Configurar el servidor DNS local para apuntar al nuevo DC
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "search $DOMAIN_FQDN" >> /etc/resolv.conf

# 4.1.2 Copiar el archivo krb5.conf generado por Samba
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# 4.1.3 Deshabilitar el servicio SMB tradicional (si existe) para evitar conflictos con samba-ad-dc
systemctl disable smbd nmbd winbind &> /dev/null

# --- 5. INICIO DE SERVICIOS ---

echo "--- 5.1 Iniciando el servicio Samba AD DC..."
# Desenmascarar, habilitar e iniciar el servicio
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc

if systemctl is-active --quiet samba-ad-dc; then
    echo "✅ Samba AD DC iniciado exitosamente."
else
    echo "❌ ERROR: Samba AD DC no pudo iniciar. Revisa los logs de systemctl status samba-ad-dc"
fi

# --- 6. VERIFICACIÓN FINAL ---

echo "--- 6.1 Verificación de estado del dominio ---"
# Debería mostrar el nivel de dominio y el rol (Domain Controller)
samba-tool domain level show

echo "--- 6.2 Verificación de DNS SRV Records (Búsqueda de LDAP) ---"
# Debería resolver la IP de tu servidor
host -t SRV _ldap._tcp.$DOMAIN_FQDN

echo ""
echo "========================================================"
echo "🎉 ¡PROCESO TERMINADO!"
echo "Tu servidor es ahora un Controlador de Dominio para: $DOMAIN_FQDN"
echo "Contraseña de Administrador: (La que ingresaste)"
echo "========================================================"

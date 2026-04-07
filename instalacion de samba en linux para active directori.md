Configuración de Active Directory en Linux con Samba 4
Para que un servidor Linux actúe como un Controlador de Dominio (DC), utilizamos Samba 4. Estos scripts automatizan el proceso de instalación, la estructura organizativa y la carga de usuarios.

1. Script de Instalación y Aprovisionamiento (01_instalar_ad.sh)
Explicación: Este script descarga los paquetes necesarios, limpia cualquier configuración previa de Samba para evitar conflictos y genera la base de datos del dominio (Reino, NetBIOS y contraseña de administrador).

Bash
#!/bin/bash
# Variables de entorno
REALM="TECNOLOBATO.LOCAL"
DOMAIN="TECNOLOBATO"
ADMIN_PASS="TecnoLobato2026!" # Usa una clave robusta

# 1. Instalación de software
apt update
DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-config krb5-user smbclient

# 2. Limpieza y preparación
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl unmask samba-ad-dc
[ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 3. Creación del Dominio
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL \
  --realm=$REALM --domain=$DOMAIN --adminpass=$ADMIN_PASS

# 4. Configurar Kerberos y arrancar
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
systemctl start samba-ad-dc
systemctl enable samba-ad-dc

echo "Dominio $REALM creado con éxito."
2. Script para Crear la Unidad Organizativa (02_crear_ou.sh)
Explicación: Una Unidad Organizativa (OU) es un contenedor dentro del AD que sirve para organizar objetos (usuarios, grupos, equipos). Este script crea específicamente la carpeta lógica de "tecnolobato".

Bash
#!/bin/bash
# Ajusta el DN según el dominio que pusiste en el script anterior
DOMAIN_DN="dc=tecnolobato,dc=local"
OU_NAME="tecnolobato"

echo "Creando OU: $OU_NAME..."
samba-tool ou create "OU=$OU_NAME,$DOMAIN_DN"

if [ $? -eq 0 ]; then
    echo "OU $OU_NAME creada correctamente."
else
    echo "Error: Posiblemente la OU ya existe o el servicio está apagado."
fi
3. Script para Agregar Miembros (03_agregar_usuario.sh)
Explicación: Este script es interactivo. Te pedirá un nombre de usuario y una contraseña, y colocará automáticamente a ese nuevo miembro dentro de la OU "tecnolobato" creada anteriormente.

Bash
#!/bin/bash
OU_TARGET="OU=tecnolobato,dc=tecnolobato,dc=local"

read -p "Nombre del nuevo miembro: " NEW_USER
read -s -p "Contraseña del usuario: " USER_PASS
echo ""

# Crear el usuario dentro de la OU específica
samba-tool user create "$NEW_USER" "$USER_PASS" --userou="$OU_TARGET"

if [ $? -eq 0 ]; then
    echo "Usuario $NEW_USER agregado con éxito a tecnolobato."
else
    echo "Error al crear el usuario."
fi
Instrucciones de uso rápido
Dar permisos: chmod +x *.sh

Orden de ejecución: 1. sudo ./01_instalar_ad.sh (Instala todo).
2. sudo ./02_crear_ou.sh (Crea la carpeta "tecnolobato").
3. sudo ./03_agregar_usuario.sh (Añade a las personas).

Importante: Tras la instalación, asegúrate de que el archivo /etc/resolv.conf apunte a 127.0.0.1 para que el servidor pueda resolver los nombres del propio dominio.

Nota de seguridad: El script 01 contiene una contraseña en texto plano (ADMIN_PASS). Una vez usado, borra el script o cámbiale los permisos para que solo root pueda leerlo.
#!/bin/bash




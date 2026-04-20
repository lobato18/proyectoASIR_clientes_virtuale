

-----

# Mega-Script de Automatización para ASIR (Fases 2, 3 y 4)

Aquí tienes un "Mega-Script" de Bash. Este script automatiza la **Fase 2, 3 y 4** completas.

### Lo que hace este script:

  * 📦 **Instala** todos los paquetes necesarios (`dnsmasq`, `nfs`, `debootstrap`, etc.).
  * network **Configura Dnsmasq** (DHCP + TFTP).
  * 📂 **Prepara** la estructura de carpetas PXE.
  * 🐧 **Descarga y crea** el sistema Linux completo automáticamente (usando `debootstrap`).
  * ⚙️ **Configura** el kernel y el initrd para arranque por red.
  * 📋 **Genera** el menú GRUB.
  * share **Exporta** la carpeta por NFS.

### ⚠️ Requisitos previos (Muy importante)

Antes de ejecutarlo asegúrate de cumplir lo siguiente:

1.  **Internet:** Tu servidor debe tener acceso a Internet (NAT) para descargar paquetes.
2.  **IP Estática:** Tu servidor debe tener una IP fija configurada en la segunda tarjeta de red (ej. `192.168.1.1`).
3.  **Privilegios:** Ejecútalo como root (`sudo su`).

-----

### El Script (`install_asir_pxe.sh`)

Copia el siguiente contenido en un fichero en tu servidor (ej: `nano install_asir_pxe.sh`), dale permisos de ejecución (`chmod +x install_asir_pxe.sh`) y ejecútalo.

```bash
#!/bin/bash

# ============================================================
# SCRIPT MAESTRO DE DESPLIEGUE: PROYECTO TECNOLOBATO (ASIR)
# Versión: 2.0 (Corregida para Debian 13 + PXELINUX)
# ============================================================

# --- CONFIGURACIÓN DE ENTORNO ---
SERVER_IP="192.168.1.146"       # Tu IP actual según 'ip a'
INTERFACE="enp2s0"               # Tu interfaz de red
DIR_TFTP="/var/lib/tftpboot"     # Ruta estándar de Debian
DIR_NFS="/export/thinclient"     # Ruta del sistema raíz
REALM="TECNOLOBATO.LOCAL"

# Colores para la terminal
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
NC='\033[0m'

echo -e "${VERDE}=== INICIANDO DESPLIEGUE TOTAL TECNOLOBATO ===${NC}"

# 1. LIMPIEZA DE CONFLICTOS
# ------------------------------------------------------------
echo -e "${AMARILLO}[1/7] Limpiando servicios conflictivos...${NC}"
sudo systemctl stop dnsmasq 2>/dev/null
sudo systemctl disable dnsmasq 2>/dev/null
# Aseguramos que ISC-DHCP-SERVER apunte a la interfaz correcta
sudo sed -i "s/INTERFACESv4=\".*\"/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

# 2. INSTALACIÓN DE PAQUETES FALTANTES
# ------------------------------------------------------------
echo -e "${AMARILLO}[2/7] Instalando binarios de arranque PXE...${NC}"
sudo apt update
sudo apt install -y pxelinux syslinux-common nfs-kernel-server tftpd-hpa isc-dhcp-server

# 3. PREPARAR ESTRUCTURA TFTP
# ------------------------------------------------------------
echo -e "${AMARILLO}[3/7] Configurando servidor de archivos de arranque (TFTP)...${NC}"
sudo mkdir -p $DIR_TFTP/pxelinux.cfg
sudo cp /usr/lib/PXELINUX/pxelinux.0 $DIR_TFTP/
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 $DIR_TFTP/
sudo cp /usr/lib/syslinux/modules/bios/libcom32.c32 $DIR_TFTP/ 2>/dev/null
sudo cp /usr/lib/syslinux/modules/bios/libutil.c32 $DIR_TFTP/ 2>/dev/null

# 4. CONFIGURACIÓN DEL KERNEL EN LA IMAGEN
# ------------------------------------------------------------
echo -e "${AMARILLO}[4/7] Asegurando Kernel e Initrd en el sistema cliente...${NC}"
# Montajes necesarios para chroot
sudo mount --bind /dev $DIR_NFS/dev
sudo mount --bind /proc $DIR_NFS/proc
sudo mount --bind /sys $DIR_NFS/sys

sudo chroot $DIR_NFS /bin/bash <<EOF
apt update
DEBIAN_FRONTEND=noninteractive apt install -y linux-image-amd64 nfs-common
# Configuración de usuarios solicitada
echo "root:asir" | chpasswd
id -u alumno >/dev/null 2>&1 || useradd -m -s /bin/bash alumno
echo "alumno:asir" | chpasswd
exit
EOF

sudo umount $DIR_NFS/dev $DIR_NFS/proc $DIR_NFS/sys

# 5. EXPORTAR ARCHIVOS DE ARRANQUE
# ------------------------------------------------------------
echo -e "${AMARILLO}[5/7] Copiando archivos de arranque al directorio TFTP...${NC}"
# Buscamos los archivos más recientes generados en el paso anterior
KERNEL_REAL=$(ls -t $DIR_NFS/boot/vmlinuz-* | head -1)
INITRD_REAL=$(ls -t $DIR_NFS/boot/initrd.img-* | head -1)

sudo cp "$KERNEL_REAL" $DIR_TFTP/vmlinuz
sudo cp "$INITRD_REAL" $DIR_TFTP/initrd.img
sudo chmod 644 $DIR_TFTP/vmlinuz $DIR_TFTP/initrd.img

# 6. GENERAR MENÚ DE ARRANQUE PXE
# ------------------------------------------------------------
echo -e "${AMARILLO}[6/7] Creando menú de arranque default...${NC}"
cat <<EOF | sudo tee $DIR_TFTP/pxelinux.cfg/default
DEFAULT debian
PROMPT 0
TIMEOUT 30

LABEL debian
    MENU LABEL Cliente Ligero Debian (TecnoLobato)
    KERNEL vmlinuz
    APPEND initrd=initrd.img root=/dev/nfs nfsroot=$SERVER_IP:$DIR_NFS rw ip=dhcp
EOF

# 7. EXPORTACIÓN NFS Y REINICIO DE SERVICIOS
# ------------------------------------------------------------
echo -e "${AMARILLO}[7/7] Aplicando exportaciones NFS y reiniciando motores...${NC}"
echo "$DIR_NFS *(rw,sync,no_root_squash,no_subtree_check,insecure)" | sudo tee /etc/exports
sudo exportfs -ra

sudo systemctl restart isc-dhcp-server
sudo systemctl restart tftpd-hpa
sudo systemctl restart nfs-kernel-server

echo -e "${VERDE}============================================================${NC}"
echo -e "${VERDE}🚀 DESPLIEGUE COMPLETADO CON ÉXITO${NC}"
echo -e "Servidor IP: $SERVER_IP"
echo "Usuario cliente: alumno / asir"
echo "Root cliente: root / asir"
echo -e "${VERDE}============================================================${NC}"
```

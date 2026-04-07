# 🐧 Creación de la Imagen Base Linux (Root Filesystem NFS)

Este documento describe el proceso para generar el sistema de archivos raíz (`root filesystem`) mínimo que tu Thin Client cargará desde el servidor mediante **NFS (Network File System)**.

Se utiliza la herramienta **`debootstrap`**, la forma estándar de crear una instalación limpia de Debian/Ubuntu.

## ⚙️ Requisitos y Preparación

Asegúrate de ejecutar estos comandos en tu **Servidor PXE/NFS**.

### 1. Instalación de Herramientas

Necesitas `debootstrap` para crear el sistema base y `qemu-user-static` si tu servidor tiene una arquitectura diferente a la del cliente (aunque generalmente el thin client será x86 o ARM, igual que el servidor).

```bash
#!/bin/bash

# --- 1. Instalación de Herramientas en el Servidor ---
sudo apt update
sudo apt install -y debootstrap qemu-user-static nfs-common

# --- 2. Definir Variables y Directorios ---
EXPORT_DIR="/export/thinclient"
DISTRO="buster"

# Asegurar que el directorio esté limpio
sudo rm -rf $EXPORT_DIR
sudo mkdir -p $EXPORT_DIR

# --- 3. Generar el Sistema Base ---
echo "Iniciando debootstrap en $EXPORT_DIR..."
# Corregida la URL (sin corchetes de Markdown)
sudo debootstrap --arch=amd64 $DISTRO $EXPORT_DIR http://deb.debian.org/debian/

# --- 4. Montar Sistemas de Archivos Virtuales ---
echo "Montando sistemas de archivos virtuales..."
sudo mount --bind /proc $EXPORT_DIR/proc
sudo mount --bind /sys $EXPORT_DIR/sys
sudo mount --bind /dev $EXPORT_DIR/dev

# --- 5. Configuración Interna (vía Chroot) ---
echo "Entrando al entorno chroot para configuración..."

sudo chroot $EXPORT_DIR /bin/bash <<EOF
# Actualizar repositorios internos
apt update

# Instalar herramientas básicas (corregido nfs-common)
apt install -y net-tools iproute2 dhcpcd5 ssh locales vim nfs-common linux-image-amd64

# Configurar Hostname
echo "thinclient-pxe" > /etc/hostname

# Instalar entorno gráfico mínimo y RDP
apt install -y xorg openbox xserver-xorg-input-all freerdp2-x11

# Limpieza de caché para reducir tamaño de imagen
apt clean
exit
EOF

# --- 6. Desmontar y Finalizar ---
echo "Limpiando y desmontando..."
sudo umount $EXPORT_DIR/proc
sudo umount $EXPORT_DIR/sys
sudo umount $EXPORT_DIR/dev

echo "✅ Imagen Base Lista en $EXPORT_DIR"

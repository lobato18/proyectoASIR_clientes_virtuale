#!/bin/bash

ISO_PATH=$1
OS_NAME=$2

if [ -z "$ISO_PATH" ] || [ -z "$OS_NAME" ]; then
    echo "Uso: sudo ./import_iso.sh /ruta/a/la.iso nombre_os"
    exit 1
fi

# 1. Crear directorios
MOUNT_POINT="/mnt/iso_tmp"
TARGET_DIR="/var/lib/tftpboot/$OS_NAME"
sudo mkdir -p $MOUNT_POINT $TARGET_DIR

# 2. Montar ISO (solo lectura)
sudo mount -o loop "$ISO_PATH" $MOUNT_POINT

# 3. Buscar y extraer Kernel e Initrd (nombres comunes)
echo "Extrayendo archivos de arranque..."
sudo cp $(find $MOUNT_POINT -name vmlinuz* | head -n 1) $TARGET_DIR/vmlinuz
sudo cp $(find $MOUNT_POINT -name initrd* | head -n 1) $TARGET_DIR/initrd

# 4. Añadir entrada al menú de PXE
MENU_FILE="/var/lib/tftpboot/pxelinux.cfg/default"

# Si el archivo no existe, creamos la cabecera básica
if [ ! -f "$MENU_FILE" ]; then
    sudo bash -c "cat <<EOF > $MENU_FILE
DEFAULT menu.c32
PROMPT 0
TIMEOUT 300
ONTIMEOUT local

MENU TITLE --- Menu de Instalacion PXE ---
EOF"
fi

# Añadir la nueva opción al menú
sudo bash -c "cat <<EOF >> $MENU_FILE

LABEL $OS_NAME
    MENU LABEL Instalar $OS_NAME
    KERNEL $OS_NAME/vmlinuz
    APPEND initrd=$OS_NAME/initrd boot=casper netboot=nfs nfsroot=192.168.1.10:/srv/pxe/isos/$OS_NAME
EOF"

# 5. Limpieza
sudo umount $MOUNT_POINT
echo "¡Hecho! $OS_NAME ha sido añadido al servidor PXE."

#!/bin/bash

# ==========================================
# CONFIGURACIÓN INICIAL (EDITA ESTO SI ES NECESARIO)
# ==========================================
RED_INTERNA_IF="enp0s8"        # Nombre de tu interfaz de red interna (haz 'ip a' para verla)
SERVER_IP="192.168.1.1"        # La IP fija de tu servidor
RANGO_DHCP="192.168.1.50,192.168.1.100,12h"
DIR_TFTP="/srv/tftp"
DIR_NFS="/srv/nfs/cliente_linux"

# Colores para mensajes
VERDE='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${VERDE}=== INICIANDO INSTALACIÓN PROYECTO ASIR PXE ===${NC}"

# 1. INSTALACIÓN DE PAQUETES
echo -e "${VERDE}[1/7] Instalando paquetes necesarios...${NC}"
apt update
apt install -y dnsmasq nfs-kernel-server debootstrap qemu-user-static grub-efi-amd64-signed shim-signed samba

# 2. CONFIGURACIÓN DNSMASQ (DHCP + TFTP)
echo -e "${VERDE}[2/7] Configurando Dnsmasq...${NC}"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
cat <<EOF > /etc/dnsmasq.conf
interface=$RED_INTERNA_IF
dhcp-range=$RANGO_DHCP
enable-tftp
tftp-root=$DIR_TFTP
dhcp-boot=bootx64.efi
log-dhcp
EOF

# 3. PREPARAR ESTRUCTURA TFTP Y GRUB
echo -e "${VERDE}[3/7] Preparando ficheros de arranque UEFI...${NC}"
mkdir -p $DIR_TFTP/grub/fonts
# Copiamos el bootloader firmado
cp /usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed $DIR_TFTP/bootx64.efi
# Copiamos la fuente
cp /usr/share/grub/unicode.pf2 $DIR_TFTP/grub/fonts/
# Permisos
chmod -R 755 $DIR_TFTP

# 4. CREACIÓN DE IMAGEN LINUX (DEBOOTSTRAP)
echo -e "${VERDE}[4/7] Creando sistema base Linux (Esto tardará unos minutos)...${NC}"
mkdir -p $DIR_NFS
# Instalamos Ubuntu Jammy (22.04) base
debootstrap --arch=amd64 jammy $DIR_NFS http://archive.ubuntu.com/ubuntu/

# 5. CONFIGURACIÓN DENTRO DE LA IMAGEN (CHROOT AUTOMATIZADO)
echo -e "${VERDE}[5/7] Configurando el cliente Linux internamente...${NC}"
# Copiamos qemu por si acaso
cp /usr/bin/qemu-x86_64-static $DIR_NFS/usr/bin/
# Montamos binds
mount --bind /dev $DIR_NFS/dev
mount --bind /dev/pts $DIR_NFS/dev/pts
mount -t proc /proc $DIR_NFS/proc
mount -t sysfs /sys $DIR_NFS/sys

# Ejecutamos comandos dentro de la jaula
chroot $DIR_NFS /bin/bash <<EOF
# Configurar repositorios
echo "deb http://archive.ubuntu.com/ubuntu/ jammy main universe" > /etc/apt/sources.list
apt update
# Instalar kernel y herramientas de red (SIN PREGUNTAS)
DEBIAN_FRONTEND=noninteractive apt install -y linux-image-generic initramfs-tools nfs-common iproute2 nano
# Crear usuario
echo "root:asir" | chpasswd
useradd -m -s /bin/bash alumno
echo "alumno:asir" | chpasswd
# Hostname
echo "cliente-virtual" > /etc/hostname
# Fstab
echo "proc /proc proc defaults 0 0" > /etc/fstab
# Configurar initramfs para arranque NFS
sed -i 's/BOOT=local/BOOT=nfs/' /etc/initramfs-tools/initramfs.conf
update-initramfs -u
EOF

# Desmontamos
umount $DIR_NFS/sys
umount $DIR_NFS/proc
umount $DIR_NFS/dev/pts
umount $DIR_NFS/dev

# 6. EXPORTAR KERNEL Y NFS
echo -e "${VERDE}[6/7] Exportando Kernel y configurando NFS...${NC}"
# Copiar kernel e initrd al TFTP
cp $DIR_NFS/boot/vmlinuz* $DIR_TFTP/vmlinuz-cliente
cp $DIR_NFS/boot/initrd.img* $DIR_TFTP/initrd-cliente.img
chmod 644 $DIR_TFTP/vmlinuz-cliente $DIR_TFTP/initrd-cliente.img

# Configurar /etc/exports
echo "$DIR_NFS *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a

# 7. GENERAR MENÚ GRUB
echo -e "${VERDE}[7/7] Creando menú de arranque...${NC}"
cat <<EOF > $DIR_TFTP/grub/grub.cfg
set timeout=10
set default=0

menuentry "Arrancar Cliente Linux (NFS)" {
    echo "Cargando Kernel..."
    linux /vmlinuz-cliente root=/dev/nfs nfsroot=$SERVER_IP:$DIR_NFS rw ip=dhcp
    echo "Cargando Initrd..."
    initrd /initrd-cliente.img
}

menuentry "Instalador Windows (Requiere config extra)" {
    echo "Falta configurar WinPE y Samba/iSCSI..."
}
EOF

# REINICIO DE SERVICIOS
systemctl restart dnsmasq
systemctl restart nfs-kernel-server

echo -e "${VERDE}=== INSTALACIÓN COMPLETADA ===${NC}"
echo "Usuario Linux Cliente: alumno / Password: asir"
echo "Usuario Root Cliente: root / Password: asir"
echo "Asegúrate de que la interfaz $RED_INTERNA_IF tenga la IP $SERVER_IP"

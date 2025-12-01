# 🐧 Creación de la Imagen Base Linux (Root Filesystem NFS)

Este documento describe el proceso para generar el sistema de archivos raíz (`root filesystem`) mínimo que tu Thin Client cargará desde el servidor mediante **NFS (Network File System)**.

Se utiliza la herramienta **`debootstrap`**, la forma estándar de crear una instalación limpia de Debian/Ubuntu.

## ⚙️ Requisitos y Preparación

Asegúrate de ejecutar estos comandos en tu **Servidor PXE/NFS**.

### 1. Instalación de Herramientas

Necesitas `debootstrap` para crear el sistema base y `qemu-user-static` si tu servidor tiene una arquitectura diferente a la del cliente (aunque generalmente el thin client será x86 o ARM, igual que el servidor).

```bash
sudo apt update
sudo apt install debootstrap qemu-user-static nfs-commonS.

2. Definir Variables y Directorios
Define las variables para el montaje y la distribución.

Bash

# Directorio donde se montará el sistema de archivos raíz (Debe coincidir con /etc/exports)
EXPORT_DIR="/export/thinclient" 

# Distribución a usar (ej. 'buster' para Debian 10, 'focal' para Ubuntu 20.04)
DISTRO="buster" 

# Asegurar que el directorio esté limpio
sudo rm -rf $EXPORT_DIR/*
sudo mkdir -p $EXPORT_DIR
🧱 Proceso de Creación con debootstrap
1. Generar el Sistema Base
El comando debootstrap descargará e instalará el sistema de archivos base en el directorio.

Bash

echo "Iniciando debootstrap en $EXPORT_DIR..."
sudo debootstrap --arch=amd64 $DISTRO $EXPORT_DIR [http://deb.debian.org/debian/](http://deb.debian.org/debian/)
2. Montar el Sistema para Configuración
Necesitas montar los sistemas de archivos virtuales esenciales (/proc, /sys, /dev) para poder ingresar al entorno y configurarlo (proceso conocido como chroot).

Bash

echo "Montando sistemas de archivos virtuales..."
# Montar /proc y /sys
sudo mount --bind /proc $EXPORT_DIR/proc
sudo mount --bind /sys $EXPORT_DIR/sys
# Montar /dev
sudo mount --bind /dev $EXPORT_DIR/dev
3. Ingresar al Entorno Chroot
Ahora ingresas al entorno del Thin Client para realizar la configuración interna.

Bash

sudo chroot $EXPORT_DIR /bin/bash
📝 Configuración Interna (Dentro del Chroot)
Una vez dentro del chroot, ejecuta los siguientes comandos para configurar la imagen mínima.

1. Configuración de Red y Clave
Bash

# Establecer la contraseña de root
passwd root 

# Configurar el hostname del cliente (opcional)
echo "thinclient-pxe" > /etc/hostname

# Instalar herramientas básicas y DHCP para la red
apt update
apt install net-tools iproute2 dhcpcd5 ssh locales vim
2. Instalar el Kernel y Herramientas NFS
Es fundamental instalar el kernel y el paquete nfs-common para que el cliente pueda montar su propio sistema de archivos desde el servidor.

Bash

# Instalar el kernel Linux
apt install linux-image-amd64

# Instalar las herramientas para usar NFS
apt install nfs-common
3. Configuración de Inicio Remoto
El cliente debe saber que su sistema de archivos es remoto.

Edita /etc/fstab: Deja este archivo vacío, ya que el sistema de archivos raíz será montado por el kernel a través de los parámetros PXE (nfsroot).

Instalar el Cliente Remoto: Instala el software de conexión remota que necesites (Ej. xfreerdp para RDP, tightvnc para VNC, o un cliente VDI).

Bash

# Ejemplo: Instalar entorno gráfico mínimo y cliente RDP
apt install xorg openbox xserver-xorg-input-all xterm
apt install freerdp2-x11 
Crear Script de Inicio Automático: Configura un servicio de systemd o un script en el shell de inicio para que el cliente remoto se ejecute automáticamente tras el arranque.

4. Salir y Limpiar
Una vez terminada la configuración interna:

Bash

# Salir del entorno chroot
exit 
5. Desmontar Sistemas de Archivos
Fuera del chroot, limpia y desmonta los puntos de montaje:

Bash

echo "Limpiando y desmontando..."
sudo umount $EXPORT_DIR/proc
sudo umount $EXPORT_DIR/sys
sudo umount $EXPORT_DIR/dev
# Si usaste qemu:
# sudo umount $EXPORT_DIR/usr/bin/qemu-amd64-static 

echo "✅ Imagen Base Lista en $EXPORT_DIR"
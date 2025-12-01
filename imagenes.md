 🐧 Creación de la Imagen Base Linux (Root Filesystem NFS)

 proceso para generar el sistema de archivos raíz (`root filesystem`) mínimo que tu Thin Client cargará desde el servidor mediante **NFS (Network File System)**.

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

otro scrip necesario es el siguiente

#!/bin/bash

# Este script automatiza la creación de un sistema de archivos raíz (rootfs)
# minimalista de Debian/Ubuntu para un cliente ligero PXE usando NFS.

# --- CONFIGURACIÓN ---
# Directorio donde se montará el sistema de archivos raíz (Debe coincidir con /etc/exports)
EXPORT_DIR="/export/thinclient" 

# Distribución a usar (ej. 'buster' para Debian 10, 'focal' para Ubuntu 20.04)
# ¡ADVERTENCIA! Asegúrate de que esta distribución sea compatible con tu kernel PXE.
DISTRO="buster" 

# Arquitectura objetivo (amd64 es la más común para thin clients modernos)
ARCH="amd64" 

# Repositorio de la distribución
REPO="http://deb.debian.org/debian/"

# --------------------------------------------------------------------------

echo "======================================================"
echo "🚀 INICIANDO CREACIÓN DE IMAGEN THIN CLIENT (PXE/NFS)"
echo "======================================================"

# --- 1. PREPARACIÓN E INSTALACIÓN DE HERRAMIENTAS ---
echo "1. Instalando dependencias..."
sudo apt update
sudo apt install -y debootstrap qemu-user-static nfs-common

# --- 2. DEFINIR Y LIMPIAR DIRECTORIOS ---
echo "2. Definiendo variables y limpiando directorios..."
if [ -d "$EXPORT_DIR" ]; then
    echo "Limpiando contenido de $EXPORT_DIR..."
    sudo rm -rf $EXPORT_DIR/*
fi
sudo mkdir -p $EXPORT_DIR
echo "Directorio de exportación: $EXPORT_DIR"

# --- 3. PROCESO DE CREACIÓN CON DEBOOTSTRAP ---
echo "3. Generando el Sistema Base con debootstrap ($DISTRO)..."
sudo debootstrap --arch=$ARCH $DISTRO $EXPORT_DIR $REPO

# --- 4. MONTAR EL SISTEMA PARA CHROOT ---
echo "4. Montando sistemas de archivos virtuales (proc, sys, dev)..."
sudo mount --bind /proc $EXPORT_DIR/proc
sudo mount --bind /sys $EXPORT_DIR/sys
sudo mount --bind /dev $EXPORT_DIR/dev
if [ "$ARCH" != "$(uname -m)" ]; then
    echo "Montando qemu-user-static para chroot cruzado..."
    # Montar el binario QEMU para ejecutar comandos si la arquitectura es diferente
    sudo mount --bind /usr/bin/qemu-$(echo $ARCH | tr 'A-Z' 'a-z')-static $EXPORT_DIR/usr/bin/
fi

# --------------------------------------------------------------------------
# --- 5. CONFIGURACIÓN INTERNA (CHROOT INTERACTIVO) ---
# ESTA FASE ES INTERACTIVA Y REQUIERE INTERVENCIÓN MANUAL
# --------------------------------------------------------------------------
echo ""
echo "======================================================"
echo ">>> ENTRANDO AL ENTORNO CHROOT. DEBES CONFIGURAR MANUALMENTE:"
echo "    - 🔑 Contraseña de Root (passwd root)"
echo "    - 🔧 Configuración de Red/SSH/Locales"
echo "    - 🐧 Instalación de Kernel (apt install linux-image-amd64)"
echo "    - 🖥️ Instalación de Clientes Remotos (xorg, freerdp2-x11, etc.)"
echo "    - 🚀 Configuración de Autoarranque (Script de conexión)"
echo "    - 💾 Limpiar fstab (/etc/fstab debe estar vacío)"
echo ">>> ESCRIBE 'exit' PARA SALIR DEL CHROOT UNA VEZ TERMINADO."
echo "======================================================"
echo ""

# Ingresar al entorno Chroot
sudo chroot $EXPORT_DIR /bin/bash

# --- 6. SALIR Y LIMPIAR ---
echo "6. Saliendo del CHROOT y Desmontando sistemas de archivos..."

# Desmontar en orden inverso
if [ "$ARCH" != "$(uname -m)" ]; then
    echo "Desmontando binario qemu-static..."
    sudo umount $EXPORT_DIR/usr/bin/qemu-$(echo $ARCH | tr 'A-Z' 'a-z')-static
fi

sudo umount $EXPORT_DIR/dev
sudo umount $EXPORT_DIR/sys
sudo umount $EXPORT_DIR/proc

echo "======================================================"
echo "✅ Imagen Base Creada y Lista en $EXPORT_DIR"
echo "======================================================"

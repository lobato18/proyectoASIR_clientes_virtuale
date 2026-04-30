# 📑 Proyecto: Infraestructura de Clientes Virtuales

## 🧩 1. Resumen del Sistema

Este proyecto implementa una infraestructura basada en **Ubuntu Server** que actúa como:

- 🏢 Controlador de Dominio (AD DC) mediante Samba  
- 🖥️ Servidor de Virtualización (KVM/Libvirt)  
- 🌐 Servidor de Despliegue (PXE) *(en configuración)*  

---

## 🌐 2. Infraestructura de Red

### Configuración del Host

- **Interfaz física:** `enp1s0`  
- **Bridge:** `br0`  
- **IP del servidor:** `172.16.7.230/16`  

---

# ⚙️ Fase 1: Infraestructura de Red (Bridge)

## Crear puente temporal

```bash
sudo ip link add name br0 type bridge
sudo ip link set dev br0 up
Configuración persistente (Netplan)
sudo nano /etc/netplan/00-installer-config.yaml
```
Ejemplo:

network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
  bridges:
    br0:
      interfaces: [enp1s0]
      addresses: [172.16.7.230/16]
      gateway4: 172.16.0.1
      nameservers:
        addresses: [8.8.8.8]

Aplicar cambios:

sudo netplan apply
🏢 Fase 2: Configuración del Dominio (Samba AD DC)
Desplegar dominio
sudo bash dominio.sh

Interfaz:

enp1s0 o br0
Configuración del dominio
Realm: TECNOLOBATO.LOCAL
Dominio: TECNOLOBATO
Política de contraseñas (Opcional)
sudo samba-tool domain passwordsettings set --complexity=off
sudo samba-tool domain passwordsettings set --min-pwd-length=1
Gestión de usuarios
sudo bash gestion_usuarios.sh
OU principal: TecnoLobato
🖥️ Fase 3: Preparación de Virtualización
Permisos de ISOs
chmod +x /home/lobato
chmod +x /home/lobato/Descargas
Instalar dependencias
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system virtinst bridge-utils
💻 Fase 4: Despliegue de Clientes
Crear VM maestra
sudo bash create_vm.sh
Parámetros
Nombre: pclobato
IP: 172.16.2.80
ISO: /home/lobato/Descargas/Windows10.iso
Ver estado de VMs
sudo virsh list --all
Crear plantilla (post-instalación)
sudo mkdir -p /srv/pxe/templates/
sudo cp /var/lib/libvirt/images/pclobato.qcow2 /srv/pxe/templates/windows10_base.qcow2
Clonación automática
sudo bash crear_cliente.sh
📡 Fase 5: PXE (En progreso)

Scripts disponibles:

import_iso.sh → preparación de imágenes PXE

Ruta de configuración:

/var/lib/tftpboot/pxelinux.cfg/default
📊 Fase 6: Monitorización y Control
Comandos clave
# Ver VMs
sudo virsh list --all

# Ver VNC
sudo virsh domdisplay <nombre_vm>

# Apagar VM
sudo virsh shutdown <nombre_vm>

# Encender VM
sudo virsh start <nombre_vm>

# Eliminar VM
sudo virsh destroy <nombre_vm>
sudo virsh undefine <nombre_vm> --remove-all-storage
📁 Estructura de Archivos
Tipo	Ruta
Discos VM	/var/lib/libvirt/images/
Plantillas	/srv/pxe/templates/
Samba	/etc/samba/smb.conf
PXE	/var/lib/tftpboot/
🧰 Scripts del Proyecto
Script	Función	Estado
dominio.sh	Configuración AD DC	✅
gestion_usuarios.sh	Gestión de usuarios	✅
create_vm.sh	Crear VM base	⚙️
crear_cliente.sh	Clonar clientes	⏳
import_iso.sh	PXE	🧪
🚀 Estado del Proyecto
✔️ Dominio funcional
✔️ Virtualización operativa
⚙️ VM maestra en instalación
⏳ Clonación pendiente
🧪 PXE en desarrollo
📌 Próximos Pasos
Finalizar instalación de Windows en VM maestra
Convertirla en plantilla
Automatizar despliegue masivo
Completar servidor PXE

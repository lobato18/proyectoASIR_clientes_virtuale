#!/bin/bash


# Configuración
TEMPLATE="/srv/pxe/templates/windows10_base.qcow2"
STORAGE_DIR="/var/lib/libvirt/images"
SERVER_IP="172.16.229.232"

echo "=== SISTEMA DE DESPLIEGUE RÁPIDO DE CLIENTES ==="

# 1. Datos de la nueva máquina
read -p "Introduce el nombre del nuevo cliente: " VM_NAME
read -p "Introduce la IP para anotar (ej: 172.16.2.80): " VM_IP

# 2. Clonación
echo "Clonando disco..."
sudo cp "$TEMPLATE" "$STORAGE_DIR/$VM_NAME.qcow2"

# 3. Creación de la VM (Asegúrate de las barras invertidas al final de cada línea)
echo "Iniciando $VM_NAME..."

sudo virt-install \
  --name "$VM_NAME" \
  --ram 4096 \
  --vcpus 2 \
  --disk path="$STORAGE_DIR/$VM_NAME.qcow2",format=qcow2 \
  --os-variant win10 \
  --network bridge=br0,model=e1000 \
  --graphics vnc,listen=0.0.0.0,port=-1 \
  --import \
  --noautoconsole

# Obtener puerto VNC asignado
PORT=$(sudo virsh domdisplay "$VM_NAME" | cut -d: -f3)
ACTUAL_PORT=$((5900 + PORT))

echo "----------------------------------------------------"
echo "¡VM DESPLEGADA CON ÉXITO!"
echo "1. Conéctate por VNC a: $SERVER_IP:$ACTUAL_PORT"
echo "2. Configura en Windows -> IP: $VM_IP | GW: 172.16.50.6"
echo "----------------------------------------------------"

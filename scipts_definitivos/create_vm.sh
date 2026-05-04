#!/bin/bash 

read -p "Introduce el nombre de la VM: " VM_NAME
read -p "Introduce la dirección IP deseada: " STATIC_IP
read -p "Introduce la ruta de la ISO: " ISO_PATH


sudo ip link add name br0 type bridge
sudo ip link set dev br0 up
sudo ip link set dev br0 up
sudo ip link set dev enp1s0 master br0

sudo chmod 777 $ISO_PATH
 
echo "Creando máquina virtual '$VM_NAME'..."

sudo virt-install \
  --name "$VM_NAME" \
  --ram 4096 \
  --vcpus 2 \
  --disk size=30,format=qcow2 \
  --os-variant win10 \
  --network bridge=br0,model=virtio \
  --graphics vnc,listen=0.0.0.0,port=5901 \
  --noautoconsole \
  --cdrom "$ISO_PATH" \
  --boot hd,cdrom

echo "VM creada. Puedes acceder vía VNC en el puerto 5901 del host."

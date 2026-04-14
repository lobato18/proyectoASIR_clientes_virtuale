# 1. Preguntar el nombre
echo "Introduce el nombre para tu máquina virtual (ej: windows10):"
read NOMBRE_VM

# 2. Comprobar si el disco existe, si no, crearlo
if [ ! -f "$NOMBRE_VM.qcow2" ]; then
    echo "El disco $NOMBRE_VM.qcow2 no existe. Creando uno de 64GB..."
    qemu-img create -f qcow2 "$NOMBRE_VM.qcow2" 64G
fi

# 3. Lanzar QEMU con ese nombre
sudo qemu-system-x86_64 -m 4096 -smp 2 -enable-kvm -cpu host \
  -bios /usr/share/ovmf/OVMF.fd \
  -netdev user,id=n1,tftp=/srv/tftp,bootfile=ipxe.efi \
  -device e1000,netdev=n1 \
  -drive file="$NOMBRE_VM.qcow2",format=qcow2,if=none,id=drive0 \
  -device ahci,id=ahci \
  -device ide-hd,drive=drive0,bus=ahci.0 \
  -device qemu-xhci -device usb-tablet \
  -vnc :1

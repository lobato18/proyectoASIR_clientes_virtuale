# 💻 PXE Thin Client para Windows 11 vía RDP

Sistema de arranque por red (**PXE + NFS**) que carga un Linux minimalista en RAM para lanzar automáticamente una sesión RDP hacia un servidor con Windows 11.

---

## 🚀 Características

* ⚡ Arranque rápido sin disco (diskless)
* 🧠 Uso mínimo de recursos (thin client)
* 🔁 Reconexión automática RDP
* 🔒 Usuario sin privilegios
* 🖥️ Pantalla completa directa a Windows 11

---

## 🧱 Arquitectura

```text
[ Cliente PXE ]
       ↓
   (DHCP/TFTP)
       ↓
[ Kernel Linux ]
       ↓
   (NFS RootFS)
       ↓
[ Xorg + Openbox ]
       ↓
[ xfreerdp ]
       ↓
[ Windows 11 ]
```

---

## 🛠️ 1. Modificaciones en la Imagen Base (RootFS)

Accede al entorno `chroot` en:

```bash
/export/thinclient
```

### 📦 Instalar RDP y entorno gráfico

```bash
apt update
apt install -y xorg openbox xserver-xorg-input-all xterm freerdp2-x11
```

### 👤 Crear usuario limitado

```bash
adduser thinuser --disabled-password --gecos ""
```

### 🧹 Limpiar fstab

```bash
echo "" > /etc/fstab
```

---

## 🚀 2. Autoarranque de la sesión RDP

Crear el archivo:

```bash
nano /home/thinuser/.xinitrc
```

### 📄 Contenido del script

```bash
#!/bin/bash

xset s off
xset -dpms

while true; do
    xfreerdp /v:192.168.1.50 /u:MiDominio\\MiUsuario /p:MiContraseña /f /bpp:24
    sleep 5
done

exec openbox-session
```

### 🔐 Permisos

```bash
chmod +x /home/thinuser/.xinitrc
chown thinuser:thinuser /home/thinuser/.xinitrc
```

---

## 🧹 3. Salir del entorno chroot

```bash
exit
```

### 🔌 Desmontar sistemas

```bash
sudo umount /export/thinclient/dev
sudo umount /export/thinclient/sys
sudo umount /export/thinclient/proc
```

---

## ✅ Flujo de funcionamiento

1. 🖧 Cliente arranca por PXE
2. 📡 Descarga kernel vía TFTP
3. 📁 Monta `/export/thinclient` por NFS
4. 🐧 Linux inicia
5. 🖥️ Arranca Xorg
6. 👤 Login automático (`thinuser`)
7. 🚀 Ejecuta `.xinitrc`
8. 🔗 Conecta vía RDP a Windows 11
9. 🪟 Usuario trabaja directamente en Windows

---

## ⚙️ Requisitos

* Servidor PXE (DHCP + TFTP)
* Servidor NFS
* Imagen Linux minimalista
* Windows 11 con RDP habilitado

---

## 🔒 Seguridad

* ❗ Evitar contraseñas en texto plano
* 🔐 Usar credenciales seguras
* 🌐 Restringir acceso por red

---

## 📄 Licencia

MIT

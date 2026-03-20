## 💻 Plan de Conexión a Windows 11 vía RDP (usando PXE Linux)

El objetivo es usar la robustez de **PXE y NFS** para cargar rápidamente un sistema operativo Linux minimalista en la RAM del cliente, cuyo único propósito es lanzar el cliente RDP (`xfreerdp`) para acceder a un servidor con Windows 11.

---

### 1. 🛠️ Modificaciones en la Imagen Base (RootFS)

Debes volver a ingresar al entorno `chroot` de la imagen que creaste en `/export/thinclient` para instalar el software necesario y el script de autoarranque.

**⚠️ Instrucciones para ejecutar DENTRO del `chroot`:**

| Tarea | Comandos (Dentro del Chroot) |
| :--- | :--- |
| **Instalar RDP y Gráficos** | Instalar el servidor gráfico Xorg, un gestor de ventanas ligero (`openbox`), y el cliente RDP (`xfreerdp`).<br><br>`apt update`<br>`apt install -y xorg openbox xserver-xorg-input-all xterm freerdp2-x11` |
| **Crear Usuario Limitado** | Es buena práctica ejecutar el cliente RDP con un usuario sin privilegios.<br><br>`adduser thinuser --disabled-password --gecos ""` |
| **Limpieza de `fstab`** | Asegura que el archivo `/etc/fstab` esté vacío, ya que el *rootfs* se monta vía NFS, no localmente.<br><br>`echo "" > /etc/fstab` |

---

### 2. 🚀 Configuración del Autoarranque

Para que el cliente se conecte automáticamente, debes configurar un script que se ejecute al iniciar la sesión gráfica del usuario.

Crea el archivo `.xinitrc` en el directorio principal del usuario (`thinuser`) para que se ejecute automáticamente después de iniciar el servidor X.

```bash
# Comando a ejecutar DENTRO del chroot para crear el script
sudo nano /home/thinuser/.xinitrc


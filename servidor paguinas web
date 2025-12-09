***servidor web instanciar paguina


🐧 Instalación del Servidor Web Apache2 en Linux
El proceso es rápido y utiliza el administrador de paquetes apt.

1. Actualizar el Índice de Paquetes
Siempre debes actualizar tu lista local de paquetes antes de instalar cualquier software nuevo.

Bash

sudo apt update
2. Instalar el Paquete Apache2
Este comando descargará e instalará el servidor web y sus dependencias.

Bash

sudo apt install apache2
Se te pedirá que confirmes la instalación (S o Y).

3. Verificar el Estado del Servicio
Apache se iniciará automáticamente después de la instalación. Usa systemctl para confirmar que está activo y ejecutándose (active (running)).

Bash

sudo systemctl status apache2
Si por alguna razón no se inicia, puedes forzarlo con: sudo systemctl start apache2.

4. Ajustar el Firewall (UFW)
Si tu sistema utiliza el firewall UFW (Uncomplicated Firewall), debes permitir el tráfico web para que la gente pueda acceder a tu servidor.

Bash

# Mostrar las aplicaciones Apache disponibles en el firewall
sudo ufw app list

# Permitir el tráfico HTTP (puerto 80) y HTTPS (puerto 443)
sudo ufw allow 'Apache Full'

# (Opcional) Si el firewall no está activo, actívalo
# sudo ufw enable
5. Acceder y Verificar el Servidor
Tu servidor web está ahora en funcionamiento. Para verificarlo, abre tu navegador web y navega a la dirección IP de tu servidor o a localhost.

http://tu_direccion_ip_del_servidor
o

http://localhost
Si la instalación fue exitosa, verás la página de bienvenida predeterminada de "Apache2 Ubuntu Default Page".

🛠️ Archivos Clave
Raíz de Documentos Web: El contenido de tu sitio web debe ir en el directorio: /var/www/html/

Configuración Principal: /etc/apache2/apache2.conf

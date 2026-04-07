***servidor web instanciar pagina


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

 Configuración de Servidor Web (Apache)

Este script permite instalar y configurar un servidor web básico en Linux para mostrar una página de prueba.

📝 Descripción del Script

El script realiza las siguientes acciones:

Instalación: Descarga e instala el servidor web Apache2.

Limpieza: Elimina la página por defecto de Apache.

Creación: Genera una nueva página index.html con un diseño básico y un mensaje de bienvenida.

Permisos: Ajusta los permisos de la carpeta /var/www/html.

💻 Código del Script (instalar_web.sh)

#!/bin/bash

echo "===================================================="
echo "    INSTALADOR DE SERVIDOR WEB - TECNOLOBATO        "
echo "===================================================="

# 1. Actualizar e instalar Apache
echo "Instalando Apache2..."
sudo apt update
sudo apt install -y apache2

# 2. Habilitar y arrancar el servicio
echo "Iniciando el servicio web..."
sudo systemctl enable apache2
sudo systemctl start apache2

# 3. Crear la página de prueba
echo "Creando página de inicio personalizada..."
cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor de Prueba - Tecnolobato</title>
    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            padding: 50px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        h1 { color: #2c3e50; }
        p { color: #7f8c8d; }
        .logo { font-size: 50px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚀</div>
        <h1>¡Servidor Web Operativo!</h1>
        <p>Esta es la página de prueba del proyecto <strong>Tecnolobato</strong>.</p>
        <p>Si ves esto, Apache está funcionando correctamente.</p>
    </div>
</body>
</html>
EOF

# 4. Ajustar permisos
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "----------------------------------------------------"
echo "✅ SERVIDOR CONFIGURADO"
echo "Puedes acceder escribiendo la IP de tu servidor en el navegador."
echo "----------------------------------------------------"


🛠️ Instrucciones de uso

Crear el archivo: nano instalar_web.sh.

Dar permisos: chmod +x instalar_web.sh.

Ejecutar: sudo ./instalar_web.sh.

Para ver tu página, abre el navegador y escribe la dirección IP de tu máquina Linux (ejemplo: http://192.168.1.10).

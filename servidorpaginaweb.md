🌐 Configuración de Servidor Web (Apache)

Este script permite instalar y configurar un servidor web básico en Linux para mostrar una página de prueba personalizada.

📝 Descripción del Script

El script realiza las siguientes acciones automáticas:

Instalación: Descarga e instala el servidor web Apache2.

Activación: Configura el servicio para que se inicie automáticamente con el sistema.

Despliegue: Genera una página de inicio index.html con un diseño moderno (CSS3).

Permisos: Ajusta la seguridad de la carpeta web para que el servidor pueda leer los archivos.

💻 Código del Script (instalar_web.sh)

#!/bin/bash

echo "===================================================="
echo "    INSTALADOR DE SERVIDOR WEB - TECNOLOBATO        "
echo "===================================================="

# 1. Actualizar repositorios e instalar Apache2
echo "Instalando Apache2..."
sudo apt update
sudo apt install -y apache2

# 2. Habilitar y arrancar el servicio para que siempre esté activo
echo "Iniciando el servicio web..."
sudo systemctl enable apache2
sudo systemctl start apache2

# 3. Crear la página de prueba con diseño integrado
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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #eef2f3;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            max-width: 500px;
        }
        h1 { color: #2c3e50; margin-bottom: 10px; }
        p { color: #576574; line-height: 1.6; }
        .badge {
            background-color: #1dd1a1;
            color: white;
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 0.9em;
            font-weight: bold;
        }
        .logo { font-size: 60px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🌐</div>
        <span class="badge">ONLINE</span>
        <h1>¡Servidor Web Listo!</h1>
        <p>Has configurado correctamente el servidor Apache en tu proyecto <strong>Tecnolobato</strong>.</p>
        <p>Ahora puedes empezar a subir tus archivos a <code>/var/www/html</code>.</p>
    </div>
</body>
</html>
EOF

# 4. Ajustar permisos para el usuario del servidor (www-data)
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "----------------------------------------------------"
echo "✅ CONFIGURACIÓN FINALIZADA CON ÉXITO"
echo "Accede desde tu navegador usando la IP del servidor."
echo "----------------------------------------------------"


📖 Explicación Técnica del Servidor

Para entender cómo funciona este servidor web tras ejecutar el script, aquí tienes un desglose de los puntos clave:

¿Qué es Apache?: Es el software encargado de escuchar peticiones en el puerto 80 (HTTP) y entregar archivos (como el index.html) al navegador que los solicita.

Gestión del Servicio: Usamos systemctl enable para que el servidor web arranque automáticamente si reinicias la máquina, y systemctl start para ponerlo en marcha inmediatamente.

Ruta de los archivos: En sistemas basados en Debian/Ubuntu, la "raíz" del sitio web es /var/www/html. Cualquier archivo .html que pongas ahí será visible desde el exterior.

El comando cat <<EOF: Es una técnica de Bash llamada "Here Document". Permite escribir bloques largos de texto (en este caso, el código HTML/CSS) directamente dentro de un archivo sin tener que usar un editor manual.

Permisos de Usuario: El usuario www-data es la cuenta estándar bajo la cual corre Apache. Al asignar la propiedad con chown, nos aseguramos de que el servidor tenga permisos de lectura sobre la página web.

🛠️ Instrucciones de uso

Sigue estos pasos para desplegar tu servidor ahora mismo:

Crear el archivo del script:

nano instalar_web.sh


(Pega el código de arriba y guarda con Ctrl+O, sal con Ctrl+X).

Dar permisos de ejecución:

chmod +x instalar_web.sh


Ejecutar la instalación:

sudo ./instalar_web.sh


Para visualizar tu web: Abre el navegador en cualquier dispositivo de tu red y escribe la dirección IP de tu máquina Linux (ejemplo: http://192.168.1.10).

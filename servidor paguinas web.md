
📜 1. Script (install.sh)

Déjalo así (solo añado cabecera profesional y buenas prácticas):

#!/bin/bash

set -e  # Detiene el script si hay errores

echo "===================================================="
echo "    INSTALADOR DE SERVIDOR WEB - TECNOLOBATO        "
echo "===================================================="

# 1. Actualizar e instalar Apache
echo "📦 Instalando Apache2..."
sudo apt update
sudo apt install -y apache2

# 2. Habilitar y arrancar el servicio
echo "🚀 Iniciando el servicio web..."
sudo systemctl enable apache2
sudo systemctl start apache2

# 3. Crear la página de prueba
echo "🌐 Creando página de inicio personalizada..."
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
📘 2. README.md (IMPORTANTE para GitHub)

Este es lo que hará que tu repo se vea 🔥:

# 🚀 Instalador de Servidor Web - Tecnolobato

Script automático para instalar y configurar un servidor web con Apache en sistemas Linux (Ubuntu/Debian).

---

## 📦 Características

- Instalación automática de Apache2
- Configuración del servicio (enable + start)
- Página web personalizada de prueba
- Ajuste automático de permisos

---

## ⚙️ Requisitos

- Sistema basado en Debian/Ubuntu
- Usuario con permisos `sudo`
- Conexión a Internet

---

## 🚀 Instalación y uso

1. Clona el repositorio:

```bash
git clone https://github.com/tu-usuario/tecnolobato-web-server.git
cd tecnolobato-web-server
Da permisos de ejecución:
chmod +x install.sh
Ejecuta el script:
./install.sh
🌐 Resultado

Después de la instalación, podrás acceder a la página web desde tu navegador usando:

http://IP_DE_TU_SERVIDOR
📸 Vista previa

El script crea una página web simple con un mensaje:

"¡Servidor Web Operativo!"

🛠️ Tecnologías usadas
Apache2
Bash scripting
HTML + CSS
📄 Licencia

Este proyecto es de uso libre para fines educativos.

👨‍💻 Autor

Tecnolobato


---

## 🔥 Tips para que quede aún mejor en GitHub

- Añade un `.gitignore` (aunque sea básico)
- Súbelo con este comando:

```bash
git init
git add .
git commit -m "Primer commit - instalador Apache"
git branch -M main
git remote add origin https://github.com/tu-usuario/tecnolobato-web-server.git
git push -u origin main

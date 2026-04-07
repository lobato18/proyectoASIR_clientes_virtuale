Configuración de Servidor Web (Apache) - Blog Tecnolobato

Este script instala Apache y despliega un Blog de Informática moderno como página de inicio.

📝 Descripción del Proyecto

La página generada es un portal de noticias tecnológicas que incluye:

Cabecera Hero: Con el título del proyecto.

Sección de Artículos: Diseño en tarjetas (Cards) con imágenes.

Barra Lateral: Con categorías de informática.

Diseño Responsive: Se ve bien en cualquier dispositivo.

💻 Código del Script de Instalación (instalar_blog.sh)

#!/bin/bash

# ====================================================
#     INSTALADOR DE BLOG INFORMÁTICO - TECNOLOBATO    
# ====================================================

# 1. Instalación de Apache
echo "Instalando el servidor web..."
sudo apt update
sudo apt install -y apache2

# 2. Configuración del servicio
sudo systemctl enable apache2
sudo systemctl start apache2

# 3. Creación del Home Page (Blog de Informática)
echo "Generando el portal de Tecnolobato..."
cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tecnolobato | Blog d'Informàtica</title>
    <style>
        :root {
            --primary: #2563eb;
            --dark: #1e293b;
            --light: #f8fafc;
        }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            margin: 0;
            background-color: var(--light);
            color: var(--dark);
        }
        header {
            background: linear-gradient(135deg, var(--primary), #000);
            color: white;
            padding: 60px 20px;
            text-align: center;
        }
        nav {
            background: white;
            padding: 15px;
            display: flex;
            justify-content: center;
            gap: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        nav a { text-decoration: none; color: var(--dark); font-weight: bold; }
        
        .container {
            max-width: 1100px;
            margin: 40px auto;
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            padding: 0 20px;
        }

        /* Secció de Post */
        .blog-posts { display: flex; flex-direction: column; gap: 30px; }
        .card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        .card-img {
            height: 250px;
            background: #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
        }
        .card-content { padding: 25px; }
        .card h2 { margin-top: 0; color: var(--primary); }

        /* Barra Lateral */
        aside {
            background: white;
            padding: 25px;
            border-radius: 12px;
            height: fit-content;
        }
        .category-list { list-style: none; padding: 0; }
        .category-list li {
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }

        footer {
            text-align: center;
            padding: 40px;
            background: var(--dark);
            color: white;
            margin-top: 50px;
        }

        @media (max-width: 768px) {
            .container { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<header>
    <h1>Aquest és el servidor de Tecnolobato</h1>
    <p>Benvinguts al blog oficial d'informàtica i xarxes</p>
</header>

<nav>
    <a href="#">Inici</a>
    <a href="#">Tutorials</a>
    <a href="#">Hardware</a>
    <a href="#">Samba AD</a>
</nav>

<div class="container">
    <main class="blog-posts">
        <!-- Post 1 -->
        <article class="card">
            <div class="card-img">💻</div>
            <div class="card-content">
                <h2>Últimes novetats en Programari Lliure</h2>
                <p>Explorem com les noves actualitzacions de Linux estan canviant el panorama dels servidors empresarials el 2026.</p>
                <a href="#" style="color: var(--primary);">Llegir més...</a>
            </div>
        </article>

        <!-- Post 2 -->
        <article class="card">
            <div class="card-img">🛡️</div>
            <div class="card-content">
                <h2>Seguretat en Xarxes amb Samba 4</h2>
                <p>Com configurar correctament el teu controlador de domini per evitar atacs externs i protegir la teva OU.</p>
                <a href="#" style="color: var(--primary);">Llegir més...</a>
            </div>
        </article>
    </main>

    <aside>
        <h3>Categories</h3>
        <ul class="category-list">
            <li>Sistemes Operatius</li>
            <li>Ciberseguretat</li>
            <li>Desenvolupament Web</li>
            <li>Administració de Xarxes</li>
        </ul>
        <br>
        <div style="background: #e2e8f0; padding: 15px; border-radius: 8px;">
            <h4>Sobre el servidor</h4>
            <p style="font-size: 0.9em;">Aquesta pàgina s'està servint des d'un servidor Apache2 configurat per l'equip de Tecnolobato.</p>
        </div>
    </aside>
</div>

<footer>
    <p>&copy; 2026 Tecnolobato Project - Tots els drets reservats</p>
</footer>

</body>
</html>
EOF

# 4. Permisos finalitzats
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "----------------------------------------------------"
echo "✅ BLOG DE TECNOLOBATO INSTAL·LAT"
echo "Accedeix mitjançant la teva IP per veure el blog."
echo "----------------------------------------------------"


🛠️ Com utilitzar-lo

Crea el fitxer: nano instalar_blog.sh.

Dóna permisos: chmod +x instalar_blog.sh.

Executa: sudo ./instalar_blog.sh.

Al entrar en tu navegador, verás una interfaz de blog profesional con una cabecera azul degradada, iconos y secciones bien organizadas.

Ejecutar la instalación:

sudo ./instalar_web.sh


Para visualizar tu web: Abre el navegador en cualquier dispositivo de tu red y escribe la dirección IP de tu máquina Linux (ejemplo: http://192.168.1.10).

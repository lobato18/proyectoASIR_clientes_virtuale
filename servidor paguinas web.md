
# 🚀 Instalador de Servidor Web - Tecnolobato

Script automático para instalar y configurar un servidor web con Apache en Linux (Ubuntu/Debian).

---

## 📜 Script

```bash
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
```

---

## ⚙️ Uso

```bash
chmod +x install.sh
./install.sh
```

---

## 🌐 Resultado

Accede desde tu navegador:

```
http://IP_DE_TU_SERVIDOR
```

---

## 👨‍💻 Autor

Tecnolobato

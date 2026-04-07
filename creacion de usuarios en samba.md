🚀 Gestión de Usuarios en Active Directory (Samba 4)
Este apartado contiene la herramienta necesaria para alimentar nuestra Unidad Organizativa (OU) de Tecnolobato con nuevos miembros de forma rápida y segura.

📝 Descripción del Script
El script de Alta de Usuarios es una herramienta interactiva diseñada para administradores. En lugar de ejecutar comandos manuales complejos, el script solicita los datos básicos y realiza la configuración automáticamente en el servidor.

Beneficios de usar este script:

✨ Velocidad: Crea usuarios en segundos sin errores de sintaxis.

🔒 Seguridad: La contraseña se introduce de forma oculta (no se ve mientras escribes).

📁 Orden: Ubica al usuario directamente en el contenedor OU=tecnolobato.

✅ Feedback: Te confirma visualmente si el usuario se creó con éxito o si hubo un error.

💻 Código del Script (alta_usuarios.sh)
Bash
#!/bin/bash
# Configuración de la ruta de la OU de destino
OU_TARGET="OU=tecnolobato,dc=tecnolobato,dc=local"

echo "===================================================="
echo "   GESTOR DE ALTA DE USUARIOS - TECNOLOBATO         "
echo "===================================================="

# Solicitar datos de forma interactiva
read -p "Nombre del nuevo usuario (ej: lobato01): " NEW_USER
read -s -p "Introduce la contraseña para $NEW_USER: " USER_PASS
echo "" # Salto de línea estético

echo "Registrando a $NEW_USER en el dominio..."

# Comando oficial de Samba para crear el usuario en la OU específica
samba-tool user create "$NEW_USER" "$USER_PASS" --userou="$OU_TARGET"

# Verificación del resultado del comando anterior
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo "✅ ÉXITO: El usuario $NEW_USER ha sido creado."
    echo "Ubicación: $OU_TARGET"
    echo "----------------------------------------------------"
else
    echo "----------------------------------------------------"
    echo "❌ ERROR: No se pudo crear el usuario."
    echo "Revisa si el usuario ya existe o si el servicio AD está activo."
    echo "----------------------------------------------------"
fi
🛠️ Instrucciones de uso
Para ejecutar este script en tu servidor Linux, sigue estos tres pasos:

Crear el archivo: nano alta_usuarios.sh (y pega el código de arriba).

Dar permisos: chmod +x alta_usuarios.sh.

Ejecutar: sudo ./alta_usuarios.sh.

Nota: Asegúrate de haber ejecutado primero el script de creación de la OU para que el contenedor tecnolobato exista antes de intentar añadir miembros.

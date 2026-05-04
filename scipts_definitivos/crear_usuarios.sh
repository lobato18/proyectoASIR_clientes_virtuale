#!/bin/bash
# Configuración de la ruta de la OU de destino
OU_TARGET="OU=tecnolobato,dc=tecnolobato,dc=local"

echo "===================================================="
echo "    GESTOR DE ALTA DE USUARIOS - TECNOLOBATO         "
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

```bash

🛠️ Instrucciones de uso

Para ejecutar este script en tu servidor Linux, sigue estos tres pasos:

Crear el archivo: nano alta_usuarios.sh (y pega el código de arriba).

Dar permisos: chmod +x alta_usuarios.sh.

Ejecutar: sudo ./alta_usuarios.sh.

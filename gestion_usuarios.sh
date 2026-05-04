#!/bin/bash

# --- CONFIGURACIÓN BÁSICA ---
DOMAIN_DN="DC=tecnolobato,DC=local"
ADMIN_PASS='TecnoLobato2026!'

echo "============================================================"
echo "   GESTOR DE USUARIOS Y UNIDADES ORGANIZATIVAS (SAMBA AD)   "
echo "============================================================"

# 1. GESTIÓN DE LA UNIDAD ORGANIZATIVA (OU)
read -p "Nombre de la Unidad Organizativa (ej: Ventas): " OU_NAME
OU_DN="OU=$OU_NAME,$DOMAIN_DN"

# Comprobar si la OU ya existe
samba-tool ou list | grep -i "OU=$OU_NAME" > /dev/null

if [ $? -eq 0 ]; then
    echo "⚠️  La OU '$OU_NAME' ya existe."
    read -p "¿Deseas unir al nuevo usuario a esta OU existente? (s/n): " JOIN_OU
    if [[ ! $JOIN_OU =~ ^[Ss]$ ]]; then
        echo "❌ Operación cancelada por el usuario."
        exit 1
    fi
else
    echo "🔨 Creando nueva Unidad Organizativa: $OU_NAME..."
    samba-tool ou create "$OU_DN"
    echo "✅ OU creada con éxito."
fi

echo "------------------------------------------------------------"

# 2. GESTIÓN DEL USUARIO
read -p "Nombre del nuevo usuario (login): " USER_NAME
read -s -p "Contraseña para $USER_NAME: " USER_PASS
echo ""

# Crear el usuario dentro de la OU seleccionada
echo "👤 Creando usuario '$USER_NAME' en '$OU_DN'..."

samba-tool user add "$USER_NAME" "$USER_PASS" --userou="OU=$OU_NAME"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------------------"
    echo "🚀 ¡ÉXITO TOTAL!"
    echo "Usuario: $USER_NAME"
    echo "Ubicación: $OU_DN"
    echo "------------------------------------------------------------"
else
    echo "❌ Error al crear el usuario. Revisa que el nombre no esté duplicado."
fi

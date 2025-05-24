#!/bin/bash

# Configuración base (debe coincidir con el script de creación)
BASE_DIR="/home"
FTP_GROUP_PREFIX="grupo"
HTML_DIR="html_public"
DB_PREFIX="db_"

eliminar_grupo() {
    echo -e "\n\033[1;33m🔻 Ingresa el nombre exacto del grupo/usuario a eliminar (ejemplo: grupo01):\033[0m"
    read GRUPO_ELIMINAR

    # Verifica si el usuario existe
    if ! id "$GRUPO_ELIMINAR" &>/dev/null; then
        echo -e "\033[1;31m❌ El usuario $GRUPO_ELIMINAR no existe.\033[0m"
        exit 1
    fi

    DB_NAME="${DB_PREFIX}${GRUPO_ELIMINAR}"

    echo -e "\033[1;33m🧹 Eliminando base de datos y usuario MySQL...\033[0m"
    sudo mysql -e "DROP DATABASE IF EXISTS $DB_NAME;"
    sudo mysql -e "DROP USER IF EXISTS '$GRUPO_ELIMINAR'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"

    echo -e "\033[1;33m🗑️ Eliminando directorio del usuario...\033[0m"
    if [ -d "$BASE_DIR/$GRUPO_ELIMINAR" ]; then
        sudo rm -rf "$BASE_DIR/$GRUPO_ELIMINAR"
    fi

    echo -e "\033[1;33m👤 Eliminando usuario del sistema...\033[0m"
    sudo userdel "$GRUPO_ELIMINAR"

    echo -e "\033[1;33m👥 Eliminando grupo del sistema (si existe)...\033[0m"
    if getent group "$GRUPO_ELIMINAR" > /dev/null; then
        sudo groupdel "$GRUPO_ELIMINAR"
    fi

    echo -e "\n\033[1;32m✅ Eliminación completa:\033[0m"
    echo -e "\033[1;34m👥 Grupo eliminado:\033[0m $GRUPO_ELIMINAR"
    echo -e "\033[1;32m-------------------------------------------\033[0m"
}

# Ejecutar función
eliminar_grupo

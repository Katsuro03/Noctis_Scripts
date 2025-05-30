#!/bin/bash

# Configuración
BASE_DIR="/home"
FTP_GROUP_PREFIX="grupo"
HTML_DIR="html_public"
DB_PREFIX="db_"
DOMAIN="172.17.42.54"

# URLs desde GitHub
URL_HTML="https://raw.githubusercontent.com/BOOTEABLE/pagina-web/refs/heads/main/paginadefault.html"
URL_VIDEO="https://raw.githubusercontent.com/BOOTEABLE/pagina-web/refs/heads/main/robot.webm"

crear_grupo() {
    USER_COUNT=$(ls $BASE_DIR | grep -E "^$FTP_GROUP_PREFIX[0-9]{2}$" | wc -l)
    NEW_GROUP_NUM=$(printf "%02d" $((USER_COUNT + 1)))
    NEW_GROUP="$FTP_GROUP_PREFIX$NEW_GROUP_NUM"
    PASSWORD=$(openssl rand -base64 12)

    if id "$NEW_GROUP" &>/dev/null; then
        echo -e "\033[1;31m❌ El usuario $NEW_GROUP ya existe.\033[0m"
        exit 1
    fi

    # Crear usuario del sistema
    sudo useradd -m -d "$BASE_DIR/$NEW_GROUP" -s /bin/bash "$NEW_GROUP"
    echo "$NEW_GROUP:$PASSWORD" | sudo chpasswd

    # Crear carpeta web
    sudo mkdir -p "$BASE_DIR/$NEW_GROUP/$HTML_DIR"
    sudo wget -q -O "$BASE_DIR/$NEW_GROUP/$HTML_DIR/index.html" "$URL_HTML"
    sudo wget -q -O "$BASE_DIR/$NEW_GROUP/$HTML_DIR/robot.webm" "$URL_VIDEO"
    sudo sed -i "s/{{USUARIO}}/$NEW_GROUP/g" "$BASE_DIR/$NEW_GROUP/$HTML_DIR/index.html"
    sudo chown -R "$NEW_GROUP:$NEW_GROUP" "$BASE_DIR/$NEW_GROUP"
    sudo chmod -R 755 "$BASE_DIR/$NEW_GROUP"

    # Crear usuario en MySQL
    sudo mysql -e "CREATE USER IF NOT EXISTS '$NEW_GROUP'@'localhost' IDENTIFIED BY '$PASSWORD';"

    # Crear 5 bases de datos y asignar permisos
    for i in {1..5}; do
        DB_NAME="${DB_PREFIX}${NEW_GROUP}_${i}"
        sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
        sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$NEW_GROUP'@'localhost';"
    done

    sudo mysql -e "FLUSH PRIVILEGES;"

    # Resultado
    echo -e "\n\033[1;32m✅ Grupo creado exitosamente:\033[0m"
    echo -e "\033[1;34m👤 Usuario:\033[0m $NEW_GROUP"
    echo -e "\033[1;34m🔑 Contraseña:\033[0m $PASSWORD"
    echo -e "\033[1;34m💾 Bases de datos:\033[0m ${DB_PREFIX}${NEW_GROUP}_1 a _5"
    echo -e "\033[1;34m🌍 Sitio web:\033[0m http://$DOMAIN/$NEW_GROUP/"
}

crear_grupo


#!/bin/bash

# Configuraciones generales
BASE_DIR="/home"
FTP_GROUP_PREFIX="grupo"
HTML_DIR="html_public"
DB_PREFIX="db_"
DOMAIN="172.17.42.54"
PORT=80

# URLs de los archivos a descargar desde el repositorio de GitHub
GITHUB_REPO_URL_HTML="https://raw.githubusercontent.com/BOOTEABLE/pagina-web/refs/heads/main/paginadefault.html"
GITHUB_REPO_URL_VIDEO="https://raw.githubusercontent.com/BOOTEABLE/pagina-web/refs/heads/main/robot.webm"

crear_grupo() {

    USER_COUNT=$(ls $BASE_DIR | grep -E "^$FTP_GROUP_PREFIX[0-9]{2}$" | wc -l)
    NEW_GROUP_NUM=$(printf "%02d" $((USER_COUNT + 1)))
    NEW_GROUP="$FTP_GROUP_PREFIX$NEW_GROUP_NUM"

    # Verificar si el usuario ya existe
    if id "$NEW_GROUP" &>/dev/null; then
        echo -e "\033[1;31m❌ El usuario $NEW_GROUP ya existe. Abortando creación.\033[0m"
        exit 1
    fi

    PASSWORD=$(openssl rand -base64 12)

    # Crear usuario
    if ! sudo useradd -m -d "$BASE_DIR/$NEW_GROUP" -s /bin/bash "$NEW_GROUP"; then
        echo -e "\033[1;31m❌ Error al crear el usuario $NEW_GROUP.\033[0m"
        exit 1
    fi

    # Asignar contraseña
    if ! echo "$NEW_GROUP:$PASSWORD" | sudo chpasswd; then
        echo -e "\033[1;31m❌ Error al asignar la contraseña para $NEW_GROUP.\033[0m"
        exit 1
    fi

    # Crear carpeta html_public
    if ! sudo mkdir -p "$BASE_DIR/$NEW_GROUP/$HTML_DIR"; then
        echo -e "\033[1;31m❌ Error al crear el directorio HTML para $NEW_GROUP.\033[0m"
        exit 1
    fi

    # Cambiar propietario y permisos
    if ! sudo chown -R $NEW_GROUP:$NEW_GROUP "$BASE_DIR/$NEW_GROUP"; then
        echo -e "\033[1;31m❌ Error al cambiar propietario de los archivos.\033[0m"
        exit 1
    fi                                                                                                                                                                        
    sudo chmod 755 "$BASE_DIR/$NEW_GROUP"
    sudo chmod 755 "$BASE_DIR/$NEW_GROUP/$HTML_DIR"

    # Descargar archivo HTML
    echo "Descargando archivo HTML desde GitHub..."
    if ! sudo wget -q -O "$BASE_DIR/$NEW_GROUP/$HTML_DIR/index.html" "$GITHUB_REPO_URL_HTML"; then
        echo -e "\033[1;31m❌ Error al descargar el archivo HTML.\033[0m"
        exit 1
    fi

    # Descargar archivo video
    echo "Descargando archivo de video desde GitHub..."
    if ! sudo wget -q -O "$BASE_DIR/$NEW_GROUP/$HTML_DIR/robot.webm" "$GITHUB_REPO_URL_VIDEO"; then
        echo -e "\033[1;31m❌ Error al descargar el archivo de video.\033[0m"
        exit 1
    fi

    # Cambiar propietario de los archivos descargados
    if ! sudo chown "$NEW_GROUP:$NEW_GROUP" "$BASE_DIR/$NEW_GROUP/$HTML_DIR/index.html"; then
        echo -e "\033[1;31m❌ Error al cambiar propietario del archivo index.html.\033[0m"
        exit 1
    fi
    if ! sudo chown "$NEW_GROUP:$NEW_GROUP" "$BASE_DIR/$NEW_GROUP/$HTML_DIR/robot.webm"; then
        echo -e "\033[1;31m❌ Error al cambiar propietario del archivo robot.webm.\033[0m"
        exit 1
    fi

    # Reemplazar {{USUARIO}} en el HTML
    if ! sudo sed -i "s/{{USUARIO}}/$NEW_GROUP/g" "$BASE_DIR/$NEW_GROUP/$HTML_DIR/index.html"; then
        echo -e "\033[1;31m❌ Error al editar el archivo HTML.\033[0m"
        exit 1
    fi

    # Crear base de datos y usuario en MySQL
    DB_NAME="${DB_PREFIX}${NEW_GROUP}"
    if ! sudo mysql -e "CREATE DATABASE $DB_NAME;"; then
        echo -e "\033[1;31m❌ Error al crear la base de datos $DB_NAME.\033[0m"
        exit 1
    fi

    # Nota: en tu script original tienes CREATE GROUP, pero para MySQL normalmente es CREATE USER
    if ! sudo mysql -e "CREATE USER '$NEW_GROUP'@'localhost' IDENTIFIED BY '$PASSWORD';"; then
        echo -e "\033[1;31m❌ Error al crear el usuario MySQL $NEW_GROUP.\033[0m"
        exit 1
    fi

    if ! sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$NEW_GROUP'@'localhost';"; then
        echo -e "\033[1;31m❌ Error al asignar privilegios a $NEW_GROUP en la base de datos $DB_NAME.\033[0m"
        exit 1
     
    fi

    sudo mysql -e "FLUSH PRIVILEGES;"

    # Cambiar permisos y propietarios de html_public para servidor web
    sudo chown -R $NEW_GROUP:www-data "$BASE_DIR/$NEW_GROUP/$HTML_DIR"
    sudo chmod -R 755 "$BASE_DIR/$NEW_GROUP/$HTML_DIR"
    sudo chmod 755 "$BASE_DIR/$NEW_GROUP"

    # Mostrar resumen
    echo -e "\n\033[1;32m✅ Usuario creado exitosamente:\033[0m"
    echo -e "\033[1;34m👤 Usuario:\033[0m $NEW_GROUP"
    echo -e "\033[1;34m🔑 Contraseña:\033[0m $PASSWORD"
    echo -e "\033[1;34m📊 Base de datos:\033[0m $DB_NAME"
    echo -e "\033[1;34m🌍 Sitio web:\033[0m http://$DOMAIN/$NEW_GROUP/"
    echo -e "\033[1;32m-------------------------------------------\033[0m"
}

crear_grupo 

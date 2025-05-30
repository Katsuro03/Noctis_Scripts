# Gestión de Grupos y Usuarios en Linux con MySQL

Scripts Bash para automatizar la creación/eliminación de grupos, usuarios y sus respectivas bases de datos MySQL.

## 📦 Scripts

### `add_group.sh`
**Propósito**:  
Crea un nuevo grupo/usuario en el sistema, asigna directorios y configura una base de datos MySQL asociada.

### `del_group.sh`  
**Propósito**:  
Elimina completamente un grupo/usuario, incluyendo su base de datos, directorios y archivos asociados.

---

## 🚀 Instrucciones de Uso

### Prerrequisitos
- Ejecutar como **root** o con `sudo`
- MariaDB/MySQL instalado
- Bash en Linux

### 📥 Instalación
```bash
git clone https://github.com/tu-repositorio/Noctis_Scripts.git
cd Noctis_Scripts/Public
chmod +x *.sh  # Dar permisos de ejecución

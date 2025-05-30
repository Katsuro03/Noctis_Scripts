# Gestión de Grupos y Usuarios (add_group.sh y del_group.sh)

Este repositorio contiene scripts para la creación y eliminación de grupos y usuarios en un sistema Linux, junto con la gestión de bases de datos MySQL asociadas a cada grupo.

## Scripts incluidos

- `add_group.sh`: Script para crear un grupo y usuario, asignar directorios y crear una base de datos MySQL asociada.
- `del_group.sh`: Script para eliminar un grupo y usuario, así como borrar la base de datos y los archivos asociados.

## Uso

### add_group.sh

Ejecuta el script para crear un grupo/usuario nuevo con su base de datos:

```bash
./add_group.sh
El script solicitará el nombre del grupo y otros datos necesarios.

del_group.sh
Ejecuta el script para eliminar un grupo/usuario y todos sus recursos:
./del_group.sh
Requisitos
Permisos de superusuario para ejecutar comandos useradd, groupadd, mysql, etc.

MariaDB/MySQL instalado y configurado.

Bash shell en Linux.

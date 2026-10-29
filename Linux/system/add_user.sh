#!/usr/bin/env bash
#===============================================================================
# Nombre:       add_user.sh
# Descripción:  Da de alta un usuario para administración remota por SSH con
#               clave pública y lo añade a sudoers (NOPASSWD).
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   useradd y privilegios de root.
# Uso:          ./add_user.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================
set -euo pipefail

# Variables
USER_NAME="<NOMBRE_USUARIO>"
USER_COMENT="<COMENTARIO>"
# Añadiendo usuario para administración remota
useradd -m -d "/home/$USER_NAME" -s /bin/bash -c "$USER_COMENT" -u 1000 "$USER_NAME"
mkdir "/home/$USER_NAME/.ssh"
chmod u=rwx,g-rwx,o-rwx "/home/$USER_NAME/.ssh"
echo '<LLAVE_SSH_PUBLICA>' >> "/home/$USER_NAME/.ssh/authorized_keys"
chmod 700 "/home/$USER_NAME/.ssh"
chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"
chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME/.ssh"

# Deshabilitar la contraseña para el usuario de administración remota (sudoers)
sed -i '/^%sudo.*/a $USER_NAME    ALL=NOPASSWD: ALL' /etc/sudoers

# Borrar script despues de su ejecucion deshabilitado
# rm $0
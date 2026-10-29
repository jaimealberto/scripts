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

# Conceder sudo sin contraseña (NOPASSWD) de forma segura: un fichero propio en
# /etc/sudoers.d (nunca editar /etc/sudoers directamente) con permisos 440 y
# validado con visudo antes de darlo por bueno.
printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$USER_NAME" > "/etc/sudoers.d/$USER_NAME"
chmod 440 "/etc/sudoers.d/$USER_NAME"
visudo -cf "/etc/sudoers.d/$USER_NAME"

# Borrar el script después de su ejecución (deshabilitado por defecto)
# rm -- "$0"
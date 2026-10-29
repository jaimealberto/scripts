#!/bin/bash
# Ejecutar como root
# https://jaimealberto.io
# 11/11/2022
# Variables
USER_NAME="<NOMBRE_USUARIO>"
USER_COMENT="<COMENTARIO>"
# Añadiedo usuario para gestion remota
useradd -m -d /home/$USER_NAME -s /bin/bash -c "$USER_COMENT" -u 1000 $USER_NAME
mkdir /home/$USER_NAME/.ssh
chmod u=rwx,g-rwx,o-rwx /home/$USER_NAME/.ssh
echo '<LLAVE_SSH_PUBLICA>' >> /home/$USER_NAME/.ssh/authorized_keys
chmod 700 /home/$USER_NAME/.ssh
chmod 600 /home/$USER_NAME/.ssh/authorized_keys
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh

# Deshabilitar password to root usuario gestion remota
sed -i '/^%sudo.*/a $USER_NAME    ALL=NOPASSWD: ALL' /etc/sudoers

# Borrar script despues de su ejecucion deshabilitado
# rm $0
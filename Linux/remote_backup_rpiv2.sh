#!/bin/bash
set -e

###############################################################################
# Script: remote_backup_rpiv2.sh                                              #
# Date: 01/08/2025 - Versión optimizada                                       #
# Description:: Backup remoto de Raspberry Pi a través de SSH con alertas.    #
# Author: jaimealberto.io                                                     #
# Requirements: Conexión SSH sin contraseña (con llave), gzip y msmtp.        #
# Config msmtp                                                                #
# Creation of the file .msmtprc                                               #
# account default                                                             #
# host smtp.gmail.com                                                         #
# port 587                                                                    #
# from <quienenviaelcorreo@gmail.com>                                         #
# tls on                                                                      #
# tls_starttls on                                                             #
# auth on                                                                     #
# user <quienenviaelcorreo>                                                   #
# password <passord de la cuenta que envía el correo>                         #
# logfile ~/.msmtp.log                                                        #
# We give the necessary permissions to the configuration file                 #
# chmod 600 .msmtprc                                                          #
# Checks: ping, integridad fichero de backup , envió correo si falla          #
# Alerts: ping failure mailing or backup file integrity                       #
# 00 1 * * * ~/scripts/remote_backup_rpiv2.sh >/dev/null 2>&1                 #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
# Mejoras respecto a al versión anterior                                      #
#  Uso de variables y funciones: Se han agrupado las variables en un bloque,  #
#  se ha creado una función para el envío de correos, y se ha utilizado la    #
#  sintaxis de Bash más moderna.                                              #
#  Manejo de errores mejorado: Las verificaciones de errores se agrupan, lo   #
#   que hace el código más legible y eficiente. El script utiliza `set -e`    #
#   para salir inmediatamente si un comando falla.                            #
#  Comentarios y claridad                                                     #
#  Ruta de logs más dinámica                                                  #
# #############################################################################
# ==================== PARÁMETROS DE CONFIGURACIÓN ====================
host_remoto="<hostname_descriptivo>"
ip_remota="<ip_o_fqdn>"
usuario="<user>"
origen="/dev/mmcblk0"
mail_to="destino_alerta@dominio.com"

# Directorios de trabajo
working="<destino_copia>"
working_log="$working/logs"

# Nombres de archivos
timestamp_log=$(date +%H:%M:%S)
fecha_actual=$(date +%d%m%Y)
log_file="$working_log/$fecha_actual.log"
backup_file="$working/$host_remoto$fecha_actual.gz"

# ==================== FUNCIONES AUXILIARES ====================
# Función para enviar un correo de alerta
send_email() {
    local subject="$1"
    local body="$2"
    echo -e "Subject:$subject\n$body" | msmtp -a default -t "$mail_to"
    echo "[$timestamp_log] Correo de alerta enviado al administrador."
}

# ==================== LÓGICA DEL SCRIPT ====================
echo "$timestamp_log Iniciando el script de backup de $host_remoto."
mkdir -p "$working_log" # Asegura que el directorio de logs existe

# Redirigir la salida estándar y de error al archivo de log
exec >> "$log_file" 2>&1

echo "$timestamp_log Comprobando conexión de red a $host_remoto..."
if ! ping -c 4 "$ip_remota" > /dev/null; then
    echo "$timestamp_log ERROR: Fallo de ping a $host_remoto. El backup no se pudo realizar."
    send_email "Fallo de conexión de red $host_remoto" "$host_remoto no responde a ping. El backup no se ha podido realizar."
    exit 1
fi
echo "$timestamp_log Ping a $host_remoto OK."

echo "$timestamp_log Comienza el backup de $host_remoto."
# Usamos 'pipefail' para que el script falle si alguna parte del pipe falla
set -o pipefail
if ! ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=2 "$usuario@$ip_remota" "sudo dd if=$origen bs=1M status=progress | gzip -" | dd of="$backup_file"; then
    echo "$timestamp_log ERROR: Fallo en la copia del backup."
    send_email "Fallo en el backup de $host_remoto" "La copia remota de $host_remoto ha fallado."
    exit 1
fi
set +o pipefail # Desactivamos pipefail

echo "$timestamp_log Verificando la integridad del backup de $host_remoto..."
if ! gzip -t "$backup_file"; then
    echo "$timestamp_log ERROR: Fallo en la verificación de integridad del backup de $host_remoto."
    send_email "Fallo de integridad del backup de $host_remoto" "La verificación del archivo de backup '$backup_file' ha fallado."
    exit 1
fi

echo "$timestamp_log Backup finalizado y verificado correctamente de $host_remoto."
echo "$timestamp_log Borrando backups y logs antiguos (+7 días) de $host_remoto ..."

# Borrar backups antiguos (más de 7 días)
find "$working" -maxdepth 1 -name "*.gz" -type f -ctime +7 -delete
# Borrar logs antiguos (más de 7 días)
find "$working_log" -maxdepth 1 -name "*.log" -type f -ctime +7 -delete

echo "$timestamp_log Fin del script de backup de $host_remoto. Ejecución correcta."

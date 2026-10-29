#!/bin/bash

###############################################################################
# Script: remote_backup_opnsense.sh                                           #
# Date: 27/06/2025                                                            #
# Description:: Backup remoto Raspberry OpnSense                              #
# Author: jaimealberto.io                                                     #
# Requirements: Api key                                                       #
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
# password <passord de la cuenta que envia el correo>                         #
# logfile ~/.msmtp.log                                                        #
# We give the necessary permissions to the configuration file                 #
# chmod 600 .msmtprc                                                          #
# Checks: ping, send mail in case of failure                                  # 
# Alerts: ping failure mailing                                                # 
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
#!/bin/bash

# Configuracion
OPNSENSE_HOST="https://<ip o fqdn>"
REMOTE_IP="<ip execute ping>"
REMOTE_HOST="<alias or descprintion name>"
API_KEY="<your api key>"
API_SECRET="<your scretet key>"
DAY=$(date +%d%m%Y)
TIME_STAMP=$(date +%H:%M:%S)
PATH_FILE_BACKUP="<destination path file backup>"
PATH_FILE_LOG="<destionation path file log>"
OUTPUT_BACKUP_FILE="$REMOTE_HOST$DAY.xml"
OUTPUT_LOG_FILE="$REMOTE_HOST$DAY.log"
MAIL_TO="<mal destination alert failed>"

# Crear archivo de log
touch "$PATH_FILE_LOG$REMOTE_HOST$DAY.log"

# Ruta archivo de log
LOG_FILE="$PATH_FILE_LOG$REMOTE_HOST$DAY.log"

# Redirigir salida estándar y de error al log
exec >> "$LOG_FILE" 2>&1

echo "$TIME_STAMP Iniciando el script."

# Comprobar conectividad
ping -c 4 "$REMOTE_IP" > /dev/null

if [ $? -eq 0 ]; then
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Ping a $REMOTE_HOST ok."
    echo "$TIME_STAMP Comienza el backup de $REMOTE_HOST."

    # Realizar backup
    curl -s -X GET "${OPNSENSE_HOST}/api/backup/backup/download" \
        -u "${API_KEY}:${API_SECRET}" \
        --insecure \
        -o "${PATH_FILE_BACKUP}${OUTPUT_BACKUP_FILE}"

    if [ $? -eq 0 ]; then
        TIME_STAMP=$(date +%H:%M:%S)
        echo "$TIME_STAMP ✅ Configuración descargada correctamente de $REMOTE_HOST"
    else
        TIME_STAMP=$(date +%H:%M:%S)
        echo "$TIME_STAMP ❌ Error al descargar la configuración de $REMOTE_HOST"
    fi

    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Backup finalizado de $REMOTE_HOST."

    # Borrar backups antiguos
    echo "$TIME_STAMP Borrando backups antiguos de $REMOTE_HOST, +30 días."
    find "$PATH_FILE_BACKUP" -name "*.gz" -type f -ctime +30 -exec rm {} \;

    echo "$TIME_STAMP Borrando logs antiguos de $REMOTE_HOST, +30 días."
    find "$PATH_FILE_LOG" -name "*.log" -type f -ctime +30 -exec rm {} \;

    echo "$TIME_STAMP Fin del script, ejecución correcta."

else
    # El ping falló
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP ❌ Error al hacer ping a $REMOTE_IP. El backup de $REMOTE_HOST no se pudo realizar por falta de red."
    SUBJECT="Fallo conexion de red $REMOTE_HOST"
    BODY="$REMOTE_HOST no responde al ping. No se puede realizar el backup."
    echo -e "Subject:$SUBJECT\n$BODY" | msmtp -a default -t "$MAIL_TO"
    echo "$TIME_STAMP Correo enviado al administrador."
    echo "$TIME_STAMP Fin del script con errores."
    exit 1
fi

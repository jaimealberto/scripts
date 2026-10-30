#!/usr/bin/env bash
#===============================================================================
# Nombre:       backup_opnsense.sh
# Descripción:  Backup remoto de la configuración de OPNsense a través de su
#               API, con alerta por correo si el host no responde al ping.
# Autor:        JaimeAlberto · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, msmtp y una API key/secret de OPNsense.
# Uso:          ./backup_opnsense.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#
# Configuración de msmtp (fichero ~/.msmtprc):
#   account default
#   host smtp.gmail.com
#   port 587
#   from <correo_origen@gmail.com>
#   tls on
#   tls_starttls on
#   auth on
#   user <correo_origen@gmail.com>
#   password <contraseña de la cuenta que envía el correo>
#   logfile ~/.msmtp.log
#   Protege el fichero de configuración con: chmod 600 ~/.msmtprc
#===============================================================================

# Configuración
OPNSENSE_HOST="https://<ip o fqdn>"
REMOTE_IP="<ip a la que hacer ping>"
REMOTE_HOST="<alias o nombre descriptivo>"
API_KEY="<tu api key>"
API_SECRET="<tu api secret>"
DAY=$(date +%d%m%Y)
TIME_STAMP=$(date +%H:%M:%S)
PATH_FILE_BACKUP="<ruta destino del fichero de backup>"
PATH_FILE_LOG="<ruta destino del fichero de log>"
OUTPUT_BACKUP_FILE="$REMOTE_HOST$DAY.xml"
MAIL_TO="<correo destino de las alertas>"

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

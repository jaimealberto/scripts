#!/bin/bash
###############################################################################
# Script: remote_backup_rpi.sh                                                #
# Date: 27/06/2025                                                            #
# Description:: Backup remoto Raspberry Pi                                    #
# Author: jaimealberto.io                                                     #
# Requirements: Connection via ssh key without password. gzip msmtp           #
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
# Checks: ping, backup file integrity, send mail in case of failure           #
# Alerts: ping failure mailing or backup file integrity                       #
# crontab -e add line:                                                        #
# 00 1 * * * ~/scripts/remote_backup_rpi.sh >/dev/null 2>&1                   #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################

# Parameters of configuration
REMOTE_HOST="<hostname_descriptivo>"
REMOTE_IP="<ip_o_fqdn>"
USER="<user>"
CURRENT_DATE=$(date +%d%m%Y)
TIME_STAMP=$(date +%H:%M:%S)
SOURCE="/dev/mmcblk0"
WORKING="<destino_copia>"
WORKING_LOG="<destino_log>"
mail_to="destino_alerta@dominio.com"

# Creating log file
touch $WORKING_LOG$CURRENT_DATE.log

# Path of log file
LOG_FILE="$WORKING_LOG$CURRENT_DATE.log"

# Redirect standard and error output to log file
exec >> "$LOG_FILE" 2>&1

# Commands and script logic...
echo "$TIME_STAMP Iniciando el script."

# Check ping network connection
ping -c 4 $REMOTE_IP > /dev/null

# Verify the ping command output code
if [ $? -eq 0 ]; then
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Ping a $REMOTE_HOST ok."
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Comienza el backup."
    # Remote copy command using dd and SSH
    ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=2 $USER@$REMOTE_IP "sudo dd if=$SOURCE bs=1M status=progress | gzip -" | dd of=$WORKING$REMOTE_HOST$CURRENT_DATE.gz
        # Backup integrity verification
        gzip -t $WORKING$REMOTE_HOST$CURRENT_DATE.gz
        if [ $? -eq 0 ]; then
            TIME_STAMP=$(date +%H:%M:%S)
            echo "$TIME_STAMP Verificacion integridad backup ok."
        else
            TIME_STAMP=$(date +%H:%M:%S)
            echo "$TIME_STAMP Error verficacion backup, fallo en el backup."
            subject="Fallo verificacion backup $REMOTE_HOST"
            TIME_STAMP=$(date +%H:%M:%S)
            echo "$TIME_STAMP Enviando correo al administrador."
            body="La verificacion del backup de $REMOTE_HOST fallado."
            echo -e "Subject:$subject\n$body" | msmtp -a default -t $mail_to
            TIME_STAMP=$(date +%H:%M:%S)
            echo "$TIME_STAMP Fin del script."
            exit
        fi      
else
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Error al hacer ping a $REMOTE_IP . El backup de $REMOTE_HOST no se pudo realizar, sin conexion de red."
    subject="Fallo conexion de red $REMOTE_HOST"
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Enviando correo al administrador."
    body="$REMOTE_HOST no responde a ping, no se puede realizar el backup."
    echo -e "Subject:$subject\n$body" | msmtp -a default -t $mail_to
    TIME_STAMP=$(date +%H:%M:%S)
    echo "$TIME_STAMP Fin del script."
    exit
fi

TIME_STAMP=$(date +%H:%M:%S)
echo "$TIME_STAMP Backup finalizado correctamente."
TIME_STAMP=$(date +%H:%M:%S)
echo "$TIME_STAMP Borrando backups antiguos, +2 dias."
find $WORKING -name "*.gz" -type f -ctime +2 -exec rm {} \; 
echo "$TIME_STAMP Borrando logs antiguos, +2 dias."
find $WORKING_LOG -name "*.log" -type f -ctime +2 -exec rm {} \; 
echo "$TIME_STAMP Fin del script, ejecucion correcta."
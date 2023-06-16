#!/bin/bash

###############################################################################
# Script: remote_backup_rpi.sh                                                #
# Date: 16/06/2023                                                            #
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
# password <passord de la cuenta que envia el correo>                         #
# logfile ~/.msmtp.log                                                        #
# We give the necessary permissions to the configuration file                 #
# chmod 600 .msmtprc                                                          #
# Checks: ping, backkup file integrity, send mail in case of failure          # 
# Alerts: ping failure mailing or backkup file integrity                      # 
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################

# Parameters of configuration
host_remoto="<hostname_descriptivo>"
ip_remota="<ip_o_fqdn>"
usuario="<user>"
fecha_actual=$(date +%d%m%Y)
time_stamp=$(date +%H:%M:%S)
origen="/dev/mmcblk0"
working="<destino_copia>"
working_log="<destino_log>"
mail_to="destino_alerta@dominio.com"

# Creating log file
touch $working_log$fecha_actual.log

# Path of log file
log_file="$working_log$fecha_actual.log"

# Redirect standard and error output to log file
exec >> "$log_file" 2>&1

# Commands and script logic...
echo "$time_stamp Iniciando el script."

# Check ping network connection
ping -c 4 $ip_remota > /dev/null

# Verify the ping command output code
if [ $? -eq 0 ]; then
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Ping a $host_remoto ok."
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Comienza el backup."
    # Remote copy command using dd and SSH
    ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=2 $usuario@$ip_remota "sudo dd if=$origen bs=1M status=progress | gzip -" | dd of=$working$host_remoto$fecha_actual.gz
        # Backup integrity verification
        gzip -t $working$host_remoto$fecha_actual.gz
        if [ $? -eq 0 ]; then
            time_stamp=$(date +%H:%M:%S)
            echo "$time_stamp Verificacion integridad backup ok."
        else
            time_stamp=$(date +%H:%M:%S)
            echo "$time_stamp Error verficacion backup, fallo en el backup."
            subject="Fallo verificacion backup $host_remoto"
            time_stamp=$(date +%H:%M:%S)
            echo "$time_stamp Enviando correo al administrador."
            body="La verificacion del backup de $host_remoto fallado."
            echo -e "Subject:$subject\n$body" | msmtp -a default -t $mail_to
            time_stamp=$(date +%H:%M:%S)
            echo "$time_stamp Fin del script."
            exit
        fi      
else
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Error al hacer ping a $ip_remota . El backup de $host_remoto no se pudo realizar, sin conexion de red."
    subject="Fallo conexion de red $host_remoto"
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Enviando correo al administrador."
    body="$host_remoto no responde a ping, no se puede realizar el backup."
    echo -e "Subject:$subject\n$body" | msmtp -a default -t $mail_to
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Fin del script."
    exit
fi

time_stamp=$(date +%H:%M:%S)
echo "$time_stamp Backup finalizado correctamente."
time_stamp=$(date +%H:%M:%S)
echo "$time_stamp Borrando backups antiguos, +2 dias."
find $working -name "*.gz" -type f -ctime +2 -exec rm {} \; 
echo "$time_stamp Borrando logs antiguos, +2 dias."
find $working_log -name "*.log" -type f -ctime +2 -exec rm {} \; 
echo "$time_stamp Fin del script, ejecucion correcta."
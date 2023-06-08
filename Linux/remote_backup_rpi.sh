#!/bin/bash

###############################################################################
# Script: remote_backup_rpi.sh                                                #
# Fecha: 05/06/2023                                                           #
# Descripción: Backup remoto Raspberry Pi                                     #
# Autor: jaimealberto.io                                                      #
# Requimientos: Conexion mediante llave ssh sin password gzip msmtp           #
# Configuracion msmtp                                                         #
# creacion del fichero .msmtprc                                               #
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
# Damos los permisos necesarios al fichero de configuracion                   #
# chmod 600 .msmtprc                                                          #
# Checks: ping, integridad fichero backkup, envio correo caso de fallo        # 
# Alertas: envio correo fallo ping o integridad fichero backkup               # 
# Licencia CC BY-NC-SA 4.0                                                    #
###############################################################################

# Parametros de configuracion
host_remoto="<hostname_descriptivo>"
ip_remota="<ip_o_fqdn>"
usuario="<user>"
fecha_actual=$(date +%d%m%Y)
time_stamp=$(date +%H:%M:%S)
origen="/dev/mmcblk0"
working="<destino_copia>"
working_log="<destino_log>"
mail_to="destino_alerta@dominio.com"

# Creando archivo de log
touch $working_log$fecha_actual.log

# Ruta del archivo de log
log_file="$working_log$fecha_actual.log"

# Redirigir la salida estándar y de error al archivo de log
exec >> "$log_file" 2>&1

# Comandos y lógica del script...
echo "$time_stamp Iniciando el script."

# Check conexion de red ping
ping -c 4 $ip_remota > /dev/null

# Verificar el código de salida del comando ping
if [ $? -eq 0 ]; then
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Ping a $host_remoto ok."
    time_stamp=$(date +%H:%M:%S)
    echo "$time_stamp Comienza el backup."
    # Comando de copia remota usando dd y SSH
    ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=2 $usuario@$ip_remota "sudo dd if=$origen bs=1M status=progress | gzip -" | dd of=$working$host_remoto$fecha_actual.gz
        # Verificacion integridad del backup
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
find $working -name "*.gz" -type f -mtime +2 -exec rm {} \; 
echo "$time_stamp Borrando logs antiguos, +2 dias."
find $working_log -name "*.log" -type f -mtime +2 -exec rm {} \; 
echo "$time_stamp Fin del script, ejecucion correcta."

: '
-mtime n: Encuentra archivos modificados hace "n" días.
-ctime n: Encuentra archivos cuyo estado fue cambiado hace "n" días.
-atime n: Encuentra archivos accedidos por última vez hace "n" días.
-newer file: Encuentra archivos más nuevos que "file". 
-mmin n: Encuentra archivos modificados hace "n" minutos.
-amin n: Encuentra archivos accedidos por última vez hace "n" minutos.
'

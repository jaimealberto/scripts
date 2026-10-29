#!/bin/bash

###############################################################################
# Script: ping_notify.sh                                                      #
# Date: 16/06/2023                                                            #
# Description:: Ping host list and notify desktop                             #
# Author: jaimealberto.io                                                     #
# Requirements: libnotify-bin                                                 #
# Checks: ping                                                                # 
# Alerts: send mesage notify-send                                             # 
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################

# Parameters of configuration
# Hosts list
archivo_hosts="hosts.lst"

while IFS= read -r host
do
  echo "Realizando ping a $host..."
  
  # Ejecutar el comando ping y capturar la salida
  if ping -c 4 "$host" &> /dev/null; then
    # Si el ping es ok
    echo "Ping a $host ok"
    notify-send -t 30000 -a " Ping ok" " Ping a $host ok"
    
  else
    # Si el ping ko
    echo "Ping a $host ko"
    notify-send -u critical -a " Ping ko" " Ping a $host ko"
    
  fi
  
  echo # Espacio en blanco para separar cada resultado de ping
  
done < "$archivo_hosts"

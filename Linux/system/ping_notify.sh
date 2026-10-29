#!/usr/bin/env bash
#===============================================================================
# Nombre:       ping_notify.sh
# Descripción:  Monitoriza por ping una lista de hosts (hosts.lst) y avisa en
#               el escritorio mediante notify-send según el resultado.
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   iputils-ping y libnotify-bin (notify-send).
# Uso:          ./ping_notify.sh
# Nota:         Define los hosts en 'hosts.lst' (ver hosts.lst.example). Se
#               ignoran las líneas vacías y las que empiezan por '#'.
#===============================================================================

# Lista de hosts (un host por línea; ver hosts.lst.example)
archivo_hosts="hosts.lst"

while IFS= read -r host
do
  # Ignorar líneas vacías y comentarios (#)
  [[ "$host" =~ ^[[:space:]]*(#.*)?$ ]] && continue

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

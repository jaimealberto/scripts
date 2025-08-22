#!/bin/bash
###############################################################################
# Script: zt_host_ipstatus.sh                                                 #
# Date: 22/08/2025                                                            #
# Description:: Muestra información de hosts ip y staus  de ZeroTier          #
# Author: jaimealberto.io                                                     #
# Requirements: jq API Token ZeroTier.                                        #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################

# 👉 Token de API de ZeroTier (genera uno en https://my.zerotier.com/account)
TOKEN="<TU_API_TOKEN>"

API_URL="https://my.zerotier.com/api"

# Obtener todas las redes con ID y nombre
NETWORKS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network" | jq -r '.[] | "\(.id) \(.config.name // "SinNombre")"')

if [ -z "$NETWORKS" ]; then
  echo "❌ No se encontraron redes o el token no es válido"
  exit 1
fi

while read -r NET NETNAME; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐 Red: $NET  🏷️  Nombre: $NETNAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  MEMBERS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network/$NET/member")

  if ! echo "$MEMBERS" | jq empty >/dev/null 2>&1; then
    echo "❌ Error: no se pudo obtener miembros de la red $NET"
    echo "$MEMBERS"
    continue
  fi

  # Obtener rango de DHCP de la red (opcional para diferenciar fija/DHCP)
  DHCP_RANGES=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network/$NET" | jq -r '.config.ipAssignmentPools[]? | "\(.ipRangeStart)-\(.ipRangeEnd)"')

  echo "$MEMBERS" | jq -r '
    .[] | [
      (.config.ipAssignments[0] // "-"),
      (.description // "-"),
      (if .config.authorized then "✅ Autorizado" else "⏳ Pendiente" end),
      (if .config.ipAssignments[0] != null then "Fija" else "DHCP" end)
    ] | @tsv
  ' | column -t -s $'\t' -N "IP,Descripción,Estado,Tipo"
  echo
done <<< "$NETWORKS"

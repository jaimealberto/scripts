#!/usr/bin/env bash
###############################################################################
# Script: zt_host_status.sh                                                   #
# Date: 22/08/2025                                                            #
# Description:: Muestra información de estado de los hosts  ZeroTier          #
# Author: jaimealberto.io                                                     #
# Requirements: jq API Token ZeroTier.                                        #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
# 👉 Tu token de ZeroTier
TOKEN="<TU_API_TOKEN>"

# Colores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Obtener todas las redes de la cuenta
NETWORKS_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://my.zerotier.com/api/network")

# Revisar si hay redes
if [[ "$NETWORKS_JSON" == "[]" ]]; then
  echo -e "${YELLOW}⚠️  No hay redes en esta cuenta.${NC}"
  exit 0
fi

# Recorrer cada red
echo "$NETWORKS_JSON" | jq -c '.[]' | while read -r NETWORK; do
  NETWORK_ID=$(echo "$NETWORK" | jq -r '.id')
  RED_NAME=$(echo "$NETWORK" | jq -r '.name // .config.name // "Desconocida"')

  MEMBERS_JSON=$(curl -s -s -H "Authorization: Bearer $TOKEN" \
    "https://my.zerotier.com/api/network/$NETWORK_ID/member")

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e " Red: ${YELLOW}$RED_NAME${NC}"
  echo -e " ID:  ${GREEN}$NETWORK_ID${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if [[ "$MEMBERS_JSON" == "[]" ]]; then
    echo -e "${YELLOW}⚠️  No hay miembros en esta red.${NC}"
    continue
  fi

  # Encabezados de tabla
  printf "%-18s %-30s %-10s %-12s\n" \
    "ipAssignments" "description" "authorized" "status"

  NOW_EPOCH=$(date +%s)

  echo "$MEMBERS_JSON" | jq -r '.[] | [
    (.config.ipAssignments | join(",")),
    (.description // "-"),
    (.lastSeen // 0 | tostring),
    (.config.authorized // false)
  ] | @tsv' | \
  awk -F'\t' -v NOW_EPOCH="$NOW_EPOCH" '
  {
    # Convertir IP a número para ordenar
    split($1,a,",");
    split(a[1],b,".");
    ipnum=b[1]*256^3+b[2]*256^2+b[3]*256+b[4];

    # Autorizado y Status (solo texto)
    auth_txt=($4=="true")?"✅":"❌";
    last_epoch=$3/1000;
    diff=NOW_EPOCH-last_epoch;
    if (diff <= 300) {
      status_txt="Online";
    } else if (diff <= 3600) {
      status_txt="Inactivo";
    } else {
      status_txt="Offline";
    }

    # Imprimir la línea con los campos de texto
    printf "%s\t%s\t%s\t%s\t%s\n", ipnum, $1, $2, auth_txt, status_txt;
  }' | sort -n | cut -f2- | \
  while IFS=$'\t' read -r ip desc auth status; do
    # Aplicar colores y formato al final
    auth_color_code=;
    if [[ "$auth" == "✅" ]]; then
      auth_color_code=$GREEN;
    else
      auth_color_code=$RED;
    fi

    status_color_code=;
    if [[ "$status" == "Online" ]]; then
      status_color_code=$GREEN;
    elif [[ "$status" == "Inactivo" ]]; then
      status_color_code=$YELLOW;
    else
      status_color_code=$RED;
    fi

    printf "%-18s %-30s ${auth_color_code}%-10s${NC} ${status_color_code}%-12s${NC}\n" \
      "$ip" "$desc" "$auth" "$status"
  done

done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

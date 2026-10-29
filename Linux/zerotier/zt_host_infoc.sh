#!/usr/bin/env bash
###############################################################################
# Script: zt_host_infoc.sh                                                    #
# Date: 22/08/2025                                                            #
# Description:: Muestra información de los hosts con colores                  #
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
  printf "%-15s %-12s %-25s %-19s %-17s %-12s %-19s %-10s %-12s\n" \
    "ipAssignments" "nodeId" "description" "lastSeen" "physicalAddress" "clientVersion" "clock" "authorized" "status"

  NOW_EPOCH=$(date +%s)

  echo "$MEMBERS_JSON" | jq -r '.[] | [
    (.config.ipAssignments | join(",")),
    (.nodeId // "-"),
    (.description // "-"),
    (.lastSeen // 0 | tostring),
    (.physicalAddress // "-"),
    (.clientVersion // "-"),
    (.clock // 0 | tostring),
    (.config.authorized // false),
    (.config.active // false)
  ] | @tsv' | \
  awk -F'\t' -v RED="$RED" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v NC="$NC" -v NOW_EPOCH="$NOW_EPOCH" '{
    # Convertir IP a número para ordenar
    split($1,a,",");
    split(a[1],b,"."); ipnum=b[1]*256^3+b[2]*256^2+b[3]*256+b[4];

    # Fechas legibles
    last=strftime("%Y-%m-%d %H:%M:%S", $4/1000);
    clock=strftime("%Y-%m-%d %H:%M:%S", $7/1000);

    # Autorizado
    auth=($8=="true")?GREEN"✅"NC:RED"❌"NC;

    # Calcular estado (lastSeen vs NOW)
    last_epoch=$4/1000;
    diff=NOW_EPOCH-last_epoch;
    if (diff <= 300) {
      status=GREEN"Online"NC;
    } else if (diff <= 3600) {
      status=YELLOW"Inactivo"NC;
    } else {
      status=RED"Offline"NC;
    }

    # Imprimir fila alineada
    printf "%-15s %-12s %-25s %-19s %-17s %-12s %-19s %-10s %-12s\n", \
      $1,$2,$3,last,$5,$6,clock,auth,status
  }' | sort -k1,1n

done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_host_info.sh
# Descripción:  Muestra información de los hosts y redes de la cuenta ZeroTier.
# Autor:        JaimeAlberto · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq, awk y un token de API de ZeroTier.
# Uso:          ./zt_host_info.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 👉 Pon aquí tu token
TOKEN="<TU_API_TOKEN>"

# Función para convertir epoch a fecha legible
epoch_to_date() {
  date -d @"$1" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "-"
}

# Obtener todas las redes de la cuenta
NETWORKS_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://my.zerotier.com/api/network")

# Revisar si hay redes
if [[ "$NETWORKS_JSON" == "[]" ]]; then
  echo "No hay redes en esta cuenta."
  exit 0
fi

# Recorrer cada red
echo "$NETWORKS_JSON" | jq -c '.[]' | while read -r NETWORK; do
  NETWORK_ID=$(echo "$NETWORK" | jq -r '.id')
  RED_NAME=$(echo "$NETWORK" | jq -r '.name // .config.name // "Desconocida"')

  MEMBERS_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "https://my.zerotier.com/api/network/$NETWORK_ID/member")

  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "🌐 Red: $RED_NAME  ID: $NETWORK_ID"
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [[ "$MEMBERS_JSON" == "[]" ]]; then
    echo "No hay miembros en esta red."
    continue
  fi

  # Encabezados de la tabla
  printf "%-15s %-15s %-15s %-20s %-15s %-10s %-19s %-6s %-6s\n" \
    "IP" "ID" "Address" "LastSeen" "PhysicalAddr" "ClientVer" "Clock" "Auth" "Status"

  # Procesamiento de miembros
  echo "$MEMBERS_JSON" | jq -r '.[] | [
    (.config.ipAssignments | join(",")),
    .id,
    (.address // "-"),
    (.lastSeen // 0 | tostring),
    (.physicalAddress // "-"),
    (.clientVersion // "-"),
    (.clock // 0 | tostring),
    (.config.authorized // false),
    (.config.active // false)
  ] | @tsv' | \
  awk -F'\t' 'BEGIN {OFS="\t"} {
    split($1, a, ","); ipnum=a[1];
    $4=strftime("%Y-%m-%d %H:%M:%S", $4/1000);
    $7=strftime("%Y-%m-%d %H:%M:%S", $7/1000);
    auth=($8=="true")?"*":" ";
    active=($9=="true")?"*":" ";
    print ipnum, $1, $2, $3, $4, $5, $6, $7, auth, active;
  }' | sort -n | cut -f2- | column -t

done

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

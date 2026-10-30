#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_account_info.sh
# Descripción:  Muestra información general de la cuenta de ZeroTier (redes y
#               número de hosts en cada una).
# Autor:        JaimeAlberto · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq y un token de API de ZeroTier.
# Uso:          ./zt_account_info.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 👉 Token de API de ZeroTier (genera uno en https://my.zerotier.com/account)
TOKEN="<TU_API_TOKEN>"

API_URL="https://my.zerotier.com/api"

# Obtener redes
NETWORKS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network")

if ! echo "$NETWORKS" | jq empty >/dev/null 2>&1; then
  echo "❌ Error al obtener redes"
  echo "$NETWORKS"
  exit 1
fi

TOTAL_NETWORKS=$(echo "$NETWORKS" | jq length)
echo "🌐 Número de redes: $TOTAL_NETWORKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_HOSTS=0

# Recorremos redes
for row in $(echo "$NETWORKS" | jq -r '.[] | @base64'); do
  _jq() {
    echo "$row" | base64 --decode | jq -r "$1"
  }

  NET_ID=$(_jq '.id')
  NET_NAME=$(_jq '.config.name')
  [ "$NET_NAME" == "null" ] && NET_NAME="(sin nombre)"

  # Obtener miembros de la red
  MEMBERS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network/$NET_ID/member")
  NUM_MEMBERS=$(echo "$MEMBERS" | jq length)

  echo "🆔 Red: $NET_ID"
  echo "   📌 Nombre: $NET_NAME"
  echo "   👥 Hosts: $NUM_MEMBERS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  TOTAL_HOSTS=$((TOTAL_HOSTS + NUM_MEMBERS))
done

echo "📊 Total de hosts en todas las redes: $TOTAL_HOSTS"

# Información de la cuenta
ACCOUNT=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/account")

if echo "$ACCOUNT" | jq -e '.type' >/dev/null 2>&1; then
  PLAN=$(echo "$ACCOUNT" | jq -r '.type')
  echo "💳 Tipo de cuenta: $PLAN"
else
  echo "⚠️ No se pudo obtener el tipo de cuenta"
fi

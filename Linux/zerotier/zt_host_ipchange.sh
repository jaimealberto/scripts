#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_host_ipchange.sh
# Descripción:  Cambia la IP asignada a un host dentro de una red ZeroTier.
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq y un token de API de ZeroTier.
# Uso:          ./zt_host_ipchange.sh <NETWORK_ID> <MEMBER_ID> <NUEVA_IP>
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 👉 Token de API de ZeroTier (genera uno en https://my.zerotier.com/account)
TOKEN="<TU_API_TOKEN>"

API_URL="https://my.zerotier.com/api"

NETWORK_ID="$1"
MEMBER_ID="$2"
NEW_IP="$3"

if [ -z "$NETWORK_ID" ] || [ -z "$MEMBER_ID" ] || [ -z "$NEW_IP" ]; then
  echo "Uso: $0 <network_id> <member_id> <nueva_ip>"
  exit 1
fi

# Ejecutar actualización de IP
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"config\": {\"ipAssignments\": [\"$NEW_IP\"]}}" \
  "$API_URL/network/$NETWORK_ID/member/$MEMBER_ID")

# Verificar si fue exitoso
if echo "$RESPONSE" | jq -e '.id' >/dev/null 2>&1; then
  echo "✅ IP cambiada correctamente"
  echo "📌 Host: $MEMBER_ID"
  echo "🌐 Red: $NETWORK_ID"
  echo "🔑 Nueva IP: $NEW_IP"
else
  echo "❌ Error al cambiar la IP"
  echo "Respuesta API: $RESPONSE"
fi

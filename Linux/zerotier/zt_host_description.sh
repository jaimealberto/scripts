#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_host_description.sh
# Descripción:  Cambia la descripción de un host (miembro) en una red ZeroTier.
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq y un token de API de ZeroTier.
# Uso:          ./zt_host_description.sh <NETWORK_ID> <MEMBER_ID> "<NUEVA_DESCRIPCION>"
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 🔑 API Token (puede estar en variable de entorno ZT_API_TOKEN)
API_TOKEN="${ZT_API_TOKEN:-<TU_API_TOKEN>}"

# Parámetros
NETWORK_ID="$1"
MEMBER_ID="$2"
NEW_DESCRIPTION="$3"

# Validación
if [[ -z "$NETWORK_ID" || -z "$MEMBER_ID" || -z "$NEW_DESCRIPTION" ]]; then
  echo "❌ Uso: $0 <NETWORK_ID> <MEMBER_ID> \"<NUEVA_DESCRIPCION>\""
  exit 1
fi

# Petición a la API
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "https://api.zerotier.com/api/v1/network/${NETWORK_ID}/member/${MEMBER_ID}" \
  -H "Authorization: bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"description\":\"${NEW_DESCRIPTION}\"}")

# Separar cuerpo y código HTTP
BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

# Evaluar respuesta
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✅ Descripción actualizada correctamente"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$BODY" | jq '{id, address, description, authorized}'
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "❌ Error al actualizar descripción (HTTP $HTTP_CODE)"
  echo "Respuesta: $BODY"
fi

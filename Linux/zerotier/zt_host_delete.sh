#!/usr/bin/env bash
#
# Script para borrar (eliminar) un host/miembro de una red ZeroTier
# Uso: ./zt_delete_host.sh <NETWORK_ID> <MEMBER_ID>
#

# 🔑 API Token (pon aquí tu API token o usa variable de entorno)
API_TOKEN="${ZT_API_TOKEN:-<TU_API_TOKEN>}"

# Parámetros
NETWORK_ID="$1"
MEMBER_ID="$2"

# Validación
if [[ -z "$NETWORK_ID" || -z "$MEMBER_ID" ]]; then
  echo "❌ Uso: $0 <NETWORK_ID> <MEMBER_ID>"
  exit 1
fi

# Petición DELETE a la API
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X DELETE "https://api.zerotier.com/api/v1/network/${NETWORK_ID}/member/${MEMBER_ID}" \
  -H "Authorization: bearer ${API_TOKEN}" \
  -H "Content-Type: application/json")

# Evaluar respuesta
if [[ "$RESPONSE" == "200" || "$RESPONSE" == "204" ]]; then
  echo "✅ Host eliminado correctamente de la red $NETWORK_ID"
else
  echo "❌ Error al eliminar el host (HTTP $RESPONSE)"
fi

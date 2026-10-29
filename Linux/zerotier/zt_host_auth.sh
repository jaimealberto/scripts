#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_host_auth.sh
# Descripción:  Lista los miembros de una red ZeroTier y autoriza o desautoriza
#               hosts (uno, varios o todos los pendientes).
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq y un token de API de ZeroTier.
# Uso:          ./zt_host_auth.sh {list|authorize|unauthorize} <NETWORK_ID> [MEMBER]
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 👉 Token de API de ZeroTier (genera uno en https://my.zerotier.com/account)
TOKEN="<TU_API_TOKEN>"

API_URL="https://my.zerotier.com/api"

usage() {
  echo "Uso:"
  echo "  $0 list <NETWORK_ID>                 # Listar miembros de la red"
  echo "  $0 authorize <NETWORK_ID> <MEMBER>   # Autorizar un miembro"
  echo "  $0 authorize --all <NETWORK_ID>      # Autorizar a todos los pendientes"
  echo "  $0 unauthorize <NETWORK_ID> <MEMBER> # Desautorizar un miembro"
  exit 1
}

list_members() {
  NETWORK_ID="$1"
  curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network/$NETWORK_ID/member" | \
  jq -r '.[] | [.nodeId,
                 (.name // "-"),
                 (.description // "-"),
                 (if .config.authorized then "✅ Autorizado" else "⏳ Pendiente" end),
                 (.config.ipAssignments | join(","))]
                 | @tsv' | \
  column -t -s $'\t' -N "ID,Nombre,Descripción,Estado,IPs"
}

authorize_member() {
  NETWORK_ID="$1"
  MEMBER_ID="$2"

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"config":{"authorized":true}}' \
    "$API_URL/network/$NETWORK_ID/member/$MEMBER_ID")

  AUTHORIZED=$(echo "$RESPONSE" | jq -r '.config.authorized // empty')

  if [[ "$AUTHORIZED" == "true" ]]; then
    echo "✅ Miembro $MEMBER_ID autorizado en la red $NETWORK_ID"
  else
    echo "❌ Error al autorizar miembro $MEMBER_ID"
    echo "$RESPONSE"
  fi
}

unauthorize_member() {
  NETWORK_ID="$1"
  MEMBER_ID="$2"

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"config":{"authorized":false}}' \
    "$API_URL/network/$NETWORK_ID/member/$MEMBER_ID")

  AUTHORIZED=$(echo "$RESPONSE" | jq -r '.config.authorized // empty')

  if [[ "$AUTHORIZED" == "false" ]]; then
    echo "🛑 Miembro $MEMBER_ID desautorizado en la red $NETWORK_ID"
  else
    echo "❌ Error al desautorizar miembro $MEMBER_ID"
    echo "$RESPONSE"
  fi
}

authorize_all() {
  NETWORK_ID="$1"
  MEMBERS=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network/$NETWORK_ID/member" | \
            jq -r '.[] | select(.config.authorized==false) | .nodeId')

  if [[ -z "$MEMBERS" ]]; then
    echo "ℹ️ No hay miembros pendientes en la red $NETWORK_ID"
    exit 0
  fi

  for M in $MEMBERS; do
    authorize_member "$NETWORK_ID" "$M"
  done
}

# ================================
# Main
# ================================

CMD="$1"
shift || true

case "$CMD" in
  list)
    [[ -z "$1" ]] && usage
    list_members "$1"
    ;;
  authorize)
    if [[ "$1" == "--all" ]]; then
      [[ -z "$2" ]] && usage
      authorize_all "$2"
    else
      [[ -z "$1" || -z "$2" ]] && usage
      authorize_member "$1" "$2"
    fi
    ;;
  unauthorize)
    [[ -z "$1" || -z "$2" ]] && usage
    unauthorize_member "$1" "$2"
    ;;
  *)
    usage
    ;;
esac

#!/usr/bin/env bash
#===============================================================================
# Nombre:       zt_token_test.sh
# Descripción:  Prueba el token de API de ZeroTier listando las redes de la
#               cuenta.
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, jq y un token de API de ZeroTier.
# Uso:          ./zt_token_test.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================

# 👉 Token de API de ZeroTier (genera uno en https://my.zerotier.com/account)
TOKEN="<TU_API_TOKEN>"

API_URL="https://my.zerotier.com/api"

# Obtener redes
NETS_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" "$API_URL/network")

# Verificar si es JSON válido
if ! echo "$NETS_JSON" | jq . >/dev/null 2>&1; then
    echo "❌ Error al obtener redes. Respuesta fue:"
    echo "$NETS_JSON"
    exit 1
fi

# Formatear salida
printf "%-20s %-18s %-10s %-10s %-10s\n" "Nombre" "ID" "Tipo" "Status" "Miembros"
echo "--------------------------------------------------------------------------------"

echo "$NETS_JSON" | jq -r '.[] | "\(.config.name) \t\(.id) \t\(.config.private) \t\(.status) \t\(.totalMemberCount)"' |
while IFS=$'\t' read -r name id private status members; do
    tipo=$([ "$private" = "true" ] && echo "Privada" || echo "Pública")
    printf "%-20s %-18s %-10s %-10s %-10s\n" "$name" "$id" "$tipo" "$status" "$members"
done
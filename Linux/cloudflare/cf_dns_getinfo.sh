#!/bin/bash
###############################################################################
# Script: cf_dns_getinfo.sh                                                   #
# Date: 20/08/2025                                                            #
# Description:: Consulta de tus dominios y subdominios indicando las zonas    #
# Author: jaimealberto.io                                                     #
# Requirements: jq API Token CloudFlare read.                                 #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
# --- CONFIGURACIÓN ---
CF_API_TOKEN="<TU_API_TOKEN>"   # Reemplaza con tu API Token de Cloudflare
LOG_DIR=~/cloudflare/logs
LOG_FILE="${LOG_DIR}/cloudflare-list-$(date +%Y-%m).log"
mkdir -p "${LOG_DIR}"

# --- FUNCIÓN DE LOG ---
log() {
  echo "$(date '+%b %d %H:%M:%S') [INFO] $1" | tee -a "${LOG_FILE}"
}

# --- OBTENER TODAS LAS ZONAS ---
log "Obteniendo lista de zonas..."
ZONES=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?per_page=50" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json")

# Validación
if ! echo "$ZONES" | jq -e '.success' | grep -q true; then
  log "Error al obtener zonas. Verifica tu token."
  exit 1
fi

# --- RECORRER CADA ZONA ---
echo "" | tee -a "${LOG_FILE}"
for row in $(echo "${ZONES}" | jq -r '.result[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
  }
  
  ZONE_ID=$(_jq '.id')
  ZONE_NAME=$(_jq '.name')

  log "Procesando zona: ${ZONE_NAME} (${ZONE_ID})"

  # Obtener registros DNS de la zona
  DNS_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?per_page=500" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json")

  if ! echo "$DNS_RECORDS" | jq -e '.success' | grep -q true; then
    log "Error al obtener registros de la zona ${ZONE_NAME}"
    continue
  fi

  # Listar registros con zona
  echo "$DNS_RECORDS" | jq -r --arg ZONE_NAME "$ZONE_NAME" \
    '.result[] | " - Zona: " + $ZONE_NAME + " | \(.name) [\(.type)] → \(.content)"' | tee -a "${LOG_FILE}"

  echo "" | tee -a "${LOG_FILE}"
done

log "Fin de la ejecución."


##########################################################################################################################################
# Por terminal copiar y pegar con tu api token.
# Opción 1
#curl -s -X GET "https://api.cloudflare.com/client/v4/zones/3a25cb4407a5adc525b89f94c88760cb/dns_records" \
#     -H "Authorization: Bearer <TU_API_TOKEN>" \
#     -H "Content-Type: application/json" | jq -r '.result[] | "\(.name) → \(.content) [\(.type)]"'
# Opción 2
#for zone in $(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?per_page=50" \
#    -H "Authorization: Bearer <TU_API_TOKEN>" \
#    -H "Content-Type: application/json" | jq -r 'select(.success==true) | .result[]? | "\(.id):\(.name)"'); do
#  
#  ZONE_ID=$(echo $zone | cut -d: -f1)
#  ZONE_NAME=$(echo $zone | cut -d: -f2)
#
#  curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=500" \
#      -H "Authorization: Bearer <TU_API_TOKEN>" \
#      -H "Content-Type: application/json" \
#    | jq -r --arg ZONE_NAME "$ZONE_NAME" 'select(.success==true) | .result[]? | "\($ZONE_NAME) | \(.name) → \(.content) [\(.type)]"'
#done
# Opción 3
#for zone in $(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?per_page=50" \
#    -H "Authorization: Bearer <TU_API_TOKEN>" \
#    -H "Content-Type: application/json" | jq -r 'select(.success==true) | .result[]? | "\(.id):\(.name)"'); do
#  
#  ZONE_ID=$(echo $zone | cut -d: -f1)
#  ZONE_NAME=$(echo $zone | cut -d: -f2)
#
#  curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=500" \
#      -H "Authorization: Bearer <TU_API_TOKEN>" \
#      -H "Content-Type: application/json" \
#    | jq -r --arg ZONE_NAME "$ZONE_NAME" --arg ZONE_ID "$ZONE_ID" \
#      'select(.success==true) | .result[]? | "Zone: \($ZONE_NAME) (\($ZONE_ID)) | \(.name) → \(.content) [\(.type)]"'
#done
#----------------------------------------------------------------------------------------------------------------
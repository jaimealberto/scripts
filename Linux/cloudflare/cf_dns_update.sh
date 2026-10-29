#!/bin/bash
##############################################################################
# Script: cf_dns_update.sh                                                   #
# Date: 20/08/2025                                                           #
# Description:: Actualizar un dominio o varios subdominios en CloudFlare     #
# Author: jaimealberto.io                                                    #
# Requirements: jq API Token CloudFlare read.                                #
# License: CC BY-NC-SA 4.0                                                   #
##############################################################################
set -e
# --- CONFIGURACIÓN ---
CF_API_TOKEN="<TU_API_TOKEN>"
CF_ZONE_ID="<TU_ZONE_ID>"

DOMAINS=(
  "subdominio.midominio.com"
  "midomiio.com"
)

# Logs
LOG_DIR=~/cloudflare/logs
LOG_FILE="${LOG_DIR}/cloudflare-$(date +%Y-%m).log"
SCRIPT_NAME=$(basename "$0")
SCRIPT_PID=$$
HOSTNAME=$(hostname)
mkdir -p "${LOG_DIR}"

# --- FUNCIONES ---
log_message() {
  local severity="$1"
  local message="$2"
  echo "$(date '+%b %d %H:%M:%S') ${HOSTNAME} ${SCRIPT_NAME}[${SCRIPT_PID}]: [${severity}] ${message}" | tee -a "${LOG_FILE}"
}

get_record_id() {
  local domain="$1"
  curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records?type=A&name=${domain}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" | jq -r '.result[0].id'
}

update_record() {
  local domain="$1"
  local record_id="$2"
  local ip="$3"

  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${record_id}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${domain}\",\"content\":\"${ip}\",\"ttl\":120,\"proxied\":false}"
}

# --- EJECUCIÓN ---
log_message "NOTICE" "Iniciando actualización de IP dinámica en Cloudflare."

CURRENT_IP=$(curl -s https://ipv4.icanhazip.com)

for DOMAIN in "${DOMAINS[@]}"; do
  log_message "INFO" "Procesando dominio: ${DOMAIN}"

  RECORD_ID=$(get_record_id "${DOMAIN}")
  if [ "${RECORD_ID}" == "null" ] || [ -z "${RECORD_ID}" ]; then
    log_message "ERROR" "No se encontró el registro A para '${DOMAIN}'."
    continue
  fi

  RESPONSE=$(update_record "${DOMAIN}" "${RECORD_ID}" "${CURRENT_IP}")

  if echo "${RESPONSE}" | grep -q '"success":true'; then
    log_message "INFO" "Actualización exitosa para '${DOMAIN}' a IP '${CURRENT_IP}'."
  else
    log_message "ERROR" "Fallo en la actualización de '${DOMAIN}'. Respuesta: ${RESPONSE}"
  fi
done

log_message "NOTICE" "Fin de la ejecución."

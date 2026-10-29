import os
import requests
import sys
###############################################################################
# Script: cf_subdomain_create.py                                              #
# Date: 21/08/2025                                                            #
# Description:: Creación de subdominios desde el terminal                     #
# Author: jaimealberto.io                                                     #
# Requirements: jq API Token CloudFlare read.                                 #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
# --- CONFIGURACIÓN ---
#
# Coloca aquí tu token de API de Cloudflare.
# Puedes obtenerlo desde el panel de Cloudflare en 'My Profile' > 'API Tokens'.
# Se recomienda usar un token con permisos limitados para mayor seguridad.
CLOUDFLARE_API_TOKEN = "<TU_API_TOKEN>"

# La dirección IP a la que apuntará el registro DNS tipo A
IP_ADDRESS = "1.2.3.4" 
# ---------------------

def get_zone_id(domain, headers):
    """
    Obtiene el ID de zona para un dominio dado.
    """
    url = f"https://api.cloudflare.com/client/v4/zones?name={domain}"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    result = response.json()
    if result["success"] and result["result"]:
        return result["result"][0]["id"]
    return None

def create_subdomain(zone_id, full_subdomain_name, headers):
    """
    Crea un registro DNS de tipo A para el subdominio.
    """
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    data = {
        "type": "A",
        "name": full_subdomain_name,
        "content": IP_ADDRESS,
        "ttl": 3600,
        "proxied": False
    }
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    result = response.json()
    return result

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python crear_subdominio.py <dominio_principal> <nombre_subdominio>")
        sys.exit(1)

    domain = sys.argv[1]
    subdomain_name = sys.argv[2]
    
    if CLOUDFLARE_API_TOKEN == "TU_TOKEN_DE_API_AQUI":
        print("Error: Por favor, reemplaza 'TU_TOKEN_DE_API_AQUI' en el script con tu token de Cloudflare.")
        sys.exit(1)

    headers = {
        "Authorization": f"Bearer {CLOUDFLARE_API_TOKEN}",
        "Content-Type": "application/json"
    }

    try:
        print(f"Buscando ID de zona para el dominio '{domain}'...")
        zone_id = get_zone_id(domain, headers)
        if not zone_id:
            print(f"Error: No se encontró el ID de zona para el dominio '{domain}'.")
            sys.exit(1)
        print(f"ID de zona encontrado: {zone_id}")

        full_subdomain = f"{subdomain_name}.{domain}"
        print(f"Creando subdominio '{full_subdomain}'...")
        result = create_subdomain(zone_id, full_subdomain, headers)
        
        if result["success"]:
            print("🎉 ¡Subdominio creado con éxito! 🎉")
            print(f"Registro DNS creado: {result['result']['name']} -> {result['result']['content']}")
        else:
            print("❌ Error al crear el subdominio.")
            print(result["errors"])

    except requests.exceptions.RequestException as e:
        print(f"Error de conexión con la API: {e}")
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
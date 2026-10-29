import requests
import sys

###############################################################################
# Script: delete_subdomain_cf.py                                              #
# Date: 26/08/2025                                                            #
# Description:: Eliminación de subdominios desde el terminal                  #
# Author: jaimealberto.io                                                     #
# Requirements: API Token CloudFlare con permisos de edición de DNS.          #
# License: CC BY-NC-SA 4.0                                                    #
###############################################################################
# --- CONFIGURACIÓN ---
#
# Coloca aquí tu token de API de Cloudflare.
# Puedes obtenerlo desde el panel de Cloudflare en 'My Profile' > 'API Tokens'.
# Asegúrate de que este token tenga permisos para editar registros DNS.
CLOUDFLARE_API_TOKEN = "<TU_API_TOKEN>"

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

def find_dns_record_id(zone_id, full_subdomain_name, headers):
    """
    Busca y obtiene el ID de un registro DNS por su nombre.
    """
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?name={full_subdomain_name}"
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    result = response.json()
    if result["success"] and result["result"]:
        # Cloudflare puede devolver múltiples registros si hay duplicados,
        # pero para simplificar, tomamos el primero.
        return result["result"][0]["id"]
    return None

def delete_dns_record(zone_id, record_id, headers):
    """
    Elimina un registro DNS usando su ID.
    """
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    response = requests.delete(url, headers=headers)
    response.raise_for_status()
    result = response.json()
    return result

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python delete_subdomain.py <dominio_principal> <nombre_subdominio>")
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
        print(f"Buscando el registro DNS para el subdominio '{full_subdomain}'...")
        record_id = find_dns_record_id(zone_id, full_subdomain, headers)
        
        if not record_id:
            print(f"❌ Error: No se encontró un registro DNS para '{full_subdomain}'.")
            sys.exit(1)
            
        print(f"Registro DNS encontrado con ID: {record_id}")
        print(f"Eliminando el subdominio '{full_subdomain}'...")
        result = delete_dns_record(zone_id, record_id, headers)
        
        if result["success"]:
            print("🎉 ¡Subdominio eliminado con éxito! 🎉")
        else:
            print("❌ Error al eliminar el subdominio.")
            print(result["errors"])

    except requests.exceptions.RequestException as e:
        print(f"Error de conexión con la API: {e}")
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
# ☁️ Cloudflare

Scripts para gestionar DNS en Cloudflare: DNS dinámico (DDNS) y alta/baja de
subdominios sobre dominios ya registrados.

Requisitos habituales: `curl` y `jq` (scripts en Bash), **Python 3** con
`requests` (scripts `.py`) y un **token de API de Cloudflare** con el permiso
adecuado (lectura para consultas, edición de DNS para cambios). Rellena el
marcador `<TU_API_TOKEN>` antes de usar cada script.

| Script | Descripción | Description |
|--------|-------------|-------------|
| `cf_dns_getinfo.sh` | Consulta tus dominios y zonas, y lista los registros DNS. | Lists your domains, zones and their DNS records. |
| `cf_dns_update.sh` | DNS dinámico (DDNS): actualiza el registro A con la IP pública actual. | Dynamic DNS (DDNS): updates the A record with the current public IP. |
| `cf_subdomain_create.py` | Crea un subdominio (registro A) en un dominio existente. | Creates a subdomain (A record) in an existing domain. |
| `cf_subdomain_delete.py` | Borra un subdominio de un dominio existente. | Deletes a subdomain from an existing domain. |

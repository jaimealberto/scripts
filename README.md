<!-- Language: Español | [English](README.en.md) -->

# 🛠️ scripts — Automatización de infraestructura

![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/shell-bash-121011?logo=gnu-bash&logoColor=white)
![Python](https://img.shields.io/badge/python-3-3776AB?logo=python&logoColor=white)
![PowerShell](https://img.shields.io/badge/powershell-5391FE?logo=powershell&logoColor=white)
[![ShellCheck](https://github.com/jaimealberto/scripts/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/jaimealberto/scripts/actions/workflows/shellcheck.yml)

> 🌐 **Idioma:** Español · [English version](README.en.md)

Colección de scripts de **administración de sistemas, redes y automatización** que uso
para gestionar mi propia infraestructura (hipervisores, NAS, Raspberry Pi, firewall
OPNsense y una malla ZeroTier). Cada script es autónomo, está documentado en su cabecera
y **no contiene credenciales**: los valores sensibles aparecen como marcadores
(`<TU_API_TOKEN>`) que debes rellenar antes de usarlos.

---

## 📁 Estructura

```
.
├── Linux/
│   ├── zerotier/     # Gestión de redes y hosts ZeroTier vía API
│   ├── cloudflare/   # DNS dinámico y gestión de registros en Cloudflare
│   ├── backup/       # Copias de seguridad remotas (OPNsense, Raspberry Pi)
│   └── system/       # Utilidades de sistema (altas de usuario, monitorización…)
└── Windows/
    └── Ansible/      # Preparación de Windows para ser gestionado con Ansible
```

| Área | Qué hay | Detalle |
|------|---------|---------|
| 🔗 **[Linux/zerotier](Linux/zerotier/)** | Instalación de ZeroTier y gestión completa de la cuenta, redes y miembros por API (alta/baja, autorización, IP, descripción, estado). | [README](Linux/zerotier/README.md) |
| ☁️ **[Linux/cloudflare](Linux/cloudflare/)** | DNS dinámico (DDNS) y alta/baja de subdominios sobre dominios ya registrados en Cloudflare. | [README](Linux/cloudflare/README.md) |
| 💾 **[Linux/backup](Linux/backup/)** | Copias de seguridad remotas con alerta por correo: configuración de OPNsense (API) y backups en caliente de Raspberry Pi. | [README](Linux/backup/README.md) |
| ⚙️ **[Linux/system](Linux/system/)** | Utilidades varias: alta de usuario para administración remota, instalación de herramientas y monitorización por ping. | [README](Linux/system/README.md) |
| 🪟 **[Windows/Ansible](Windows/Ansible/)** | Scripts PowerShell para habilitar WinRM y dejar un Windows listo para Ansible. | [README](Windows/Ansible/README.md) |

---

## 🚀 Uso

```bash
git clone git@github.com:jaimealberto/scripts.git
cd scripts/Linux/<área>
chmod +x <script>.sh
./<script>.sh
```

Antes de ejecutar cualquier script, **edita la sección de configuración** de su cabecera
y sustituye los marcadores (`<...>`) por tus valores reales.

### Requisitos habituales

- **Bash** 4+ y [`jq`](https://stedolan.github.io/jq/) para los scripts de ZeroTier/Cloudflare.
- **Python 3** para los scripts de subdominios de Cloudflare.
- **`curl`** para las llamadas a las APIs.
- **`msmtp`** (o equivalente) para las alertas por correo de los scripts de backup.

---

## 🔒 Seguridad

- Ningún script incluye tokens, claves ni contraseñas reales: todo son **marcadores**.
- Donde es posible, los secretos pueden pasarse por **variable de entorno**
  (por ejemplo `ZT_API_TOKEN`) en lugar de escribirlos en el fichero.
- Usa siempre **tokens de API con el mínimo privilegio** necesario y protege los ficheros
  de configuración con `chmod 600`.

---

## 📜 Licencia

Distribuido bajo licencia **MIT**. Consulta el fichero [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Jaime Alberto Vicente** — Administración de sistemas e infraestructura
🌐 Blog: [jaimealberto.io](https://jaimealberto.io)

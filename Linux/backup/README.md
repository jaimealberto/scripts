# 💾 Backup

Scripts de copia de seguridad remota con alerta por correo: configuración de
OPNsense vía API y backups en caliente de Raspberry Pi por SSH.

Requisitos habituales: `curl`, `msmtp` para las alertas por correo y, en los
backups de Raspberry Pi, acceso SSH por clave sin contraseña y `gzip`. Cada
script documenta en su cabecera la configuración de `~/.msmtprc`. Rellena los
marcadores `<...>` antes de usarlos.

| Script | Descripción | Description |
|--------|-------------|-------------|
| `backup_opnsense.sh` | Backup de la configuración de OPNsense vía API, con alerta por correo. | Backs up the OPNsense configuration via API, with e-mail alerting. |
| `remote_backup_rpi.sh` | Backup remoto en caliente de Raspberry Pi (versión 1). | Hot remote backup of a Raspberry Pi (version 1). |
| `remote_backup_rpiv2.sh` | Backup remoto en caliente de Raspberry Pi (versión 2). | Hot remote backup of a Raspberry Pi (version 2). |
| `remote_backup_rpiv3.sh` | Backup remoto en caliente de Raspberry Pi (versión 3, la actual). | Hot remote backup of a Raspberry Pi (version 3, the current one). |

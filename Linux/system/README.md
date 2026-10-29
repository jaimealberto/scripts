# ⚙️ System

Utilidades de sistema: alta de usuarios para administración remota, instalación
de herramientas y monitorización por ping.

| Script | Descripción | Description |
|--------|-------------|-------------|
| `add_user.sh` | Da de alta un usuario para administración remota por SSH (clave pública + sudoers). | Creates a user for remote administration over SSH (public key + sudoers). |
| `install_duf_rpi.sh` | Instala `duf` en Raspberry Pi OS (no está en los repos oficiales). | Installs `duf` on Raspberry Pi OS (not available in the official repos). |
| `ping_notify.sh` | Monitoriza hosts por ping y avisa en el escritorio con `notify-send`. | Monitors hosts via ping and notifies the desktop with `notify-send`. |
| `hosts.lst.example` | Lista de hosts de ejemplo para `ping_notify.sh` (cópiala a `hosts.lst`). | Sample host list for `ping_notify.sh` (copy it to `hosts.lst`). |

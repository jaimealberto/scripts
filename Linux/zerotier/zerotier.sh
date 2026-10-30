#!/usr/bin/env bash
#===============================================================================
# Nombre:       zerotier.sh
# Descripción:  Instala y configura el cliente ZeroTier y une el equipo a una
#               red indicada por su ID.
# Autor:        JaimeAlberto · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, gpg y systemd. Ejecutar como root.
# Uso:          ./zerotier.sh
# Nota:         Rellena los marcadores <...> de la configuración antes de usar.
#===============================================================================
set -euo pipefail

# Variables
NETWORK="<ID_NETWORK_ZEROTIER>"
# Descarga zerotier
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | bash; fi
systemctl enable zerotier-one
systemctl start zerotier-one
zerotier-cli join "$NETWORK"

# Borrar script despues de su ejecucion deshabilitado
# rm $0
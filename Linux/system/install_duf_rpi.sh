#!/usr/bin/env bash
#===============================================================================
# Nombre:       install_duf_rpi.sh
# Descripción:  Instala la utilidad duf en Raspberry Pi OS descargando el
#               binario más reciente desde GitHub, ya que no está disponible
#               en los repositorios oficiales de Raspberry Pi OS.
# Autor:        Jaime Alberto Vicente · https://jaimealberto.io
# Licencia:     MIT
# Requisitos:   curl, wget, tar y dpkg. Usa sudo para instalar en /usr/local/bin.
# Uso:          ./install_duf_rpi.sh
# Referencia:   https://github.com/muesli/duf
#===============================================================================
set -euo pipefail

# Obtener la última versión del binario desde la API de GitHub
LATEST_VERSION=$(curl -s "https://api.github.com/repos/muesli/duf/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Determinar la arquitectura de la Raspberry Pi
ARCH=$(dpkg --print-architecture)

# Mapear la arquitectura para que coincida con el nombre del archivo de duf
case "$ARCH" in
    armhf)
        DUF_ARCH="armv6"
        ;;
    arm64)
        DUF_ARCH="arm64"
        ;;
    *)
        echo "Arquitectura no soportada: $ARCH"
        exit 1
        ;;
esac

# Construir la URL de descarga
DOWNLOAD_URL="https://github.com/muesli/duf/releases/download/${LATEST_VERSION}/duf_${LATEST_VERSION/v/}_linux_${DUF_ARCH}.tar.gz"

# Descargar el archivo
echo "Descargando duf desde $DOWNLOAD_URL..."
wget "$DOWNLOAD_URL" -O duf.tar.gz

# Extraer el binario del archivo comprimido
tar -xzvf duf.tar.gz

# Darle permisos de ejecución al binario y moverlo a una ruta del sistema
chmod +x duf
sudo mv duf /usr/local/bin/

# Limpiar los archivos descargados
rm duf.tar.gz
rm README.md
rm LICENSE

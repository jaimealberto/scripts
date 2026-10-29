#!/bin/bash
# Ejecutar como root
# https://jaimealberto.io
# 11/11/2022
# Variables
NETWORK="<ID_NETWORK_ZEROTIER>"
# Descarga zerotier
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | bash; fi
systemctl enable zerotier-one
systemctl start zerotier-one
zerotier-cli join $NETWORK

# Borrar script despues de su ejecucion deshabilitado
# rm $0
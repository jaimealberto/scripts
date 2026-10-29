# 🔗 ZeroTier

Scripts para instalar ZeroTier y gestionar por API la cuenta, las redes y sus
miembros (alta, autorización, IP, descripción y estado).

Requisitos habituales: `curl`, `jq` y un **token de API de ZeroTier**
(se genera en <https://my.zerotier.com/account>). Rellena el marcador
`<TU_API_TOKEN>` de cada script antes de usarlo.

| Script | Descripción | Description |
|--------|-------------|-------------|
| `zerotier.sh` | Instala y configura el cliente ZeroTier y une el equipo a una red. | Installs and configures the ZeroTier client and joins the host to a network. |
| `zt_account_info.sh` | Muestra información general de la cuenta (redes y número de hosts). | Shows general account information (networks and host count). |
| `zt_host_auth.sh` | Lista los miembros y autoriza o desautoriza hosts (uno, varios o todos). | Lists members and authorizes or deauthorizes hosts (one, several or all). |
| `zt_host_delete.sh` | Borra un host de una red (conviene desautorizarlo antes). | Deletes a host from a network (deauthorize it first). |
| `zt_host_description.sh` | Cambia la descripción de un host. | Changes a host's description. |
| `zt_host_info.sh` | Muestra información de los hosts y redes. | Shows host and network information. |
| `zt_host_infoc.sh` | Igual que el anterior, con la salida en color. | Same as above, with colorized output. |
| `zt_host_ipchange.sh` | Cambia la IP asignada a un host. | Changes a host's assigned IP address. |
| `zt_host_ipstatus.sh` | Muestra el estado de los hosts junto con su IP. | Shows host status together with its IP address. |
| `zt_host_status.sh` | Muestra el estado de los hosts. | Shows host status. |
| `zt_token_test.sh` | Prueba el token de API listando las redes de la cuenta. | Tests the API token by listing the account networks. |

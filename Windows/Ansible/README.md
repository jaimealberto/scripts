# 🪟 Windows + Ansible

Scripts de PowerShell para habilitar **WinRM** y dejar un equipo Windows listo
para gestionarlo con **Ansible**.

PowerShell scripts to enable **WinRM** and get a Windows host ready to be
managed with **Ansible**.

## 📜 Scripts

| Script | Descripción | Description |
|--------|-------------|-------------|
| `enable.ps1` | Descarga `Upgrade-PowerShell.ps1` y actualiza Windows PowerShell a la versión 5.1 (necesaria para Ansible), usando las credenciales de administrador definidas en el script. | Downloads `Upgrade-PowerShell.ps1` and upgrades Windows PowerShell to 5.1 (required by Ansible), using the admin credentials set in the script. |
| `remote.ps1` | Descarga y ejecuta el `ConfigureRemotingForAnsible.ps1` oficial de Ansible, que configura el servicio WinRM (listeners, HTTPS y reglas de firewall). | Downloads and runs Ansible's official `ConfigureRemotingForAnsible.ps1`, which configures the WinRM service (listeners, HTTPS and firewall rules). |
| `start.ps1` | Endurecimiento posterior: restablece la política de ejecución a `Restricted` y elimina el inicio de sesión automático (AutoAdminLogon y las credenciales guardadas en el registro). | Post-setup hardening: resets the execution policy to `Restricted` and disables automatic logon (AutoAdminLogon and the credentials stored in the registry). |

## ✅ Procedimiento · Procedure

1. Abre una consola de PowerShell con privilegios de administrador.
2. Levanta el servicio WinRM:
   ```powershell
   PS C:\> Enable-PSRemoting -SkipNetworkProfileCheck
   ```
3. Configura el inicio automático del servicio:
   ```powershell
   PS C:\> Set-Service WinRM -StartupType Automatic
   ```
4. Habilita la ejecución de scripts:
   ```powershell
   PS C:\> Set-ExecutionPolicy Unrestricted
   ```
5. Edita las variables del fichero `enable.ps1` de este repositorio:
   ```powershell
   $username = "Administrador"
   $password = "SuperPassword123!"
   ```
6. Ejecuta `enable.ps1`.
7. Ejecuta `remote.ps1`.
8. Ejecuta `start.ps1`.
9. Comprueba la conexión desde tu nodo Ansible:
   ```sh
   ansible windows -m win_ping
   ```

> ⚠️ Las credenciales que aparecen en `enable.ps1` son solo un ejemplo:
> sustitúyelas por las tuyas y no las subas a ningún repositorio.
> The credentials in `enable.ps1` are just an example: replace them with your
> own and never commit them to a repository.

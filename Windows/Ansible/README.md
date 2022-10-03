#### Pasos para habilitar la administración desde Ansible

1. Abiremos la consola de PowerShell con privilegios de administrador.
2. Levantar el servicio.
```powershell
PS C:/> Enable-PSRemoting -force
```
3. Inicio automatico.
```powershell
PS C:\> Set-Service WinRM -StartMode Automatic
```
4. Habilitar ejecucion de scripts.
```powershell
PS C:\> Set-ExecutionPolicy Unrestricted
```
5. Cambiar las varibales en el fichero enble.ps1 de este repositorio.
```
$username = "Administrador"
$password = "SuperPassword123!"
```
6. Ejecutar enable.ps1
7. Ejecutar remote.ps1
8. Ejecutar start.ps1
9. Comprobar desde nuestro Ansible
```sh
ansible windows -m win_ping
```
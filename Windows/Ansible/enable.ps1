$url = "https://raw.githubusercontent.com/jaimealberto/scripts/main/Windows/Ansible/Upgrade-Poweshell.ps1"
$file = "$env:temp\Upgrade-PowerShell.ps1"
$username = "Administrador"
$password = "SuperPassword123!"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# Version can be 3.0, 4.0 or 5.1
&$file -Version 5.1 -Username $username -Password $password -Verbose
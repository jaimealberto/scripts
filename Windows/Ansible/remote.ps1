$url = "https://raw.githubusercontent.com/jaimealberto/scripts/main/Windows/Ansible/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
 
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
 
powershell.exe -ExecutionPolicy ByPass -File $file
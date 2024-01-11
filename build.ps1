$file = Get-Content .\installer\pc.ps1 | out-string
$pc = [PSCustomObject]@{
    "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($file))
}
$pc | convertto-json | set-content .\installer\pc.json

$file = Get-Content .\installer\quest.ps1 | out-string
$quest = [PSCustomObject]@{
    "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($file))
}
$quest | convertto-json | set-content .\installer\quest.json

New-Item -ItemType Directory -Force -Path .\package
Copy-Item .\installer\installer.ps1 .\package\installer.ps1
Compress-Archive -Path .\package\* -DestinationPath .\installer.zip

remove-item -Path .\package\installer.ps1

Copy-Item .\browser\serverBrowser.ps1 .\package\serverBrowser.ps1
Copy-Item .\browser\loading.gif .\package\loading.gif
Compress-Archive -Path .\package\* -DestinationPath .\browser.zip

Remove-Item .\package -Recurse
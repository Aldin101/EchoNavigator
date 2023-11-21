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
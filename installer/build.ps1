$file = Get-Content .\pc.ps1 | out-string
$pc = [PSCustomObject]@{
    "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($file))
}
$pc | convertto-json | set-content .\pc.json

$file = Get-Content .\quest.ps1 | out-string
$quest = [PSCustomObject]@{
    "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($file))
}
$quest | convertto-json | set-content .\quest.json
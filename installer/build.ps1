$file = Invoke-WebRequest https://aldin101.github.io/Echo-Relay-Installer/host.json -UseBasicParsing
$global:database = $file.Content | ConvertFrom-Json
$file = Get-Content .\online.ps1 | out-string
$j = [PSCustomObject]@{
    "Script" =  [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($file))
}
$database.installer = $j
$database | convertto-json | set-content .\host.json
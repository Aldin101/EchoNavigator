param($keys)
$keys | Out-File -FilePath "$env:appdata\EchoNavigator\token"
pause
$ProgressPreference = 'SilentlyContinue'
[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true) {
    [system.windows.forms.messagebox]::Show("Running as Administrator")
}

$file = Invoke-WebRequest https://aldin101.github.io/Echo-Relay-Installer/quest.json -UseBasicParsing
$global:database = $file.Content | ConvertFrom-Json

if ($global:database -eq $null) {
    [system.windows.forms.messagebox]::Show("No internet connection")
    exit
}
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($global:database.installer.Script)) | iex
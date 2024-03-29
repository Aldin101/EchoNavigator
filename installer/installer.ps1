$ProgressPreference = 'SilentlyContinue'
[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

$fileLocation = Get-CimInstance Win32_Process -Filter "name = 'Echo Navigator Installer.exe'" -ErrorAction SilentlyContinue
if ($fileLocation -eq $null) {
    $fileLocation = Get-CimInstance Win32_Process -Filter "name = 'EchoNavigatorInstaller.exe'" -ErrorAction SilentlyContinue
}
$fileLocation1 = $fileLocation.CommandLine -replace '"', ""
$menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
$platformMenu = new-object System.Windows.Forms.Form
$platformMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
$platformMenu.text = "Echo Navigator Installer"
$platformMenu.Size = New-Object Drawing.Size @(400, 200)
$platformMenu.StartPosition = "CenterScreen"
$platformMenu.FormBorderStyle = "FixedDialog"
$platformMenu.MaximizeBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Size(0,5)
$label.Size = New-Object System.Drawing.Size(380,30)
$label.Text = "Select your platform"
$label.Font = "Microsoft Sans Serif,20"
$label.TextAlign = "MiddleCenter"
$platformMenu.Controls.Add($label)

$pcButton = New-Object System.Windows.Forms.Button
$pcButton.Location = New-Object System.Drawing.Size(5,40)
$pcButton.Size = New-Object System.Drawing.Size(180,100)
$pcButton.Text = "PC"
$pcButton.Font = "Microsoft Sans Serif,30"
$pcButton.Add_Click({
    $platformMenu.Close()
    $file = Invoke-WebRequest https://aldin101.github.io/EchoNavigatorAPI/pc.json -UseBasicParsing
    $global:database = $file.Content | ConvertFrom-Json
    if ($global:database -eq $null) {
        [system.windows.forms.messagebox]::Show("The server could not be contacted, this is usually because you have not internet.", "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Error)
        exit
    }
})
$platformMenu.Controls.Add($pcButton)

$questButton = New-Object System.Windows.Forms.Button
$questButton.Location = New-Object System.Drawing.Size(195,40)
$questButton.Size = New-Object System.Drawing.Size(180,100)
$questButton.Text = "Quest"
$questButton.Font = "Microsoft Sans Serif,30"
$questButton.Add_Click({
    $platformMenu.Close()
    $file = Invoke-WebRequest https://aldin101.github.io/EchoNavigatorAPI/quest.json -UseBasicParsing
    $global:database = $file.Content | ConvertFrom-Json
    if ($global:database -eq $null) {
        [system.windows.forms.messagebox]::Show("The server could not be contacted, this is usually because you have not internet.", "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Error)
        exit
    }
})

$platformMenu.Controls.Add($questButton)

$platformMenu.ShowDialog()

[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($global:database.Script)) | iex
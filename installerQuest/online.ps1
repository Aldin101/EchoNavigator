$ProgressPreference = 'SilentlyContinue'
$file = Invoke-WebRequest https://aldin101.github.io/Echo-Relay-Installer/quest.json -UseBasicParsing
$global:database = $file.Content | ConvertFrom-Json

function install {
    $noUsernameOrPassword.Visible = $false
    if ($usernameBox.text -eq "" -or $passwordBox.text -eq "") {
        $noUsernameOrPassword.Text = "Please enter a username and password"
        $noUsernameOrPassword.Visible = $true
        return
    }
    if ($passwordBox.Text.Length -lt 8) {
        $noUsernameOrPassword.Text = "Password must be at least 8 characters"
        $noUsernameOrPassword.Visible = $true
        return
    }
    if ($passwordBox.Text -notmatch "[a-z]") {
        $noUsernameOrPassword.Text = "Password must contain at least 1 letter"
        $noUsernameOrPassword.Visible = $true
        return
    }
    if ($passwordBox.Text -notmatch "[0-9]") {
        $noUsernameOrPassword.Text = "Password must contain at least 1 number"
        $noUsernameOrPassword.Visible = $true
        return
    }
    if ($usernameBox.text -match " " -or $passwordBox.text -match " ") {
        $noUsernameOrPassword.Text = "Username and Password cannot contain spaces"
        $noUsernameOrPassword.Visible = $true
        return
    }
    if ($infoCheckBox.Checked -eq $false) {
        $infoLabel.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $infoLabel.ForeColor = "Black"
        start-sleep -Milliseconds 150
        $infoLabel.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $infoLabel.ForeColor = "Black"
        start-sleep -Milliseconds 150
        $infoLabel.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $infoLabel.ForeColor = "Black"
        return
    }

    mkdir "$env:appdata\Echo Relay Server Browser\"
    $config = @{}
    $config | Add-Member -Name 'username' -Type NoteProperty -Value "$($usernameBox.text)"
    $config | Add-Member -Name 'password' -Type NoteProperty -Value "$($passwordBox.text)"
    $config | Add-Member -Name 'gamePath' -Type NoteProperty -Value "$($global:gamePath)"
    $config | Add-Member -Name 'quest' -Type NoteProperty -Value "$env:appdata\Echo Relay Server Browser\Echo Relay Server Browser.exe"
    $config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
    Invoke-WebRequest "https://aldin101.github.io/echo-relay-server-browser/Echo%20Relay%20Server%20Browser.exe" -OutFile "$env:appdata\Echo Relay Server Browser\Echo Relay Server Browser.exe"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Echo Relay Server Browser.lnk")
    $Shortcut.TargetPath = "$env:appdata\Echo Relay Server Browser\Echo Relay Server Browser.exe"
    $Shortcut.Save()
    [system.windows.forms.messagebox]::Show("Echo Relay Successfully Installed", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Information)
    start-process "$env:appdata\Echo Relay Server Browser\Echo Relay Server Browser.exe"
    $menu.Close()
}




[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
$menu = new-object System.Windows.Forms.Form

$menu.text = "Echo Relay Installer"
$fileLocation = Get-CimInstance Win32_Process -Filter "name = 'Echo Relay Installer.exe'" -ErrorAction SilentlyContinue
$fileLocation1 = $fileLocation.CommandLine -replace '"', ""
$menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
$menu.Size = New-Object Drawing.Size @(600, 400)
$menu.StartPosition = "CenterScreen"
$menu.FormBorderStyle = "FixedDialog"
$menu.MaximizeBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Size(10,10)
$label.Size = New-Object System.Drawing.Size(200,20)
$label.Text = "Echo Relay Installer"
$label.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($label)

$username = New-Object System.Windows.Forms.Label
$username.Location = New-Object System.Drawing.Size(10,40)
$username.Size = New-Object System.Drawing.Size(200,20)
$username.Text = "Username"
$username.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($username)

$usernameBox = New-Object System.Windows.Forms.TextBox
$usernameBox.Location = New-Object System.Drawing.Size(10,60)
$usernameBox.Size = New-Object System.Drawing.Size(200,20)
$usernameBox.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($usernameBox)

$password = New-Object System.Windows.Forms.Label
$password.Location = New-Object System.Drawing.Size(10,90)
$password.Size = New-Object System.Drawing.Size(200,20)
$password.Text = "Password"
$password.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($password)

$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Size(10,110)
$passwordBox.Size = New-Object System.Drawing.Size(200,20)
$passwordBox.Font = "Microsoft Sans Serif,10"
$passwordBox.PasswordChar = "*"
$menu.Controls.Add($passwordBox)

$showPassword = New-Object System.Windows.Forms.PictureBox
$showPassword.Location = New-Object System.Drawing.Size(188, 111)
$showPassword.Size = New-Object System.Drawing.Size(21, 21)
$showPassword.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$showPassword.ImageLocation = "https://aldin101.github.io/Echo-Relay-Installer/eye.png"
$showPassword.BackColor = [System.Drawing.Color]::White
$showPassword.Add_Click({
    if ($passwordBox.PasswordChar -eq "*") {
        $passwordBox.PasswordChar = $null
        $showPassword.BackColor = [System.Drawing.Color]::LightBlue
        $toolTip.SetToolTip($showPassword, "Hide Password")
    } else {
        $passwordBox.PasswordChar = "*"
        $showPassword.BackColor = [System.Drawing.Color]::White
        $toolTip.SetToolTip($showPassword, "Show Password")
    }
})
$showPassword.Add_MouseEnter({
    $showPassword.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
})
$showPassword.Add_MouseLeave({
    $showPassword.BorderStyle = [System.Windows.Forms.BorderStyle]::None
})
$menu.Controls.Add($showPassword)

$showPassword.BringToFront()

$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.AutomaticDelay = 500
$toolTip.SetToolTip($showPassword, "Show Password")

$noUsernameOrPassword = New-Object System.Windows.Forms.Label
$noUsernameOrPassword.Location = New-Object System.Drawing.Size(10,170)
$noUsernameOrPassword.Size = New-Object System.Drawing.Size(210,20)
$noUsernameOrPassword.Font = "Microsoft Sans Serif,8"
$noUsernameOrPassword.ForeColor = "Red"
$noUsernameOrPassword.Visible = $false
$menu.Controls.Add($noUsernameOrPassword)

$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Location = New-Object System.Drawing.Size(220,10)
$infoLabel.Size = New-Object System.Drawing.Size(2000,230)
$infoLabel.Text = "This information is not your Meta log in, it is your account`non Echo Relay servers. But your account info is still tied to`nyour Meta account and cannot be changed later.`nIf you forget your account information for a server please`ncontact the server host.`n`nThere is no check for if your username has already been`nclaimed at this time. If you receive login errors please`ntry a different username.`n`nDO NOT use the same password for you Meta account or`nany other online service. While using unique passwords for`nall online services is always recommended, it is especially`nimportant for Echo Relay because your account information`nis not secured."
$infoLabel.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($infoLabel)

$infoCheckBox = New-Object System.Windows.Forms.CheckBox
$infoCheckBox.Location = New-Object System.Drawing.Size(220,240)
$infoCheckBox.Size = New-Object System.Drawing.Size(2000,20)
$infoCheckBox.Text = "I have read and understand the above notice"
$infoCheckBox.Font = "Microsoft Sans Serif,10"

$infoCheckBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        $infoCheckBox.Checked = !$infoCheckBox.Checked
    }
})

$menu.Controls.add($infoCheckBox)


$install = New-Object System.Windows.Forms.Button
$install.Location = New-Object System.Drawing.Size(10,140)
$install.Size = New-Object System.Drawing.Size(200,30)
$install.Text = "Install"
$install.Font = "Microsoft Sans Serif,10"
$install.Add_Click({install})
$menu.Controls.Add($install)

$credits = New-Object System.Windows.Forms.Label
$credits.Location = New-Object System.Drawing.Size(5,325)
$credits.Size = New-Object System.Drawing.Size(2000,200)
$credits.Text = "Echo Relay Created by: Xenomega`nInstaller Created by:Aldin101"
$credits.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($credits)
start-sleep -s 3

$menu.ShowDialog()


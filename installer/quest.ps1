$ProgressPreference = 'SilentlyContinue'

function makeMovableObject {
    param(
        [Parameter(Mandatory=$true)]
        $object
    )

    $object.Add_MouseDown({
        param($global:sendingObject, $event)

        $global:hasIntersected = $false

        $global:clickedPoint = $sendingObject.PointToClient([System.Windows.Forms.Cursor]::Position)

        $global:moveable = $true

    })
    $object.Add_MouseMove({
        if (!$global:moveable) {
            return
        }
        $cursorPosition = ($sendingObject.Parent.PointToClient([System.Windows.Forms.Cursor]::Position) - $clickedPoint)
        $newObjectLocation = New-Object System.Drawing.Point($cursorPosition.X, $cursorPosition.Y)
        $oldObjectLocation = $sendingObject.Location

        while (($newObjectLocation.X - $oldObjectLocation.x) -gt 20 -and $global:hasIntersected -eq $true) {
            $newObjectLocation.X = $newObjectLocation.X - [math]::Sign($newObjectLocation.X - $oldObjectLocation.x)
        }
        while (($newObjectLocation.Y - $oldObjectLocation.y) -gt 20 -and $global:hasIntersected -eq $true) {
            $newObjectLocation.Y = $newObjectLocation.Y - [math]::Sign($newObjectLocation.Y - $oldObjectLocation.y)
        }
        while (($newObjectLocation.X - $oldObjectLocation.x) -lt -20 -and $global:hasIntersected -eq $true) {
            $newObjectLocation.X = $newObjectLocation.X + [math]::Sign($oldObjectLocation.X - $newObjectLocation.x)
        }
        while (($newObjectLocation.Y - $oldObjectLocation.y) -lt -20 -and $global:hasIntersected -eq $true) {
            $newObjectLocation.Y = $newObjectLocation.Y + [math]::Sign($oldObjectLocation.Y - $newObjectLocation.y)
        }

        # collision detection, unused because there are a lot of elements on the screen and keeping it off is more fun, also bugs

        # switch ($newObjectLocation.X) {
        #     {$_ -lt 0} {$newObjectLocation.X = 0}
        #     {$_ -gt $sendingObject.Parent.Size.Width - $sendingObject.Size.Width} {$newObjectLocation.X = $sendingObject.Parent.Size.Width - $sendingObject.Size.Width}
        # }

        # switch ($newObjectLocation.Y) {
        #     {$_ -lt 0} {$newObjectLocation.Y = 0}
        #     {$_ -gt $sendingObject.Parent.Size.Height - $sendingObject.Size.Height*2} {$newObjectLocation.Y = $sendingObject.Parent.Size.Height - $sendingObject.Size.Height*2}
        # }

        # $pathRectangle = New-Object System.Drawing.Rectangle(
        #     [Math]::Min($oldObjectLocation.X, $newObjectLocation.X),
        #     [Math]::Min($oldObjectLocation.Y, $newObjectLocation.Y),
        #     ([Math]::Abs($newObjectLocation.X - $oldObjectLocation.X) + $sendingObject.Width),
        #     ([Math]::Abs($newObjectLocation.Y - $oldObjectLocation.Y) + $sendingObject.Height)
        # )

        # foreach ($control in $sendingObject.Parent.Controls) {
        #     if ($control -ne $sendingObject) {
        #         if ($control.Bounds.IntersectsWith($pathRectangle)) {
        #             $sendingObject.Location = $oldObjectLocation
        #             $global:hasIntersected = $true
        #             return
        #         }
        #     }
        # }

        $sendingObject.Location = $newObjectLocation

        $global:sendingObject.BringToFront()
        $global:sendingObject.TopLevelControl.Refresh()
    })
    $object.Add_MouseUp({
        $global:moveable = $false
    })
}
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

    mkdir "$env:appdata\EchoNavigator\"
    $config = @{}
    $config | Add-Member -Name 'username' -Type NoteProperty -Value "$($usernameBox.text)"
    $config | Add-Member -Name 'password' -Type NoteProperty -Value "$($passwordBox.text)"
    $config | Add-Member -Name 'gamePath' -Type NoteProperty -Value "$($global:gamePath)"
    $config | Add-Member -Name 'quest' -Type NoteProperty -Value "$env:appdata\EchoNavigator\EchoNavigator.exe"
    $config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
    Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/EchoNavigator.exe" -OutFile "$env:appdata\EchoNavigator\EchoNavigator.exe"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Echo Navigator.lnk")
    $Shortcut.TargetPath = "$env:appdata\EchoNavigator\EchoNavigator.exe"
    $Shortcut.Save()
    if (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EchoNavigator") {
        Remove-Item HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EchoNavigator -Recurse -Force
        Remove-Item HKCU:\Software\Classes\EchoNavigator -Recurse -Force
    }
    [system.windows.forms.messagebox]::Show("Echo Navigator installed!`n`nSelect a server to get started!", "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Information)
    start-process "$env:appdata\EchoNavigator\EchoNavigator.exe" -WorkingDirectory "C:\"
    $menu.Close()
}




[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
$menu = new-object System.Windows.Forms.Form

$menu.text = "Echo Navigator Installer"
$fileLocation = Get-CimInstance Win32_Process -Filter "name = 'Echo Relay Installer.exe'" -ErrorAction SilentlyContinue
$fileLocation1 = $fileLocation.CommandLine -replace '"', ""
$menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
$menu.Size = New-Object Drawing.Size @(600, 400)
$menu.StartPosition = "CenterScreen"
$menu.FormBorderStyle = "FixedDialog"
$menu.MaximizeBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Size(10,8)
$label.Size = New-Object System.Drawing.Size(200,25)
$label.Text = "Echo Navigator Installer"
$label.Font = "Microsoft Sans Serif,13"
$label.TextAlign = "MiddleLeft"
$menu.Controls.Add($label)
makeMovableObject -object $label

$username = New-Object System.Windows.Forms.Label
$username.Location = New-Object System.Drawing.Size(10,40)
$username.Size = New-Object System.Drawing.Size(200,20)
$username.Text = "Username"
$username.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($username)
makeMovableObject -object $username

$usernameBox = New-Object System.Windows.Forms.TextBox
$usernameBox.Location = New-Object System.Drawing.Size(10,60)
$usernameBox.Size = New-Object System.Drawing.Size(200,20)
$usernameBox.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($usernameBox)
makeMovableObject -object $usernameBox

$password = New-Object System.Windows.Forms.Label
$password.Location = New-Object System.Drawing.Size(10,90)
$password.Size = New-Object System.Drawing.Size(200,20)
$password.Text = "Password"
$password.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($password)
makeMovableObject -object $password

$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Size(10,110)
$passwordBox.Size = New-Object System.Drawing.Size(200,20)
$passwordBox.Font = "Microsoft Sans Serif,10"
$passwordBox.PasswordChar = "*"
$menu.Controls.Add($passwordBox)
makeMovableObject -object $passwordBox

$showPassword = New-Object System.Windows.Forms.PictureBox
$showPassword.Location = New-Object System.Drawing.Size(188, 111)
$showPassword.Size = New-Object System.Drawing.Size(21, 21)
$showPassword.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$showPassword.ImageLocation = "https://aldin101.github.io/EchoNavigatorAPI/eye.png"
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
makeMovableObject -object $showPassword

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
makeMovableObject -object $noUsernameOrPassword

$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Location = New-Object System.Drawing.Size(220,10)
$infoLabel.Size = New-Object System.Drawing.Size(2000,230)
$infoLabel.Text = "This information is not your Meta log in, it is your account`non Echo Relay servers. But your account info is still tied to`nyour Meta account and cannot be changed later.`nIf you forget your account information for a server please`ncontact the server host.`n`nThere is no check for if your username has already been`nclaimed at this time. If you receive login errors please`ntry a different username.`n`nDO NOT use the same password for you Meta account or`nany other online service. While using unique passwords for`nall online services is always recommended, it is especially`nimportant for Echo Relay because your account information`nis not secured."
$infoLabel.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($infoLabel)
makeMovableObject -object $infoLabel

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
makeMovableObject -object $infoCheckBox


$install = New-Object System.Windows.Forms.Button
$install.Location = New-Object System.Drawing.Size(10,140)
$install.Size = New-Object System.Drawing.Size(200,30)
$install.Text = "Install"
$install.Font = "Microsoft Sans Serif,10"
$install.Add_Click({install})
$menu.Controls.Add($install)
makeMovableObject -object $install

$credits = New-Object System.Windows.Forms.Label
$credits.Location = New-Object System.Drawing.Size(5,325)
$credits.Size = New-Object System.Drawing.Size(2000,200)
$credits.Text = "Echo Navigator Created By: Aldin101`nOriginal Echo Relay Created By:Xenomega"
$credits.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($credits)
makeMovableObject -object $credits

$menu.ShowDialog()


$ProgressPreference = 'SilentlyContinue'
$file = Invoke-WebRequest https://aldin101.github.io/Echo-Relay-Installer/host.json -UseBasicParsing
$global:database = $file.Content | ConvertFrom-Json
function Decompress-ZlibFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputPath,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    Add-Type -AssemblyName System.IO.Compression

    $input = New-Object System.IO.FileStream($InputPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
    $output = New-Object System.IO.FileStream($OutputPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)

    $input.ReadByte() | Out-Null
    $input.ReadByte() | Out-Null

    $deflateStream = New-Object System.IO.Compression.DeflateStream($input, [System.IO.Compression.CompressionMode]::Decompress)

    $buffer = New-Object byte[](1024)
    while (($read = $deflateStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $output.Write($buffer, 0, $read)
    }

    $deflateStream.Close()
    $output.Close()
    $input.Close()
}

function Read-FolderBrowserDialog([string]$Message, [string]$InitialDirectory) {
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, 0, $InitialDirectory)
    if ($folder) { return $folder.Self.Path } else { return 'C:\Program Files\Oculus\Software\Software' }
}

function downgrade {
    $menu.Hide()

    $downgradeMenu = new-object System.Windows.Forms.Form
    $downgradeMenu.text = "Echo Relay Downgrader"
    $downgradeMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
    $downgradeMenu.Size = New-Object Drawing.Size @(300, 200)
    $downgradeMenu.StartPosition = "CenterScreen"
    $downgradeMenu.FormBorderStyle = "FixedDialog"
    $downgradeMenu.MaximizeBox = $false

    $downgradeLabel = New-Object System.Windows.Forms.Label
    $downgradeLabel.Location = New-Object System.Drawing.Size(10,10)
    $downgradeLabel.Size = New-Object System.Drawing.Size(200,20)
    $downgradeLabel.Text = "Echo Relay Downgrader"
    $downgradeLabel.Font = "Microsoft Sans Serif,10"
    $downgradeMenu.Controls.Add($downgradeLabel)

    $downgradeButton = New-Object System.Windows.Forms.Button
    $downgradeButton.Location = New-Object System.Drawing.Size(10,30)
    $downgradeButton.Size = New-Object System.Drawing.Size(200,30)
    $downgradeButton.Text = "Downgrade"
    $downgradeButton.Font = "Microsoft Sans Serif,10"
    $downgradeButton.Add_Click({
        $downgradeButton.text = "Preparing WebDriver..."
        $downgradeButton.Refresh()
        Install-Module -Name Selenium -Scope CurrentUser -Confirm:$false -Force

        $downgradeButton.text = "Downloading firefox..."
        $downgradeButton.Refresh()

        winget install mozilla.firefox --source winget

        $downgradeButton.text = "Waiting for login..."
        $downgradeButton.Refresh()
        start-sleep -s 2
        $firefox = Start-SeFirefox -DefaultDownloadPath "$env:appdata\echo relay server browser\"
        $firefox.Navigate().GoToUrl("https://auth.oculus.com/login/?redirect_uri=https%3A%2F%2Fdeveloper.oculus.com%2Fmanage%2F")
        while ($firefox.url -notlike "https://developer.oculus.com/manage/*") {
            if ($firefox.url -eq $null) {
                $firefox.Quit()
                [System.Windows.Forms.MessageBox]::show("You closed the browser window without logging in. Please try again.`n`nThe account information entered is only ever used to download the game. If you wish not to enter your account information you will need to use anther method to get Echo Relay on Quest.", "Echo Relay Server Browser","OK", "Error")
                $downgradeButton.text = "Try again"
                $downgradeButton.enabled = $true
                return
            }
            Start-Sleep -Seconds 1
        }
        $token = $firefox.Manage().Cookies.GetCookieNamed("oc_www_at").Value
        $firefox.Quit()
        $downgradeButton.text = "Downloading..."
        $downgradeButton.Refresh()
        $file = Invoke-WebRequest -uri "https://securecdn.oculus.com/binaries/download/?id=6323983201049540&access_token=$token&get_manifest=1" -OutFile "$env:temp\manifest.zip"
        Expand-Archive -Path "$env:temp\manifest.zip" -DestinationPath "$env:temp\manifest" -force
        $manifest = get-content "$env:temp\manifest\manifest.json" | convertfrom-json
        for ($i=0; $i -lt $($manifest.files | get-member).name.count; $i++) {
            $folderName = $($($manifest.files | get-member).name[$i])
            $folderName = $folderName -split "\\"
            $folderName = $folderName[0..($folderName.Length - 2)]
            $folderName = $folderName -join "\"
            mkdir "$env:temp\evr\$folderName\" -ErrorAction SilentlyContinue
            $fileStream = New-Object System.IO.FileStream("$env:temp\evr\$($($manifest.files | get-member).name[$i])", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            $bufferSize = 10KB
            foreach ($segment in $manifest.files.$($($manifest.files | get-member).name[$i]).segments) {
                $targetStream = New-Object -TypeName System.IO.MemoryStream
                $uri = New-Object "System.Uri" "https://securecdn.oculus.com/binaries/segment/?access_token=$token&binary_id=6323983201049540&segment_sha256=$($segment[1])"
                $request = [System.Net.HttpWebRequest]::Create($uri)
                $request.set_Timeout(15000)
                $response = $request.GetResponse()
                $responseStream = $response.GetResponseStream()
                $responseStream.CopyTo($targetStream, $bufferSize)
                $targetStream.Position = 0
                $targetStream.SetLength($targetStream.Length - 4)
                $targetStream.Position = 2
                $deflateStream = New-Object System.IO.Compression.DeflateStream($targetStream, [System.IO.Compression.CompressionMode]::Decompress)
                $deflateStream.CopyTo($fileStream, $bufferSize)
                $deflateStream.Close()
                $targetStream.Close()
                $responseStream.Close()
            }
            $fileStream.Close()
        }
        rmdir "$env:temp\evr\Equals" -recurse -force
        rmdir "$env:temp\evr\GetHashCode" -recurse -force
        rmdir "$env:temp\evr\GetType" -recurse -force
        rmdir "$env:temp\evr\ToString" -recurse -force
    })
    $downgradeMenu.Controls.Add($downgradeButton)

    $folderPicker = New-Object System.Windows.Forms.Button
    $folderPicker.Location = New-Object System.Drawing.Size(10,70)
    $folderPicker.Size = New-Object System.Drawing.Size(200,30)
    $folderPicker.Text = "Target folder"
    $folderPicker.Font = "Microsoft Sans Serif,10"
    $folderPicker.Add_Click({
        $locations = Get-ChildItem "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\*"
        $locationList = [System.Collections.ArrayList]@()
        foreach ($location in $locations) {
            $locationList.Add($(Get-ItemProperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\$($location.PSChildName)" -Name OriginalPath | select -ExpandProperty OriginalPath))
        }
        $i=0
        foreach ($location in $locationList) {
            if (test-path "$location\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe") {
                break
            }
            $i++
        }
        $pickMenu = new-object System.Windows.Forms.Form
        $pickMenu.text = "Echo Relay Downgrader"
        $pickMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
        $pickMenu.Size = New-Object Drawing.Size @(320, 270)
        $pickMenu.StartPosition = "CenterScreen"
        $pickMenu.FormBorderStyle = "FixedDialog"
        $pickMenu.MaximizeBox = $false
        $pickMenu.ShowInTaskbar = $false

        $pickLabel = New-Object System.Windows.Forms.Label
        $pickLabel.Location = New-Object System.Drawing.Size(10,10)
        $pickLabel.Size = New-Object System.Drawing.Size(280,20)
        $pickLabel.Text = "Select folder to download Echo VR into"
        $pickLabel.TextAlign = "MiddleCenter"
        $pickLabel.Font = "Microsoft Sans Serif,10"
        $pickMenu.Controls.Add($pickLabel)

        $pickList = New-Object System.Windows.Forms.ListBox
        $pickList.Location = New-Object System.Drawing.Size(10,30)
        $pickList.Size = New-Object System.Drawing.Size(280,100)
        $pickList.Font = "Microsoft Sans Serif,10"
        $pickList.DataSource = $locationList
        $pickList.SelectedIndex = $i
        $pickMenu.Controls.Add($pickList)

        $customPath = New-Object System.Windows.Forms.Button
        $customPath.Location = New-Object System.Drawing.Size(10,140)
        $customPath.Size = New-Object System.Drawing.Size(280,30)
        $customPath.Text = "Custom Path"
        $customPath.Font = "Microsoft Sans Serif,10"
        $customPath.Add_Click({
            $choice = [System.Windows.Forms.MessageBox]::Show("It is recommended that you use the pre-selected folder so that the Oculus app launches the downgraded version of the game.`n`n`While you can use a custom path it is not recommended. Would you still like to use a custom path?", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                return
            }
            $global:gamePath = Read-FolderBrowserDialog -Message "Select the folder you want to install Echo VR into"
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($customPath)

        $pickButton = New-Object System.Windows.Forms.Button
        $pickButton.Location = New-Object System.Drawing.Size(10,180)
        $pickButton.Size = New-Object System.Drawing.Size(280,30)
        $pickButton.Text = "Select"
        $pickButton.Font = "Microsoft Sans Serif,10"
        $pickButton.Add_Click({
            if ($picklist.SelectedIndex -ne $i) {
                $choice = [System.Windows.Forms.MessageBox]::show("It is recommended that you use the pre-selected folder so that the Oculus app launches the downgraded version of the game.`n`n`While you can still pick this folder it is not recommended. Would you still like to use the selected folder?", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
                if ($choice -eq "No") {
                    return
                }
            }
            $global:gamePath = "$($pickList.SelectedItem)\Software"
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($pickButton)

        $pickMenu.ShowDialog()
    })
    $downgradeMenu.Controls.Add($folderPicker)

    $noDotNET = New-Object System.Windows.Forms.Label
    $noDotNET.Location = New-Object System.Drawing.Size(10,100)
    $noDotNET.Size = New-Object System.Drawing.Size(2000,20)
    $noDotNET.Text = "You did not install .NET 6.0"
    $noDotNET.ForeColor = "Red"
    $noDotNET.Font = "Microsoft Sans Serif,10"
    $noDotNET.Visible = $false
    $downgradeMenu.Controls.Add($noDotNET)

    $downgradeToolGithub = New-Object System.Windows.Forms.LinkLabel
    $downgradeToolGithub.Location = New-Object System.Drawing.Size(10,120)
    $downgradeToolGithub.Size = New-Object System.Drawing.Size(200,40)
    $downgradeToolGithub.Text = "Oculus Downgrader`nMade By: ComputerElite"
    $downgradeToolGithub.Font = "Microsoft Sans Serif,10"
    $downgradeToolGithub.Add_Click({explorer https://github.com/ComputerElite/Oculus-downgrader})
    $downgradeMenu.Controls.Add($downgradeToolGithub)

    $downgradeMenu.ShowDialog()
    $menu.Show()
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
    if (!(test-path $global:gamePath\bin\win10\echovr.exe)) {
        $choice = [System.Windows.Forms.MessageBox]::show("Please select a valid game folder or install the game.`n`nDon't have the game installed? Click Yes to install it.", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
        if ($choice -eq "Yes") {
            downgrade
        } else {
            return
        }
        if (!(test-path $global:gamePath\bin\win10\echovr.exe)) {
            [System.Windows.Forms.MessageBox]::Show("The game was not installed", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Error)
        }
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
    if (!(Test-Path $env:localappdata\rad-backup)) {
        Copy-Item "$env:localappdata\rad" "$env:localappdata\rad-backup" -Recurse
    }
    if ((Get-FileHash -Path $global:gamePath\bin\win10\echovr.exe).hash -ne "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043") {
        $noUsernameOrPassword.Text = "You are on the wrong version of EchoVR"
        $noUsernameOrPassword.Visible = $true
        $choice = [System.windows.forms.messagebox]::show("You are on the wrong version of EchoVR, would you like to downgrade?" , "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
        if ($choice -eq "Yes") {
            downgrade
        } else {
            return
        }
    }
    if ((Get-FileHash -Path $global:gamePath\bin\win10\echovr.exe).hash -ne "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043") {
        [system.windows.forms.messagebox]::Show("The game was not downgraded, please try again.", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Information)
        return
    }
    mkdir "$env:appdata\Echo Relay Server Browser\"
    $config = @{}
    $config | Add-Member -Name 'username' -Type NoteProperty -Value "$($usernameBox.text)"
    $config | Add-Member -Name 'password' -Type NoteProperty -Value "$($passwordBox.text)"
    $config | Add-Member -Name 'gamePath' -Type NoteProperty -Value "$($global:gamePath)"
    $config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
    Invoke-WebRequest "https://aldin101.github.io/echo-relay-server-browser/Echo%20Relay%20Server%20Browser.exe" -OutFile "$global:gamePath\bin\win10\Echo Relay Server Browser.exe"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Echo Relay Server Browser.lnk")
    $Shortcut.TargetPath = "$global:gamePath\bin\win10\Echo Relay Server Browser.exe"
    $Shortcut.Save()
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Echo VR.lnk")
    $Shortcut.TargetPath = "$global:gamePath\bin\win10\EchoVR.exe"
    $Shortcut.Save()
    [system.windows.forms.messagebox]::Show("Echo Relay Successfully Installed", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Information)
    start-process "$global:gamePath\bin\win10\Echo Relay Server Browser.exe"
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

$currentPath = New-Object System.Windows.Forms.Label
if (!(test-path "C:\Program Files\Oculus\Software\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe")) {
    $currentPath.Text = "Current Game Folder:`nPlease Select Game Folder"
    $selectGameFolder = New-Object System.Windows.Forms.Button
    $selectGameFolder.Location = New-Object System.Drawing.Size(10,220)
    $selectGameFolder.Size = New-Object System.Drawing.Size(200,30)
    $selectGameFolder.Text = "Select Game Folder"
    $selectGameFolder.Font = "Microsoft Sans Serif,10"
    $selectGameFolder.Add_Click({
        $locations = Get-ChildItem "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\*"
        $locationList = [System.Collections.ArrayList]@()
        foreach ($location in $locations) {
            $locationList.Add($(Get-ItemProperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\$($location.PSChildName)" -Name OriginalPath | select -ExpandProperty OriginalPath))
        }
        $locations = [system.Collections.ArrayList]@()
        foreach ($location in $locationList) {
            if (test-path "$location\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe") {
                $locations.Add($location)
            }
        }
        $pickMenu = new-object System.Windows.Forms.Form
        $pickMenu.text = "Echo Relay Installer"
        $pickMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
        $pickMenu.Size = New-Object Drawing.Size @(320, 270)
        $pickMenu.StartPosition = "CenterScreen"
        $pickMenu.FormBorderStyle = "FixedDialog"
        $pickMenu.MaximizeBox = $false
        $pickMenu.ShowInTaskbar = $false

        $pickLabel = New-Object System.Windows.Forms.Label
        $pickLabel.Location = New-Object System.Drawing.Size(10,10)
        $pickLabel.Size = New-Object System.Drawing.Size(280,20)
        $pickLabel.Text = "Select folder Echo VR is located in"
        $pickLabel.TextAlign = "MiddleCenter"
        $pickLabel.Font = "Microsoft Sans Serif,10"
        $pickMenu.Controls.Add($pickLabel)

        $pickList = New-Object System.Windows.Forms.ListBox
        $pickList.Location = New-Object System.Drawing.Size(10,30)
        $pickList.Size = New-Object System.Drawing.Size(280,100)
        $pickList.Font = "Microsoft Sans Serif,10"
        $pickList.DataSource = $locationList
        $pickList.SelectedIndex = $i
        $pickMenu.Controls.Add($pickList)

        $customPath = New-Object System.Windows.Forms.Button
        $customPath.Location = New-Object System.Drawing.Size(10,140)
        $customPath.Size = New-Object System.Drawing.Size(280,30)
        $customPath.Text = "Custom Path"
        $customPath.Font = "Microsoft Sans Serif,10"
        $customPath.Add_Click({
            $choice = [System.Windows.Forms.MessageBox]::Show("It is recommended that you use the pre-selected folder so that the Oculus app launches the correct version of the game.`n`n`While you can use a custom path it is not recommended. Would you still like to use a custom path?", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                return
            }
            $global:gamePath = Read-FolderBrowserDialog -Message "Select the folder Echo VR is installed in"
            if (!(test-path "$global:gamePath\bin\win10\echovr.exe")) {
                [System.Windows.Forms.MessageBox]::show("Please select a valid game folder", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
                return
            }
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($customPath)

        $pickButton = New-Object System.Windows.Forms.Button
        $pickButton.Location = New-Object System.Drawing.Size(10,180)
        $pickButton.Size = New-Object System.Drawing.Size(280,30)
        $pickButton.Text = "Select"
        $pickButton.Font = "Microsoft Sans Serif,10"
        $pickButton.Add_Click({
            if (!(test-path "$($locations[$picklist.SelectedIndex])\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe")) {
                [System.Windows.Forms.MessageBox]::show("Please select a valid game folder", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
                return
            }
            $global:gamePath = "$($pickList.SelectedItem)\Software\ready-at-dawn-echo-arena"
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($pickButton)

        $pickMenu.ShowDialog()
    })
    $menu.Controls.Add($selectGameFolder)
} else {
    $global:gamePath = "C:\Program Files\Oculus\Software\Software\ready-at-dawn-echo-arena"
    $selectGameFolder = New-Object System.Windows.Forms.Button
    $selectGameFolder.Location = New-Object System.Drawing.Size(10,220)
    $selectGameFolder.Size = New-Object System.Drawing.Size(200,30)
    $selectGameFolder.Text = "Select Game Folder"
    $selectGameFolder.Font = "Microsoft Sans Serif,10"
    $selectGameFolder.Add_Click({
        $locations = Get-ChildItem "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\*"
        $locationList = [System.Collections.ArrayList]@()
        foreach ($location in $locations) {
            $locationList.Add($(Get-ItemProperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\$($location.PSChildName)" -Name OriginalPath | select -ExpandProperty OriginalPath))
        }
        $locations = [system.Collections.ArrayList]@()
        foreach ($location in $locationList) {
            if (test-path "$location\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe") {
                $locations.Add($location)
            }
        }
        $pickMenu = new-object System.Windows.Forms.Form
        $pickMenu.text = "Echo Relay Installer"
        $pickMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
        $pickMenu.Size = New-Object Drawing.Size @(320, 270)
        $pickMenu.StartPosition = "CenterScreen"
        $pickMenu.FormBorderStyle = "FixedDialog"
        $pickMenu.MaximizeBox = $false
        $pickMenu.ShowInTaskbar = $false

        $pickLabel = New-Object System.Windows.Forms.Label
        $pickLabel.Location = New-Object System.Drawing.Size(10,10)
        $pickLabel.Size = New-Object System.Drawing.Size(280,20)
        $pickLabel.Text = "Select folder Echo VR is located in"
        $pickLabel.TextAlign = "MiddleCenter"
        $pickLabel.Font = "Microsoft Sans Serif,10"
        $pickMenu.Controls.Add($pickLabel)

        $pickList = New-Object System.Windows.Forms.ListBox
        $pickList.Location = New-Object System.Drawing.Size(10,30)
        $pickList.Size = New-Object System.Drawing.Size(280,100)
        $pickList.Font = "Microsoft Sans Serif,10"
        $pickList.DataSource = $locationList
        $pickList.SelectedIndex = $i
        $pickMenu.Controls.Add($pickList)

        $customPath = New-Object System.Windows.Forms.Button
        $customPath.Location = New-Object System.Drawing.Size(10,140)
        $customPath.Size = New-Object System.Drawing.Size(280,30)
        $customPath.Text = "Custom Path"
        $customPath.Font = "Microsoft Sans Serif,10"
        $customPath.Add_Click({
            $choice = [System.Windows.Forms.MessageBox]::Show("It is recommended that you use the pre-selected folder so that the Oculus app launches the correct version of the game.`n`n`While you can use a custom path it is not recommended. Would you still like to use a custom path?", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                return
            }
            $global:gamePath = Read-FolderBrowserDialog -Message "Select the folder Echo VR is installed in"
            if (!(test-path "$global:gamePath\bin\win10\echovr.exe")) {
                [System.Windows.Forms.MessageBox]::show("Please select a valid game folder", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
                return
            }
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($customPath)

        $pickButton = New-Object System.Windows.Forms.Button
        $pickButton.Location = New-Object System.Drawing.Size(10,180)
        $pickButton.Size = New-Object System.Drawing.Size(280,30)
        $pickButton.Text = "Select"
        $pickButton.Font = "Microsoft Sans Serif,10"
        $pickButton.Add_Click({
            if (!(test-path "$($locations[$picklist.SelectedIndex])\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe")) {
                [System.Windows.Forms.MessageBox]::show("Please select a valid game folder", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
                return
            }
            $global:gamePath = "$($pickList.SelectedItem)\Software\ready-at-dawn-echo-arena"
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($pickButton)

        $pickMenu.ShowDialog()
    })
    $currentPath.Text = "Current Game Folder:`n$global:gamePath"
    $menu.Controls.Add($selectGameFolder)
}
$currentPath.Location = New-Object System.Drawing.Size(10,250)
$currentPath.Size = New-Object System.Drawing.Size(2000,200)
$currentPath.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($currentPath)

$menu.ShowDialog()


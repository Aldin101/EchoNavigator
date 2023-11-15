$ProgressPreference = 'SilentlyContinue'
$file = Invoke-WebRequest https://aldin101.github.io/Echo-Relay-Installer/host.json -UseBasicParsing
$global:database = $file.Content | ConvertFrom-Json
function Read-FolderBrowserDialog([string]$Message, [string]$InitialDirectory) {
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, 0, $InitialDirectory)
    if ($folder) { return $folder.Self.Path } else { return 'C:\Program Files\Oculus\Software\Software' }
}
function downgradeInstructionsPage3 {
    $next.text = "Finish!"
    $troubleshootingButton.Visible = $false
    $startUpPage.Text = "After the game has finished downloading press Y and hit enter for the first`nprompt to backup the game files and launch.`nSimply press enter again to select the backup location.`nPress Y and then enter to launch the game to make sure it works`nOnce you are done press the finish key once you are done to attempt`ninstallation for Echo Relay."
}

function troubleshooting {
    $next.visible = $false
    $troubleshootingButton.Visible = $false
    $previous.visible = $false
    $backButton.Visible = $true
    $startUpPage.text = "One or more of the files failed to validate:`nOn the main menu press 7 then enter, type `"D`" and hit enter`nType echo vr and hit enter,`nType 34.4.631547.1 and hit enter, press Y and hit enter`nWait for the download to finish.`nPress the 3 key to open the launch menu and continue with the next step."
}

function downgradeInstructionsPage2 {
    $next.text = "Next" 
    $troubleshootingButton.Visible = $true
    $startUpPage.Text = "Then press the 2 key and hit enter.`nSearch for `"echo vr`".`nThen paste `"34.4.631547.1`" into the field using crtl+v (copied to clipboard) and`nhit enter.`nThen press Y and hit enter and wait for the download to finish`nIf the download gives errors click the troubleshooting button."
    Set-Clipboard "34.4.631547.1"
}

function downgradeInstructionsPage1 {
    $troubleshootingButton.Visible = $false
    $previous.visible = $true
    $startUpPage.Text = "After the Oculus Downgrader has launched press Y and hit enter`nThen press any key and log into your Meta account.`nThen enter a password to secure your Meta account token"
}

function downgradeInstructionsPage0 {
    $startUpPage.Text = "These are instructions on how to downgrade your EchoVR client to the correct`nversion for Echo Relay.`nSimply move this window open next to the downgrader.`nPress next to go to the next step."
}

function downgradeInstructions {
    $menu.Hide()
    $downgradeMenu.Hide()

    $downgradeInstructions = new-object System.Windows.Forms.Form
    $downgradeInstructions.text = "Echo Relay Downgrader"
    $downgradeInstructions.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
    $downgradeInstructions.Size = New-Object Drawing.Size @(500, 300)
    $downgradeInstructions.Location = New-Object System.Drawing.Size(1200, 400)
    $downgradeInstructions.StartPosition = "Manual"
    $downgradeInstructions.FormBorderStyle = "FixedDialog"
    $downgradeInstructions.MaximizeBox = $false

    $downgradeInstructionsLabel = New-Object System.Windows.Forms.Label
    $downgradeInstructionsLabel.Location = New-Object System.Drawing.Size(10,10)
    $downgradeInstructionsLabel.Size = New-Object System.Drawing.Size(2000,20)
    $downgradeInstructionsLabel.Text = "EchoVR Downgrade Instructions"
    $downgradeInstructionsLabel.Font = "Microsoft Sans Serif,10"
    $downgradeInstructions.Controls.Add($downgradeInstructionsLabel)

    $next = New-Object System.Windows.Forms.Button
    $next.Location = New-Object System.Drawing.Size(400,225)
    $next.Text = "Next"
    $next.Font = "Microsoft Sans Serif,10"
    $downgradeInstructions.Controls.Add($next)

    $previous = New-Object System.Windows.Forms.Button
    $previous.Location = New-Object System.Drawing.Size(320,225)
    $previous.Text = "Previous"
    $previous.Font = "Microsoft Sans Serif,10"
    $previous.Visible = $false
    $downgradeInstructions.Controls.Add($previous)

    $troubleshootingButton = New-Object System.Windows.Forms.Button
    $troubleshootingButton.Location = New-Object System.Drawing.Size(10,225)
    $troubleshootingButton.Size = New-Object System.Drawing.Size(200,30)
    $troubleshootingButton.Text = "Troubleshooting"
    $troubleshootingButton.Font = "Microsoft Sans Serif,10"
    $troubleshootingButton.Visible = $false
    $troubleshootingButton.Add_Click({
        $troubleshootingButton.Visible = $false
        troubleshooting
    })
    $downgradeInstructions.Controls.Add($troubleshootingButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location =  New-Object System.Drawing.Size(400,225)
    $backButton.Text = "Back"
    $backButton.Font = "Microsoft Sans Serif,10"
    $backButton.Visible = $false
    $backButton.Add_Click({
        $backButton.Visible = $false
        $next.Visible = $true
        $previous.Visible = $true
        $troubleshootingButton.Visible = $true
        $startUpPage.Text = "Then press the 2 key and hit enter.`nSearch for `"echo vr`".`nThen paste `"34.4.631547.1`" into the field using crtl+v (copied to clipboard) and`nhit enter.`nThen press Y and hit enter and wait for the download to finish`nIf the download gives errors click the troubleshooting button."
    })
    $downgradeInstructions.Controls.Add($backButton)

    $startUpPage = New-Object System.Windows.Forms.Label
    $startUpPage.Location = New-Object System.Drawing.Size(10,40)
    $startUpPage.Size = New-Object System.Drawing.Size(2000,150)
    $startUpPage.Text = "These are instructions on how to downgrade your EchoVR client to the correct`nversion for Echo Relay.`nSimply move this window open next to the downgrader.`nPress next to go to the next step."
    $startUpPage.Font = "Microsoft Sans Serif,10"
    $downgradeInstructions.Controls.Add($startUpPage)

    $global:currentPage = 0

    $next.Add_Click({
        switch ($global:currentPage) {
            0 { downgradeInstructionsPage1; $global:currentPage = 1 }
            1 { downgradeInstructionsPage2; $global:currentPage = 2 }
            2 { downgradeInstructionsPage3; $global:currentPage = 3 }
            3 { $downgradeInstructions.Close(); $global:currentPage = 4 }
        }
    })

    $previous.Add_Click({
        switch ($global:currentPage) {
            1 { downgradeInstructionsPage0; $global:currentPage = 0; $previous.visible = $false }
            2 { downgradeInstructionsPage1; $global:currentPage = 1 }
            3 { downgradeInstructionsPage2; $global:currentPage = 2 }
            4 { downgradeInstructionsPage3; $global:currentPage = 3 }
        }
    })

    $downgradeInstructions.ShowDialog()
    $menu.Show()
}

function downgrade {
    $downgradeOptions.Hide()
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
        $downgradeButton.text = "Downloading..."
        $downgradeInstaller = "https://github.com/ComputerElite/Oculus-downgrader/releases/download/1.11.36/net6.0.1.zip"
        $downgradePath = "$env:temp\downgrader.zip"
        Invoke-WebRequest -Uri $downgradeInstaller -OutFile $downgradePath
        Expand-Archive -Path $downgradePath -DestinationPath $env:USERPROFILE\downgrader -force
        Invoke-WebRequest -Uri "https://msedgedriver.azureedge.net/118.0.2088.76/edgedriver_win64.zip" -OutFile "$env:temp\edgedriver.zip"
        Expand-Archive -Path "$env:temp\edgedriver.zip" -DestinationPath "$env:USERPROFILE\downgrader" -force
        Start-Process "$env:USERPROFILE\downgrader\Oculus Downgrader"
        start-sleep -s 1
        if ((get-process "Oculus Downgrader") -eq $null) {
            $downgradeButton.text = "Downgrade"
            $noDotNET.Visible = $true
        } else {
            downgradeInstructions
            while ((get-process "Oculus Downgrader") -ne $null) {
                [System.Windows.Forms.MessageBox]::show("Oculus Downgrader is still running, please close it before continuing", "Echo Relay Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
            }
        }
        del $env:USERPROFILE\downgrader -recurse -force
    })
    $downgradeMenu.Controls.Add($downgradeButton)

    $installdotNET = New-Object System.Windows.Forms.Button
    $installdotNET.Location = New-Object System.Drawing.Size(10,70)
    $installdotNET.Size = New-Object System.Drawing.Size(200,30)
    $installdotNET.Text = "Install .NET 6.0"
    $installdotNET.Font = "Microsoft Sans Serif,10"
    $installdotNET.Add_Click({
        $dotNETInstaller = "https://download.visualstudio.microsoft.com/download/pr/1ac0b57e-cf64-487f-aecf-d7df0111fd56/2484cbe1ffacceacaa41eab92a6de998/dotnet-runtime-6.0.3-win-x64.exe"
        $dotNETInstallerPath = "$env:temp\dotNETInstaller.exe"
        $installdotNET.text = "Downloading..."
        Invoke-WebRequest -Uri $dotNETInstaller -OutFile $dotNETInstallerPath
        $installDotNET.text = "Accept Prompt"
        try {
            Start-Process $dotNETInstallerPath -verb runAs -ArgumentList "/install /quiet /norestart"
        } catch {
            $noDotNET.Visible = $true
            $installdotNET.text = "Install .NET 6.0"
            return
        }
        $installDotNET.text = "Installing..."
        start-sleep -s 3
        $noDotNET.Visible = $false
        $installdotNET.text = "Install .NET 6.0"
    })
    $downgradeMenu.Controls.Add($installdotNET)

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

function entitlement {
    $downgradeOptions.Hide()
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


    $installProgress = New-Object System.Windows.Forms.ProgressBar
    $installProgress.Location = New-Object System.Drawing.Size(10,100)
    $installProgress.Size = New-Object System.Drawing.Size(200,10)
    $installProgress.Style = "Continuous"
    $installProgress.Maximum = 100
    $installProgress.minimum = 0
    $installProgress.Value = 0
    $installProgress.Visible = $false
    $downgradeMenu.Controls.Add($installProgress)

    $folderPicker = New-Object System.Windows.Forms.Button
    $folderPicker.Location = New-Object System.Drawing.Size(10,30)
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

    $downgradeButton = New-Object System.Windows.Forms.Button
    $downgradeButton.Location = New-Object System.Drawing.Size(10,70)
    $downgradeButton.Size = New-Object System.Drawing.Size(200,30)
    $downgradeButton.Text = "Install"
    $downgradeButton.Font = "Microsoft Sans Serif,10"
    $downgradeButton.Add_Click({

        if ($global:gamePath -eq $null) {
            [System.Windows.Forms.MessageBox]::show("Please select a valid game folder", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
            return
        }

        if ((Get-PSDrive -name "C").free/1GB -lt 15) {
            [System.Windows.Forms.MessageBox]::show("You do not have enough space on your C drive to install the game, you need 15 gigs of total free space (although only 5 gigs are used after installation finishes).`n`nThe Oculus Downgrader requires less total storage space although it is harder to do. If you can not free up 15 gigs of space use that instead.", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Error)
            return
        }

        $doNotExitLabel = New-Object System.Windows.Forms.Label
        $doNotExitLabel.Location = New-Object System.Drawing.Size(10,115)
        $doNotExitLabel.Size = New-Object System.Drawing.Size(2000,200)
        $doNotExitLabel.Text = "Do not exit the installer until it is finished`neven if it is `"not responding`""
        $doNotExitLabel.Font = "Microsoft Sans Serif,10"
        $downgradeMenu.Controls.Add($doNotExitLabel)

        $downgradeButton.enabled = $false
        $downgradeButton.text = "Downloading..."
        $installProgress.Visible = $true

        if (test-path "$global:gamePath\bin") {
            cd $global:gamePath
            cd..
            $global:gamePath = (get-location).Path
            cd $script:psscriptroot
        }

        $job = Start-Job -ScriptBlock {
            $uri = New-Object "System.Uri" 'https://onedrive.live.com/download?resid=357F7C1400A6848C%2117825&authkey=!AKUWYYZNia0l9Ig'
            $request = [System.Net.HttpWebRequest]::Create($uri)
            $request.set_Timeout(15000)
            $response = $request.GetResponse()
            $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
            $responseStream = $response.GetResponseStream()
            $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $env:temp\evr.key, Create
            $buffer = new-object byte[] 10KB
            $count = $responseStream.Read($buffer,0,$buffer.length)
            $downloadedBytes = $count
            while ($count -gt 0)    {
                [System.Console]::CursorLeft = 0
                [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
                $targetStream.Write($buffer, 0, $count)
                $count = $responseStream.Read($buffer,0,$buffer.length)
                $downloadedBytes = $downloadedBytes + $count
            }
            $targetStream.Flush()
            $targetStream.Close()
            $targetStream.Dispose()
            $responseStream.Dispose()
        }

        while ($job.State -eq 'Running') {
            $installProgress.Value = (((Get-Item "$env:temp\evr.key").length / 5026903423) * 100)
            start-sleep -Milliseconds 10
        }

        Remove-Job -Job $job

        Start-Sleep -Seconds 3
        $downgradeButton.text = "Decrypting..."

        Add-Type -AssemblyName System.Security
        $job = start-job {
            $inputFilePath = "$env:temp\evr.key"
            $outputFilePath = "$env:temp\evr.zip"
            $key = [Text.Encoding]::UTF8.GetBytes("echoreplaygamefi")
            $iv = [Text.Encoding]::UTF8.GetBytes("echoreplaygamefi")
            $rijAlg = New-Object System.Security.Cryptography.RijndaelManaged
            $rijAlg.Key = $key
            $rijAlg.IV = $iv
            $decryptor = $rijAlg.CreateDecryptor($rijAlg.Key, $rijAlg.IV)
            $inFileStream = New-Object System.IO.FileStream($inputFilePath, [IO.FileMode]::Open, [IO.FileAccess]::Read)
            $outFileStream = New-Object System.IO.FileStream($outputFilePath, [IO.FileMode]::Create, [IO.FileAccess]::Write)
            $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($inFileStream, $decryptor, [Security.Cryptography.CryptoStreamMode]::Read)
            $buffer = New-Object byte[](4096)
            while (($read = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outFileStream.Write($buffer, 0, $read)
            }
            $cryptoStream.Close()
            $outFileStream.Close()
            $inFileStream.Close()
            $inFileStream.Dispose()
            $outFileStream.Dispose()
            $cryptoStream.Dispose()
        }

        while ($job.State -eq "Running") {
            $installProgress.Value = (((Get-Item "$env:temp\evr.zip").length / 5026903423) * 100)
            start-sleep -Milliseconds 10
        }

        remove-job -job $job

        $downgradeButton.text = "Verifying..."
        start-sleep -s 3
        if ((Get-FileHash $env:temp\evr.zip -algorithm md5).Hash -ne "AE45FCE4C45D38B0B03EFE46B5E7EC84") {
            $downgradeButton.text = "Try again"
            $installProgress.Visible = $false
            $downgradeButton.enabled = $true
            [System.Windows.Forms.MessageBox]::show("The download failed, please try again", "Echo Relay Downgrader", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
            return
        }
        $downgradeButton.text = "Extracting..."
        $installProgress.visible = $false
        start-sleep -s 3
        $job = start-job {
            param($global:gamePath)
            Expand-Archive -Path $env:temp\evr.zip -DestinationPath $global:gamePath -force
        } -ArgumentList $global:gamePath

        while ($job.State -eq "Running") {
            start-sleep -seconds 1
        }

        remove-job -job $job

        $downgradeButton.text = "Patching..."
        Invoke-WebRequest https://echo-foundation.pages.dev/files/offline_echo/pnsovr.dll -outFile $global:gamePath\ready-at-dawn-echo-arena\bin\win10\pnsovr.dll
        del $env:temp\evr.zip
        del $env:temp\evr.key
        $global:gamePath = "$global:gamePath\ready-at-dawn-echo-arena"
        $downgradeButton.text = "Finished!"
        start-sleep -s 3
        $downgradeMenu.Close()
    })
    $downgradeMenu.Controls.Add($downgradeButton)

    $downgradeMenu.ShowDialog()
    $menu.Show()
    return
}
function downgradeOptions {
    $downgradeOptions = new-object System.Windows.Forms.Form
    $downgradeOptions.text = "Echo Relay Downgrader"
    $downgradeOptions.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
    $downgradeOptions.Size = New-Object Drawing.Size @(460, 120)
    $downgradeOptions.StartPosition = "CenterScreen"
    $downgradeOptions.FormBorderStyle = "FixedDialog"
    $downgradeOptions.MaximizeBox = $false
    $downgradeOptions.ShowInTaskbar = $false

    $downgradeLabel = New-Object System.Windows.Forms.Label
    $downgradeLabel.Location = New-Object System.Drawing.Size(80,10)
    $downgradeLabel.Size = New-Object System.Drawing.Size(2000,20)
    $downgradeLabel.Text = "What downgrade method would you like to use?"
    $downgradeLabel.Font = "Microsoft Sans Serif,10"
    $downgradeOptions.Controls.Add($downgradeLabel)

    $Oculus = New-Object System.Windows.Forms.Button
    $Oculus.Location = New-Object System.Drawing.Size(10,30)
    $Oculus.Size = New-Object System.Drawing.Size(200,30)
    $Oculus.Text = "Oculus Downgrader"
    $Oculus.Font = "Microsoft Sans Serif,10"
    $Oculus.Add_Click({downgrade})
    $downgradeOptions.Controls.Add($Oculus)

    $entitlement = new-object System.Windows.Forms.Button
    $entitlement.Location = New-Object System.Drawing.Size(230,30)
    $entitlement.Size = New-Object System.Drawing.Size(200,30)
    $entitlement.Text = "Entitlement Bypass"
    $entitlement.Font = "Microsoft Sans Serif,10"
    $entitlement.Add_Click({entitlement})
    $downgradeOptions.Controls.Add($entitlement)

    $recommended = New-Object System.Windows.Forms.Label
    $recommended.Location = New-Object System.Drawing.Size(285,60)
    $recommended.Size = New-Object System.Drawing.Size(2000,20)
    $recommended.Text = "(recommended)"
    $recommended.Font = "Microsoft Sans Serif,10"
    $downgradeOptions.Controls.Add($recommended)


    $downgradeOptions.ShowDialog()
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
            downgradeOptions
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
            downgradeOptions
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
start-sleep -s 3

$menu.ShowDialog()


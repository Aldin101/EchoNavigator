$startdelaystopwatch = [System.Diagnostics.Stopwatch]::StartNew()

function StartLogin {
    $payload = @{
        "access_token" = "FRL|512466987071624|01d4a1f7fd0682aea7ee8ae987704d63"
    }
    $loginResponse = Invoke-RestMethod -Method Post -Uri "https://meta.graph.meta.com/webview_tokens_query" -Body (ConvertTo-Json $payload) -ContentType "application/json"
    $etoken = $loginResponse.native_sso_etoken
    $global:token = $loginResponse.native_sso_token
    return "https://auth.meta.com/native_sso/confirm?native_app_id=512466987071624&native_sso_etoken=$etoken&utm_source=skyline_splash"
}

function GetToken {
    $payload = @{
        "access_token" = "FRL|512466987071624|01d4a1f7fd0682aea7ee8ae987704d63"
        "blob" = $global:blob
        "request_token" = $global:token
    }
    $response = Invoke-RestMethod -Method Post -Uri "https://meta.graph.meta.com/webview_blobs_decrypt" -Body (ConvertTo-Json $payload) -ContentType "application/json"
    $firstToken = $response.access_token
    $c = @{
        "uri" = $oculusUri
        "options" = @{
            "access_token" = if ($firstToken -ne "") { $firstToken } else { "OC|752908224809889|" }
            "doc_id" = "5787825127910775"
            "variables" = "{`"app_id`":`"1582076955407037`"}"
        }
    }
    $response = Invoke-RestMethod -Method Post -Uri "https://meta.graph.meta.com/graphql" -Body (ConvertTo-Json $c.options) -ContentType "application/json"
    return $response.data.xfr_create_profile_token.profile_tokens[0].access_token
}

function UriCallback {
    param (
        $response
    )

    $parameters = $response.Replace("oculus://", "").Split('?')[1].Split('&')
    $global:blob = $parameters[1].Split('=')[1]
    return GetToken
}

function questPatcher {
    $global:gamePatched = $false

    $global:questPatcherMenu = New-Object System.Windows.Forms.Form
    $questPatcherMenu.Text = "Echo Navigator"
    $questPatcherMenu.Size = New-Object System.Drawing.Size(300,200)
    $questPatcherMenu.StartPosition = "CenterScreen"
    $questPatcherMenu.FormBorderStyle = "FixedDialog"
    $questPatcherMenu.MaximizeBox = $false
    $questPatcherMenu.showInTaskbar = $false
    $questPatcherMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)

    $global:questPatcherLabel = New-Object System.Windows.Forms.Label
    $questPatcherLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $questPatcherLabel.Location = New-Object System.Drawing.Point(10, 10)
    $questPatcherLabel.Text = "Echo Navigator Quest Patcher"
    $questPatcherLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $questPatcherMenu.Controls.Add($questPatcherLabel)

    $global:installProgress = New-Object System.Windows.Forms.ProgressBar
    $installProgress.Location = New-Object System.Drawing.Size(10,100)
    $installProgress.Size = New-Object System.Drawing.Size(200,10)
    $installProgress.Style = "Continuous"
    $installProgress.Maximum = 100
    $installProgress.minimum = 0
    $installProgress.Value = 0
    $installProgress.Visible = $false
    $questPatcherMenu.Controls.Add($installProgress)

    $global:timeRemainingLabel = New-Object System.Windows.Forms.Label
    $timeRemainingLabel.Location = New-Object System.Drawing.Size(10, 110)
    $timeRemainingLabel.Size = New-Object System.Drawing.Size(200,20)
    $timeRemainingLabel.Text = "Time Till Cancel Option: 1:00"
    $timeRemainingLabel.Font = "Microsoft Sans Serif,10"
    $timeRemainingLabel.Visible = $false
    $downgradeMenu.Controls.Add($timeRemainingLabel)

    $global:patchEchoVR = New-Object System.Windows.Forms.Button
    $patchEchoVR.Size = New-Object System.Drawing.Size(200, 35)
    $patchEchoVR.Location = New-Object System.Drawing.Point(10, 60)
    $patchEchoVR.Text = "Patch Echo VR"
    $patchEchoVR.add_click({
        $patchEchoVR.Enabled = $false
        if (!(test-path "$env:appdata\EchoNavigator\setUpFinished.set")) {

            $patchEchoVR.text = "Waiting for login..."
            $patchEchoVR.Refresh()

            $registryPath = "HKCU\SOFTWARE\Classes\oculus"
            $backupPath = "$env:appdata\EchoNavigator\oculus.reg"

            if (Test-Path $backupPath) {
                reg import $backupPath
                Remove-Item $backupPath
            }

            reg export $registryPath $backupPath


            New-Item -Path "HKCU:\Software\Classes\Oculus"
            Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus" -Name "URL Protocol" -Value ""
            Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus" -Name "(Default)" -Value "URL:Oculus Protocol"
            New-Item -Path "HKCU:\Software\Classes\Oculus\shell\open\command"
            Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus\shell\open\command" -Name "(Default)" -Value "`"powershell.exe`" -executionPolicy bypass -windowStyle hidden -file $("$env:appdata\EchoNavigator\setToken.ps1") `%1"

            'param($keys)' | Out-File -FilePath "$env:appdata\EchoNavigator\setToken.ps1"
            '$keys | Out-File -FilePath "$env:appdata\EchoNavigator\token"' | Out-File -FilePath "$env:appdata\EchoNavigator\setToken.ps1" -Append
            '[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")' | Out-File -FilePath "$env:appdata\EchoNavigator\setToken.ps1" -Append
            '[System.Windows.Forms.Application]::EnableVisualStyles()' | Out-File -FilePath "$env:appdata\EchoNavigator\setToken.ps1" -Append
            '[System.Windows.Forms.MessageBox]::show("You have successfully logged in. You can close your browser and return to Echo Navigator", "Echo Navigator Downgrader","OK", "Information")' | Out-File -FilePath "$env:appdata\EchoNavigator\setToken.ps1" -Append

            Start-Process "$(StartLogin)"

            while (1) {
                $startTime = Get-Date
                while (!(test-path "$env:appdata\EchoNavigator\token") -and ((Get-Date) -lt ($startTime.AddMinutes(1)))) {
                    start-sleep -Milliseconds 100
                    $timeRemainingLabel.Visible = $true
                    $timeRemainingLabel.Text = "Time Till Cancel Option: $((($startTime.AddMinutes(1)) - (Get-Date)).Minutes):$((($startTime.AddMinutes(1)) - (Get-Date)).Seconds)"
                }

                if (!(test-path "$env:appdata\EchoNavigator\token")) {
                    $choice = [System.Windows.Forms.MessageBox]::show("Looks like you have been logging in for a while, would you like to cancel the login?", "Echo Navigator Downgrader","YesNo", "Question")
                    if ($choice -eq "Yes") {
                        if (Test-Path $backupPath) {
                            reg import $backupPath
                            Remove-Item $backupPath
                        }
                        $patchEchoVR.text = "Try again"
                        $patchEchoVR.enabled = $true
                        $timeRemainingLabel.Visible = $false
                        return
                    }
                } else {
                    break
                }
            }
            $timeRemainingLabel.Visible = $false
            $patchEchoVR.text = "Logging in..."

            $tokenFile = get-content "$env:appdata\EchoNavigator\token"
            remove-item "$env:appdata\EchoNavigator\token"
            remove-item "$env:appdata\EchoNavigator\setToken.ps1"
            $frl = UriCallback $tokenFile

            $patchEchoVR.text = "Downloading obb..."
            $patchEchoVR.Refresh()
            $installProgress.Visible = $true
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = "oc_www_at"
            $cookie.Value = $frl
            $cookie.Domain = "oculus.com"
            $cookie.Path = "/"
            $job = start-job {
                param($cookie)
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie.ToString())
                $webClient.DownloadFile("https://securecdn.oculus.com/binaries/download/?id=6528312897208382", "$env:appdata\EchoNavigator\main.4987566.com.readyatdawn.r15.obb")
            } -ArgumentList $cookie
            $installProgress.Value = 0
            while ($job.state -ne "Completed") {
                $installProgress.Value = (((Get-Item "$env:appdata\EchoNavigator\main.4987566.com.readyatdawn.r15.obb").length / 946094131) * 100)
                start-sleep -Milliseconds 100
            }
            remove-job $job
            $patchEchoVR.text = "Downloading apk..."
            $patchEchoVR.Refresh()
            $job = start-job {
                param($cookie)
                $webClient = New-Object System.Net.WebClient
                $webClient.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie.ToString())
                $webClient.DownloadFile("https://securecdn.oculus.com/binaries/download/?id=6528386917200980", "$env:appdata\EchoNavigator\r15_goldmaster_store.apk")
            } -ArgumentList $cookie
            $installProgress.Value = 0
            while ($job.state -ne "Completed") {
                $installProgress.Value = (((Get-Item "$env:appdata\EchoNavigator\r15_goldmaster_store.apk").length / 96177060) * 100)
                start-sleep -Milliseconds 100
            }
            remove-job $job
            $installProgress.Value = 100
            $patchEchoVR.text = "Verifying..."
            $patchEchoVR.Refresh()
            $installProgress.Visible = $false
            $installProgress.Refresh()
            if ((Get-FileHash "$env:appdata\EchoNavigator\main.4987566.com.readyatdawn.r15.obb" MD5).hash -ne "5CE4C24C4316B77CD4F5C68A4B20A5F6" -or (Get-FileHash "$env:appdata\EchoNavigator\r15_goldmaster_store.apk" MD5).hash -ne "C14C0F68ADB62A4C5DEAEF46D046F872") {
                $jsonData = @{
                    action = "Telemetry"
                    message = "Downloaded files failed verification`n$($error[0])`n$($error[1])"
                } | ConvertTo-Json
                Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData -TimeoutSec 3
                $patchEchoVR.text = "Try again"
                $installProgress.Visible = $false
                $patchEchoVR.enabled = $true
                [System.Windows.Forms.MessageBox]::show("The download failed, please try again", "Echo Navigator", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
                return
            }

            $patchEchoVR.text = "Installing dependencies..."
            Invoke-WebRequest "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile "$env:appdata\EchoNavigator\platform-tools.zip"
            Expand-Archive -Path "$env:appdata\EchoNavigator\platform-tools.zip" -DestinationPath "$env:appdata\EchoNavigator\adb\"

            Invoke-WebRequest "https://github.com/EchoTools/EchoRewind/releases/download/V.1.0.2/EchoRewind.exe" -OutFile "$env:appdata\EchoNavigator\EchoRewind.exe"
            "setup completed" | set-content "$env:appdata\EchoNavigator\setUpFinished.set"
        }
        $patchEchoVR.text = "Patching..."
        $patchEchoVR.Refresh()
        $adb = "$env:appdata\EchoNavigator\adb\platform-tools\adb.exe"
        while (1) {
            $devices = & $adb devices
            $devices = $devices -split "`n"
            if ($devices.count -gt 3) {
                $jsonData = @{
                    action = "Telemetry"
                    message = "One or more devices detected`n$($error[0])`n$($error[1])"
                } | ConvertTo-Json
                Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData -TimeoutSec 3
                $noDevice = [System.Windows.Forms.MessageBox]::show("More than one device detected, make sure only your Quest is connected to your PC. If you have any other Android devices connected is it a possibility that the game will be installed onto the wrong device. Please unplug any devices that you do not need before pressing retry.", "Echo Navigator", [system.windows.forms.messageboxbuttons]::RetryCancel, [system.windows.forms.messageboxicon]::Error)
                if ($noDevice -eq "Cancel") {
                    $patchEchoVR.text = "Try again"
                    $installProgress.Visible = $false
                    $patchEchoVR.enabled = $true
                    return
                }
            } else {
                break
            }
        }
        while (1) {
            $devices = & $adb devices
            $devices = $devices -split "`n"
            if ($devices.count -lt 3) {
                $noDevice = [System.Windows.Forms.MessageBox]::show("No device detected, make sure your Quest is connected to your PC and developer mode and debug mode are enabled (Google: How to enable developer mode on quest).`n`nIf these things have been done check your headset for a USB debugging message.`n`nIf it still is not working try restarting the headset.", "Echo Navigator", [system.windows.forms.messageboxbuttons]::RetryCancel, [system.windows.forms.messageboxicon]::Error)
                if ($noDevice -eq "Cancel") {
                    $patchEchoVR.text = "Try again"
                    $installProgress.Visible = $false
                    $patchEchoVR.enabled = $true
                    return
                }
            } else {
                break
            }
        }
        while (1) {
            $devices = & $adb devices
            if ($devices[1] -like "*unauthorized") {
                $noDevice = [System.Windows.Forms.MessageBox]::show("This computer is unauthorized. Please accept the prompt in your headset then press retry.", "Echo Navigator", [system.windows.forms.messageboxbuttons]::RetryCancel, [system.windows.forms.messageboxicon]::Warning)
                if ($noDevice -eq "Cancel") {
                    $patchEchoVR.text = "Try again"
                    $installProgress.Visible = $false
                    $patchEchoVR.enabled = $true
                    return
                }
            } else {
                break
            }
        }
        remove-item "$env:appdata\EchoNavigator\r15_goldmaster_store_patched.apk"
        & $adb uninstall com.readyatdawn.r15
        & $adb push "$env:appdata\EchoNavigator\main.4987566.com.readyatdawn.r15.obb" "/sdcard/Android/obb/com.readyatdawn.r15/main.4987566.com.readyatdawn.r15.obb"
        $exePath = "$env:appdata\EchoNavigator\EchoRewind.exe"
        $apkPath = "$env:appdata\EchoNavigator\r15_goldmaster_store.apk"
        $arguments = "`"$apkPath`""
        Rename-Item "$env:appdata\EchoNavigator\config.json" "$env:appdata\EchoNavigator\configbak.json"
        Rename-Item "$env:appdata\EchoNavigator\gameConfig.json" "$env:appdata\EchoNavigator\config.json"
        Start-Process -FilePath $exePath -ArgumentList $arguments
        while (!(test-path "$env:appdata\EchoNavigator\r15_goldmaster_store_patched.apk") -and (Get-Process EchoRewind -ErrorAction SilentlyContinue)) {
            start-sleep -Milliseconds 100
        }
        start-sleep -s 1
        if (!(Test-Path "$env:appdata\EchoNavigator\r15_goldmaster_store_patched.apk")) {
            $jsonData = @{
                action = "Telemetry"
                message = "Patched APK not found`n$($error[0])`n$($error[1])"
            } | ConvertTo-Json
            Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData -TimeoutSec 3
            [System.Windows.Forms.MessageBox]::show("Echo Rewind exited but no patched APK could be found. Please try again.", "Echo Navigator", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Error)
            $patchEchoVR.text = "Try again"
            $installProgress.Visible = $false
            $patchEchoVR.enabled = $true
            Remove-Item "$env:appdata\EchoNavigator\config.json"
            Rename-Item "$env:appdata\EchoNavigator\config.json.bak" "$env:appdata\EchoNavigator\config.json"
            return
        }
        taskkill /f /im EchoRewind.exe
        Remove-Item "$env:appdata\EchoNavigator\config.json"
        Rename-Item "$env:appdata\EchoNavigator\configbak.json" "$env:appdata\EchoNavigator\config.json"
        & $adb install "$env:appdata\EchoNavigator\r15_goldmaster_store_patched.apk"
        $questPatcherMenu.Close()
        $global:gamePatched = $true
        $jsonData = @{
            action = "Telemetry"
            message = "Echo VR patched successfully"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData -TimeoutSec 3
    })
    $questPatcherMenu.Controls.Add($patchEchoVR)

    $questPatcherMenu.showDialog()

    remove-item "$env:appdata\EchoNavigator\gameConfig.json"
    $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
}

function joinServer {
    if ($global:config.$($database.online[$global:rowIndex].ip) -eq $null) {
        $usernamePicker = New-Object System.Windows.Forms.Form
        $usernamePicker.Text = "Echo Navigator"
        $usernamePicker.Size = New-Object System.Drawing.Size(280, 150)
        $usernamePicker.StartPosition = "CenterScreen"
        $usernamePicker.FormBorderStyle = "FixedDialog"
        $usernamePicker.showInTaskbar = $false
        $usernamePicker.MaximizeBox = $false
        if ($config.quest -ne $null) {
            $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
        } else {
            $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
        }

        $usernameLabel = New-Object System.Windows.Forms.Label
        $usernameLabel.Size = New-Object System.Drawing.Size(250, 20)
        $usernameLabel.Location = New-Object System.Drawing.Point(10, 10)
        $usernameLabel.Text = "Enter a username for this server"
        $usernameLabel.Font = New-Object System.Drawing.Font("Arial", 12)
        $usernamePicker.Controls.Add($usernameLabel)

        $usernameInput = New-Object System.Windows.Forms.TextBox
        $usernameInput.Size = New-Object System.Drawing.Size(200, 20)
        $usernameInput.Location = New-Object System.Drawing.Point(30, 30)
        $usernameInput.Font = New-Object System.Drawing.Font("Arial", 12)
        $usernameInput.Text = $global:config.username
        $usernamePicker.Controls.Add($usernameInput)

        $usernameButton = New-Object System.Windows.Forms.Button
        $usernameButton.Size = New-Object System.Drawing.Size(200, 35)
        $usernameButton.Location = New-Object System.Drawing.Point(30, 60)
        $usernameButton.Text = "Join Server"

        $usernameButton.add_click({
            $username = $global:config.username
            if ($usernameInput.text -ne "") {
                $username = $usernameInput.Text
            }
            $usernamePicker.Close()
            $usernamePicker.Dispose()
            $usernameButton.Dispose()
            $usernameInput.Dispose()
            $usernameLabel.Dispose()
            $global:config | Add-Member -Name $($database.online[$global:rowIndex].ip) -Type NoteProperty -Value $username
            $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
        })
        $usernamePicker.Controls.Add($usernameButton)

        $usernamePicker.showDialog()
    }

    if ($global:config.$($database.online[$global:rowIndex].ip) -eq $null) {
        [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Navigator", "OK", "Warning")
        return
    }

    $gameConfig = @{}
    $gameConfig | Add-Member -Name 'apiservice_host' -Type NoteProperty -Value "http://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/api"
    $gameConfig | Add-Member -Name 'configservice_host' -Type NoteProperty -Value "ws://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/config"
    $gameConfig | Add-Member -Name 'loginservice_host' -Type NoteProperty -Value "ws://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/login?auth=$($global:config.password)&displayname=$($global:config.$($database.online[$global:rowIndex].ip))"
    $gameConfig | Add-Member -Name 'matchingservice_host' -Type NoteProperty -Value "ws://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/matching"
    $gameConfig | Add-Member -Name 'serverdb_host' -Type NoteProperty -Value "ws://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/serverdb"
    $gameConfig | Add-Member -Name 'transactionservice_host' -Type NoteProperty -Value "ws://$($database.online[$global:RowIndex].ip):$($database.online[$global:RowIndex].port)/transaction"
    $gameConfig | Add-Member -Name 'publisher_lock' -Type NoteProperty -Value 'rad15_live'
    if ($config.quest) {
        $gameConfig | ConvertTo-Json | set-content "$env:appdata\EchoNavigator\gameConfig.json"
        questPatcher
        if ($global:gamePatched) {
            [system.windows.forms.messagebox]::Show("You will now load into $($database.online[$global:rowIndex].name) when you start Echo VR", "Echo Navigator", "OK", "Information")
        }
    } else {
        $gameConfig | convertto-json | set-content "$($global:config.gamePath)\_local\config.json"
    }
    if ($selectPlay.enabled -eq $true) {
        [system.windows.forms.messagebox]::Show("You will now load into $($database.online[$global:rowIndex].name) when you start Echo VR", "Echo Navigator", "OK", "Information")
    }
}

function clientJoinServer {
    if ($global:config.$($config.servers[$global:rowIndex].ip) -eq $null) {
        $usernamePicker = New-Object System.Windows.Forms.Form
        $usernamePicker.Text = "Echo Navigator"
        $usernamePicker.Size = New-Object System.Drawing.Size(280, 150)
        $usernamePicker.StartPosition = "CenterScreen"
        $usernamePicker.FormBorderStyle = "FixedDialog"
        $usernamePicker.showInTaskbar = $false
        $usernamePicker.MaximizeBox = $false
        if ($config.quest -ne $null) {
            $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
        } else {
            $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
        }


        $usernameLabel = New-Object System.Windows.Forms.Label
        $usernameLabel.Size = New-Object System.Drawing.Size(250, 20)
        $usernameLabel.Location = New-Object System.Drawing.Point(10, 10)
        $usernameLabel.Text = "Enter a username for this server"
        $usernameLabel.Font = New-Object System.Drawing.Font("Arial", 12)
        $usernamePicker.Controls.Add($usernameLabel)

        $usernameInput = New-Object System.Windows.Forms.TextBox
        $usernameInput.Size = New-Object System.Drawing.Size(200, 20)
        $usernameInput.Location = New-Object System.Drawing.Point(30, 30)
        $usernameInput.Font = New-Object System.Drawing.Font("Arial", 12)
        $usernameInput.Text = $global:config.username
        $usernamePicker.Controls.Add($usernameInput)

        $usernameButton = New-Object System.Windows.Forms.Button
        $usernameButton.Size = New-Object System.Drawing.Size(200, 35)
        $usernameButton.Location = New-Object System.Drawing.Point(30, 60)
        $usernameButton.Text = "Join Server"

        $usernameButton.add_click({
            $username = $global:config.username
            if ($usernameInput.text -ne "") {
                $username = $usernameInput.Text
            }
            $usernamePicker.Close()
            $usernamePicker.Dispose()
            $usernameButton.Dispose()
            $usernameInput.Dispose()
            $usernameLabel.Dispose()
            $global:config | Add-Member -Name $($global:config.servers[$global:rowIndex].ip) -Type NoteProperty -Value $username
            $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
        })
        $usernamePicker.Controls.Add($usernameButton)

        $usernamePicker.showDialog()
    }

    if ($global:config.$($global:config.servers[$global:rowIndex].ip) -eq $null) {
        [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Navigator", "OK", "Warning")
        return
    }

    $gameConfig = @{}
    $gameConfig | Add-Member -Name 'apiservice_host' -Type NoteProperty -Value "https://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/api"
    $gameConfig | Add-Member -Name 'configservice_host' -Type NoteProperty -Value "ws://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/config"
    $gameConfig | Add-Member -Name 'loginservice_host' -Type NoteProperty -Value "ws://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/login?auth=$($global:config.password)&displayname=$($global:config.$($config.servers[$global:rowIndex].ip))"
    $gameConfig | Add-Member -Name 'matchingservice_host' -Type NoteProperty -Value "ws://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/matching"
    $gameConfig | Add-Member -Name 'serverdb_host' -Type NoteProperty -Value "ws://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/serverdb"
    $gameConfig | Add-Member -Name 'transactionservice_host' -Type NoteProperty -Value "ws://$($global:config.servers[$global:RowIndex].ip):$($global:config.servers[$global:RowIndex].port)/transaction"
    $gameConfig | Add-Member -Name 'publisher_lock' -Type NoteProperty -Value 'rad15_live'
    if ($config.quest) {
        $gameConfig | ConvertTo-Json | set-content "$env:appdata\EchoNavigator\gameConfig.json"
        questPatcher
        if ($global:gamePatched) {
            [system.windows.forms.messagebox]::Show("You will now load into $($config.servers[$global:rowIndex].name) when you start Echo VR", "Echo Navigator", "OK", "Information")
        }
    } else {
        $gameConfig | convertto-json | set-content "$($global:config.gamePath)\_local\config.json"
    }
    if ($selectPlay.enabled -eq $true) {
        [system.windows.forms.messagebox]::Show("You will now load into $($config.servers[$global:rowIndex].name) when you start Echo VR", "Echo Navigator", "OK", "Information")
    }
}

function addOnlineServer {

    if ($database.api -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("The API is not online right now, check back later.", "Echo Navigator", "OK", "Information")
        return
    }

    $addServer = New-Object System.Windows.Forms.Form
    $addServer.Text = "Echo Navigator"
    $addServer.Size = New-Object System.Drawing.Size(330, 500)
    $addServer.StartPosition = "CenterScreen"
    $addServer.FormBorderStyle = "FixedDialog"
    $addServer.MaximizeBox = $false
    if ($config.quest -ne $null) {
        $addServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
    } else {
        $addServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
    }

    $serverNameLabel = New-Object System.Windows.Forms.Label
    $serverNameLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverNameLabel.Location = New-Object System.Drawing.Point(10, 10)
    $serverNameLabel.Text = "Enter a name for the server"
    $serverNameLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverNameLabel)

    $serverNameInput = New-Object System.Windows.Forms.TextBox
    $serverNameInput.Size = New-Object System.Drawing.Size(250, 20)
    $serverNameInput.Location = New-Object System.Drawing.Point(30, 30)
    $serverNameInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverNameInput)

    $serverIPLabel = New-Object System.Windows.Forms.Label
    $serverIPLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverIPLabel.Location = New-Object System.Drawing.Point(10, 60)
    $serverIPLabel.Text = "Enter the IP of the server"
    $serverIPLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverIPLabel)

    $serverIPInput = New-Object System.Windows.Forms.TextBox
    $serverIPInput.Size = New-Object System.Drawing.Size(250, 20)
    $serverIPInput.Location = New-Object System.Drawing.Point(30, 80)
    $serverIPInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverIPInput)

    $serverPortLabel = New-Object System.Windows.Forms.Label
    $serverPortLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPortLabel.Location = New-Object System.Drawing.Point(10, 110)
    $serverPortLabel.Text = "Enter the port of the server"
    $serverPortLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverPortLabel)

    $serverPortInput = New-Object System.Windows.Forms.TextBox
    $serverPortInput.Size = New-Object System.Drawing.Size(250, 20)
    $serverPortInput.Location = New-Object System.Drawing.Point(30, 130)
    $serverPortInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverPortInput)

    $serverDescriptionLabel = New-Object System.Windows.Forms.Label
    $serverDescriptionLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverDescriptionLabel.Location = New-Object System.Drawing.Point(10, 160)
    $serverDescriptionLabel.Text = "Enter a description for the server"
    $serverDescriptionLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverDescriptionLabel)

    $serverDescriptionInput = New-Object System.Windows.Forms.TextBox
    $serverDescriptionInput.Size = New-Object System.Drawing.Size(250, 20)
    $serverDescriptionInput.Location = New-Object System.Drawing.Point(30, 180)
    $serverDescriptionInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverDescriptionInput)

    $serverLongDescriptionLabel = New-Object System.Windows.Forms.Label
    $serverLongDescriptionLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverLongDescriptionLabel.Location = New-Object System.Drawing.Point(10, 210)
    $serverLongDescriptionLabel.Text = "Enter a long description for the server"
    $serverLongDescriptionLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverLongDescriptionLabel)

    $serverLongDescriptionInput = New-Object System.Windows.Forms.TextBox
    $serverLongDescriptionInput.Size = New-Object System.Drawing.Size(250, 100)
    $serverLongDescriptionInput.Location = New-Object System.Drawing.Point(30, 230)
    $serverLongDescriptionInput.Multiline = $true
    $serverLongDescriptionInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverLongDescriptionInput)

    $serverImageLabel = New-Object System.Windows.Forms.Label
    $serverImageLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $serverImageLabel.Location = New-Object System.Drawing.Point(10, 340)
    $serverImageLabel.Text = "Enter a URL for the server image"
    $serverImageLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverImageLabel)

    $serverImageInput = New-Object System.Windows.Forms.TextBox
    $serverImageInput.Size = New-Object System.Drawing.Size(250, 20)
    $serverImageInput.Location = New-Object System.Drawing.Point(30, 360)
    $serverImageInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServer.Controls.Add($serverImageInput)

    $serverButton = New-Object System.Windows.Forms.Button
    $serverButton.Size = New-Object System.Drawing.Size(250, 35)
    $serverButton.Location = New-Object System.Drawing.Point(30, 400)
    $serverButton.Text = "Add Server"
    $serverButton.add_click({
        if ($psversiontable.psversion.major -eq 7) {
            [system.windows.forms.messagebox]::Show("PowerShell 7 is not supported", "Echo Navigator", "OK", "Error")
            return
        }
        $serverButton.Enabled = $false
        $serverButton.text = "Adding Server..."
        Start-Sleep -s 1
        $serverButton.Refresh()
        $jsonData = @{
            action = "addServer"
            serverName = $serverNameInput.Text
            ip = $serverIPInput.Text
            port = $serverPortInput.Text
            description = $serverDescriptionInput.Text
            longDescription = $serverLongDescriptionInput.Text
            imageURL = $serverImageInput.Text
            userName = $global:config.username
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
        } | ConvertTo-Json

        try {
            Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData
            [system.windows.forms.messagebox]::Show("Server added successfully, it might take 5 minutes before it can be found in the server list.", "Echo Navigator", "OK", "Information")
            $addServer.Close()
        }
        catch {
            $errorMessage = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
            [system.windows.forms.messagebox]::Show("Failed to add server, the server replied with `"$errorMessage`"", "Echo Navigator", "OK", "Error")
            $serverButton.Enabled = $true
            $serverButton.text = "Add Server"
        }
    })
    $addServer.Controls.Add($serverButton)

    $addServer.showDialog()
}

function combatLoungeNotSelected {
    $selectCombatLounge.Dispose()
    $notSelectedLabel.Dispose()
    $menuDetails.Dispose()

    $global:notSelectedLabel = New-Object System.Windows.Forms.Label
    $notSelectedLabel.Size = New-Object System.Drawing.Size(1300, 720)
    $notSelectedLabel.Location = New-Object System.Drawing.Point(-30, -60)
    $notSelectedLabel.Text = "Echo Combat Lounge not selected"
    $notSelectedLabel.TextAlign = 'MiddleCenter'
    $notSelectedLabel.Font = New-Object System.Drawing.Font("Arial", 50)
    $combatLounge.Controls.Add($notSelectedLabel)
    $notSelectedLabel.BringToFront()

    $global:selectCombatLounge = New-Object System.Windows.Forms.Button
    $selectCombatLounge.Size = New-Object System.Drawing.Size(600, 70)
    $selectCombatLounge.Location = New-Object System.Drawing.Point(320, 350)
    $selectCombatLounge.Font = New-Object System.Drawing.Font("Arial", 20)
    $selectCombatLounge.Text = "Select Echo Combat Lounge"
    $selectCombatLounge.add_click({

        if ($global:config.'62.68.167.123' -eq $null) {
            $usernamePicker = New-Object System.Windows.Forms.Form
            $usernamePicker.Text = "Echo Navigator"
            $usernamePicker.Size = New-Object System.Drawing.Size(280, 150)
            $usernamePicker.StartPosition = "CenterScreen"
            $usernamePicker.FormBorderStyle = "FixedDialog"
            $usernamePicker.MaximizeBox = $false

            $usernameLabel = New-Object System.Windows.Forms.Label
            $usernameLabel.Size = New-Object System.Drawing.Size(250, 20)
            $usernameLabel.Location = New-Object System.Drawing.Point(10, 10)
            $usernameLabel.Text = "Enter a username for Echo Combat Lounge"
            $usernameLabel.Font = New-Object System.Drawing.Font("Arial", 12)
            $usernamePicker.Controls.Add($usernameLabel)

            $usernameInput = New-Object System.Windows.Forms.TextBox
            $usernameInput.Size = New-Object System.Drawing.Size(200, 20)
            $usernameInput.Location = New-Object System.Drawing.Point(30, 30)
            $usernameInput.Font = New-Object System.Drawing.Font("Arial", 12)
            $usernameInput.Text = $global:config.username
            $usernamePicker.Controls.Add($usernameInput)

            $usernameButton = New-Object System.Windows.Forms.Button
            $usernameButton.Size = New-Object System.Drawing.Size(200, 35)
            $usernameButton.Location = New-Object System.Drawing.Point(30, 60)
            $usernameButton.Text = "Join Echo Combat Lounge"
            $usernameButton.add_click({
                $username = $global:config.username
                if ($usernameInput.text -ne "") {
                    $username = $usernameInput.Text
                }
                $usernamePicker.Close()
                $usernamePicker.Dispose()
                $usernameButton.Dispose()
                $usernameInput.Dispose()
                $usernameLabel.Dispose()
                $global:config | Add-Member -Type NoteProperty -Name '62.68.167.123' -Value $username
                $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
            })
            $usernamePicker.Controls.Add($usernameButton)

            $usernamePicker.ShowDialog()
        }

        if ($global:config.'62.68.167.123' -eq $null) {
            [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Navigator", "OK", "Warning")
            return
        }

        $gameConfig = @{}
        $gameConfig | Add-Member -Name 'apiservice_host' -Type NoteProperty -Value "http://62.68.167.123:1234/api"
        $gameConfig | Add-Member -Name 'configservice_host' -Type NoteProperty -Value "ws://62.68.167.123:1234/config"
        $gameConfig | Add-Member -Name 'loginservice_host' -Type NoteProperty -Value "ws://62.68.167.123:1234/login?auth=$($global:config.password)&displayname=$($global:config.'62.68.167.123')"
        $gameConfig | Add-Member -Name 'matchingservice_host' -Type NoteProperty -Value "ws://62.68.167.123:1234/matching"
        $gameConfig | Add-Member -Name 'serverdb_host' -Type NoteProperty -Value "ws://62.68.167.123:1234/serverdb"
        $gameConfig | Add-Member -Name 'transactionservice_host' -Type NoteProperty -Value "ws://62.68.167.123:1234/transaction"
        $gameConfig | Add-Member -Name 'publisher_lock' -Type NoteProperty -Value 'rad15_live'
        $gameConfig | convertto-json | set-content "$($global:config.gamePath)\_local\config.json"

        $selectCombatLounge.Dispose()
        $notSelectedLabel.Dispose()
        $menuDetails.Dispose()
    })
    $combatLounge.Controls.Add($selectCombatLounge)

    $selectCombatLounge.BringToFront()

    $global:menuDetails = New-Object System.Windows.Forms.Label
    $menuDetails.Size = New-Object System.Drawing.Size(520, 100)
    $menuDetails.Location = New-Object System.Drawing.Point(730, 590)
    $menuDetails.Text = "This menu gives you access to join specific matches hosted on the Echo Combat Lounge server. You need to have Echo Combat Lounge selected for this menu to be useful"
    $menuDetails.Font = New-Object System.Drawing.Font("Arial", 12)
    $combatLounge.Controls.Add($menuDetails)
    $menuDetails.BringToFront()

    $selectCombatLounge.TabIndex = 0
    $selectCombatLounge.add_LostFocus({
        $selectCombatLounge.Focus()
    })
}

function pingServer {
    param($serverIP)
    $port = 6792
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.Client.ReceiveTimeout = 1000
    $udpClient.Connect($serverIP, $port)
    $packet = [byte[]]@(0xB0, 0x03, 0x5A, 0x06, 0xDE, 0x79, 0x72, 0x99, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $udpClient.Send($packet, $packet.Length)
    $remoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
    $response = $udpClient.Receive([ref]$remoteEndPoint)
    $stopwatch.Stop()
    $udpClient.Close()
    return $stopwatch.ElapsedMilliseconds
}

$ProgressPreference = 'SilentlyContinue'

[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[system.windows.forms.application]::enablevisualstyles()

$file = Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/servers.json" -UseBasicParsing
$database = $file.content | ConvertFrom-Json
$global:config = Get-Content "$env:appdata\EchoNavigator\config.json" | ConvertFrom-Json

if ($database -eq $null) {
    [System.Windows.Forms.MessageBox]::Show("Failed to download online resources. Check your internet connection and try again.", "Echo Navigator", "OK", "Error")
    exit
}

if ($config.username -eq "" -or $config.username -eq $null) {
    [System.Windows.Forms.MessageBox]::Show("Configuration files are corrupt, please reinstall.", "Echo Navigator", "OK", "Error")
    exit
}

if ((get-item -path "$($global:config.gamePath)\bin\win10\EchoNavigator.exe").VersionInfo.FileVersion -ne $database.currentVersion -and (get-item -path $($global:config.quest)).VersionInfo.FileVersion -ne $database.currentVersion) {
    taskkill /f /im "EchoNavigator.exe"
    if ($config.quest) {
        remove-item "$env:appdata\EchoNavigator\EchoNavigator.exe"
        Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/EchoNavigator.exe" -OutFile "$env:appdata\EchoNavigator\EchoNavigator.exe"
        start-process "$env:appdata\EchoNavigator\EchoNavigator.exe"
    } else {
        remove-item "$($global:config.gamePath)\bin\win10\EchoNavigator.exe"
        Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/EchoNavigator.exe" -OutFile "$($global:config.gamePath)\bin\win10\EchoNavigator.exe"
        start-process "$($global:config.gamePath)\bin\win10\EchoNavigator.exe"
    }
    exit
}

$global:clientselected = $false

$menu = New-Object System.Windows.Forms.Form
$menu.Text = "Echo Navigator"
$menu.Size = New-Object System.Drawing.Size(1280, 720)
$menu.StartPosition = "CenterScreen"
$menu.FormBorderStyle = "FixedDialog"
$menu.MaximizeBox = $false
if ($config.quest -ne $null) {
    $menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
} else {
    $menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
}


$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Size = New-Object System.Drawing.Size(1280, 720)
$tabs.Location = New-Object System.Drawing.Point(0, 0)
$tabs.SizeMode = 'Fixed'
$tabs.TabStop = $false
$tabs.add_SelectedIndexChanged({
    if ($tabs.SelectedTab -eq $combatLounge) {
        $currentServer = Get-Content "$($global:config.gamePath)\_Local\config.json" | ConvertFrom-Json
        if ($currentServer.apiservice_host -ne "http://62.68.167.123:1234/api") {combatLoungeNotSelected} else {
            $selectCombatLounge.Dispose()
            $notSelectedLabel.Dispose()
            $menuDetails.Dispose()
        }
        $global:config.tab = 0
        $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
        if ($config.quest -ne $null) {
            $questLabel.BringToFront()
        }
    }
    if ($tabs.SelectedTab -eq $otherServers) {
        $global:config.tab = 1
        $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
    }
})
$menu.Controls.Add($tabs)
$combatLounge = New-Object System.Windows.Forms.TabPage
$combatLounge.Text = "Combat Lounge"
$combatLounge.Size = New-Object System.Drawing.Size(1280, 720)
$combatLounge.Location = New-Object System.Drawing.Point(0, 0)
$tabs.Controls.Add($combatLounge)
# $combatLounge.Visible = $false
# $combatLounge.Enabled = $false

$otherServers = New-Object System.Windows.Forms.TabPage
$otherServers.Text = "Other Servers"
$otherServers.Size = New-Object System.Drawing.Size(1280, 720)
$otherServers.Location = New-Object System.Drawing.Point(0, 0)
$tabs.Controls.Add($otherServers)

if ($global:config.tab -eq $null) {
    $global:config | Add-Member -Type NoteProperty -Name 'tab' -Value 1
    $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
}

$tabs.SelectedIndex = $global:config.tab

#combat lounge ---------------------

if ($config.quest -ne $null) {
    $questLabel = New-Object System.Windows.Forms.Label
    $questLabel.Size = New-Object System.Drawing.Size(1300, 720)
    $questLabel.Location = New-Object System.Drawing.Point(-30, -60)
    $questLabel.Text = "This tab is unavailable on Quest."
    $questLabel.TextAlign = 'MiddleCenter'
    $questLabel.Font = New-Object System.Drawing.Font("Arial", 50)
    $combatLounge.Controls.Add($questLabel)
} else {
    # $questLabel = New-Object System.Windows.Forms.Label
    # $questLabel.Size = New-Object System.Drawing.Size(1300, 720)
    # $questLabel.Location = New-Object System.Drawing.Point(-30, -60)
    # $questLabel.Text = "This tab is under construction."
    # $questLabel.TextAlign = 'MiddleCenter'
    # $questLabel.Font = New-Object System.Drawing.Font("Arial", 50)
    # $combatLounge.Controls.Add($questLabel)
}

$currentServer = Get-Content "$($global:config.gamePath)\_Local\config.json" | ConvertFrom-Json
if ($currentServer.apiservice_host -ne "http://62.68.167.123:1234/api") {combatLoungeNotSelected}

$combatGames = Invoke-WebRequest "http://51.75.140.182:3000/api/listGameServers/62.68.167.123"
$combatGames = $combatGames.content | ConvertFrom-Json

# $combatGames = get-content .\testdata.json | ConvertFrom-Json


$combatLoungeLabel = New-Object System.Windows.Forms.Label
$combatLoungeLabel.Size = New-Object System.Drawing.Size(200, 20)
$combatLoungeLabel.Location = New-Object System.Drawing.Point(10, 17)
$combatLoungeLabel.Text = "Games:"
$combatLoungeLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$combatLounge.Controls.Add($combatLoungeLabel)

$combatLoungeList = New-Object System.Windows.Forms.DataGridView
$combatLoungeList.Size = New-Object System.Drawing.Size(808, 408)
$combatLoungeList.Location = New-Object System.Drawing.Point(10, 50)
$combatLoungeList.BorderStyle = 'None'
$combatLoungeList.BackgroundColor = $menu.BackColor
$combatLoungeList.RowHeadersVisible = $false
$combatLoungeList.ReadOnly = $true
$combatLoungeList.AllowUserToResizeColumns = $false
$combatLoungeList.AllowUserToResizeRows = $false
$combatLoungeList.EnableHeadersVisualStyles = $false
$combatLoungeList.AllowUserToOrderColumns = $false
$combatLoungeList.ColumnHeadersDefaultCellStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
$combatLoungeList.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$combatLoungeList.ColumnHeadersDefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$combatLoungeList.SelectionMode = 'FullRowSelect'
$combatLoungeList.ColumnCount = 3
$combatLoungeList.RowCount = $combatGames.gameServers.count
$combatLoungeList.ColumnHeadersVisible = $true
$combatLoungeList.TabIndex = 0
$combatLoungeList.Columns[0].Name = "Players"
$combatLoungeList.Columns[0].Width = 50
$combatLoungeList.Columns[1].Name = "Game Mode"
$combatLoungeList.Columns[1].Width = 200
# $combatLoungeList.Columns[2].Name = "Region"
# $combatLoungeList.Columns[2].Width = 50
$combatLoungeList.Columns[2].Name = "Ping"
$combatLoungeList.Columns[2].Width = 50
# $combatLoungeList.Columns[3].DefaultCellStyle.Alignment = 'MiddleCenter'

$combatLoungeList.Add_CellClick({
    param($sender, $e)
    $combatLoungeList.ClearSelection()
    $combatLoungeList.Rows[$e.RowIndex].Selected = $true
    $combatSideBar.Visible = $true
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
    $currentGameMode.Text = $combatLoungeList.Rows[$e.RowIndex].Cells[1].value
    $currentGameModeImage.Image = [System.Drawing.Image]::FromFile(".\loading.gif")
})

$combatLoungeList.Add_KeyDown({
    param($sender, $e)

    $global:rowIndex = $combatLoungeList.SelectedRows.index
    $combatLoungeList.Rows[$global:rowIndex].Selected = $true
    
    if ($e.KeyCode -eq 'Enter') {
        $combatLoungeList.ClearSelection()
        $combatLoungeList.Rows[$e.RowIndex].Selected = $true
        $global:rowIndex = $e.RowIndex
        $global:clientselected = $true
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to join $($combatGames.gameServers[$global:RowIndex].gameMode)?", "Echo Navigator", "YesNo", "Question")
        if ($choice -eq "Yes") {
            Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-lobbyid $($combatGames.gameServers[$global:RowIndex].sessionID)" -Wait
        }
    }
})

$combatLoungeList.Add_CellDoubleClick({
    param($sender, $e)
    $combatLoungeList.ClearSelection()
    $combatLoungeList.Rows[$e.RowIndex].Selected = $true
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to join $($combatGames.gameServers[$global:RowIndex].gameMode)?", "Echo Navigator", "YesNo", "Question")
    if ($choice -eq "Yes") {
        Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-lobbyid $($combatGames.gameServers[$global:RowIndex].sessionID)" -Wait
    }
})

$i=0
foreach ($gameServer in $combatGames.gameServers) {
    $combatLoungeList.Rows[$i].Cells[0].value = "$($gameServer.playerCount)/$(if($gameServer.activePlayerLimit -eq $null){$gameServer.playerLimit}else{$gameServer.activePlayerLimit})"
    $combatLoungeList.Rows[$i].Cells[1].value = (Get-Culture).TextInfo.ToTitleCase($($gameServer.gameMode -replace '^(echo_|mpl_combat_)', '')) -replace '_',' '
    if ($combatLoungeList.Rows[$i].Cells[1].value -eq "Social 2.0") {
        $combatLoungeList.Rows[$i].Cells[1].value = "Lobby"
    }
    $combatLoungeList.Rows[$i].Cells[2].value = $(pingServer $gameServer.sessionIp)[1]
    if ($combatLoungeList.Rows[$i].Cells[2].value -gt 1000) {
        $PingServer = Test-Connection -count 1 -ComputerName $gameServer.sessionIP -TimeoutSeconds 1
        if ($PingServer.Latency -eq 0){
            $combatLoungeList.Rows[$i].Cells[2].value = "Error"
        } else {
            $combatLoungeList.Rows[$i].Cells[2].value = $PingServer.Latency
        }
    }
    ++$i
}
$combatLounge.Controls.Add($combatLoungeList)

$refreshCombatLounge = New-Object System.Windows.Forms.Button
$refreshCombatLounge.Location = New-Object System.Drawing.Point(236, 25)
$refreshCombatLounge.Text = "Refresh"
$refreshCombatLounge.Font = New-Object System.Drawing.Font("Arial", 10)
$refreshCombatLounge.add_click({

    $refreshCombatLounge.Enabled = $false
    $refreshCombatLounge.text = "Refreshing..."
    $refreshCombatLounge.Font = New-Object System.Drawing.Font("Arial", 8)

    $combatGames = Invoke-WebRequest "http://51.75.140.182:3000/api/listGameServers/62.68.167.123"
    $global:combatGames = $combatGames.content | ConvertFrom-Json

    $i=0
    foreach ($gameServer in $global:combatGames.gameServers) {
        $combatLoungeList.Rows[$i].Cells[0].value = "$($gameServer.playerCount)/$(if($gameServer.activePlayerLimit -eq $null){$gameServer.playerLimit}else{$gameServer.activePlayerLimit})"
        $combatLoungeList.Rows[$i].Cells[1].value = (Get-Culture).TextInfo.ToTitleCase($($gameServer.gameMode -replace '^(echo_|mpl_combat_)', '')) -replace '_',' '
        if ($combatLoungeList.Rows[$i].Cells[1].value -eq "Social 2.0") {
            $combatLoungeList.Rows[$i].Cells[1].value = "Lobby"
        }
        $combatLoungeList.Rows[$i].Cells[2].value = $(pingServer $gameServer.sessionIp)[1]
        if ($combatLoungeList.Rows[$i].Cells[2].value -gt 1000) {
            $PingServer = Test-Connection -count 1 -ComputerName $gameServer.sessionIP -TimeoutSeconds 1
            if ($PingServer.Latency -eq 0){
                $combatLoungeList.Rows[$i].Cells[2].value = "Error"
            } else {
                $combatLoungeList.Rows[$i].Cells[2].value = $PingServer.Latency
            }
        }
        ++$i
    }


    $refreshCombatLounge.Enabled = $true
    $refreshCombatLounge.text = "Refresh"
    $refreshCombatLounge.Font = New-Object System.Drawing.Font("Arial", 10)
})
$combatLounge.Controls.Add($refreshCombatLounge)

$combatSideBar = New-Object System.Windows.Forms.Panel
$combatSideBar.Size = New-Object System.Drawing.Size(385, 721)
$combatSideBar.Location = New-Object System.Drawing.Point(895, -1)
$combatSideBar.BackColor = 'LightGray'
$combatSideBar.BorderStyle = 'FixedSingle'
$combatSideBar.Visible = $false
$combatLounge.Controls.Add($combatSideBar)

$currentGameMode = New-Object System.Windows.Forms.Label
$currentGameMode.Size = New-Object System.Drawing.Size(380, 50)
$currentGameMode.Location = New-Object System.Drawing.Point(0, 0)
$currentGameMode.Text = "Current Mode Placeholder"
$currentGameMode.TextAlign = 'MiddleCenter'
$currentGameMode.Font = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)
$currentGameMode.BackColor = 'LightGray'
$combatSideBar.Controls.Add($currentGameMode)

$currentGameModeImage = New-Object System.Windows.Forms.PictureBox
$currentGameModeImage.Size = New-Object System.Drawing.Size(340, 203)
$currentGameModeImage.Location = New-Object System.Drawing.Point(12, 50)
$currentGameModeImage.ImageLocation = "https://media.discordapp.net/attachments/779349591438524457/1172949792419238008/loungebanner.gif"
$currentGameModeImage.SizeMode = 'Zoom'
$combatSideBar.Controls.Add($currentGameModeImage)

$currentGameModeDescription = New-Object System.Windows.Forms.Label
$currentGameModeDescription.Size = New-Object System.Drawing.Size(360, 100)
$currentGameModeDescription.Location = New-Object System.Drawing.Point(10, 260)
# $currentGameModeDescription.Text = "Game Mode Objective Placeholder"
$currentGameModeDescription.Font = New-Object System.Drawing.Font("Arial", 12)
$currentGameModeDescription.BackColor = 'LightGray'
$combatSideBar.Controls.Add($currentGameModeDescription)

$join = New-Object System.Windows.Forms.Button
$join.Size = New-Object System.Drawing.Size(345, 50)
$join.Location = New-Object System.Drawing.Point(10, 600)
$join.Text = "Join Game"
$join.Font = New-Object System.Drawing.Font("Arial", 12)
$join.add_click({
    Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-lobbyid $($combatGames.gameServers[$global:RowIndex].sessionID)" -Wait
})

$combatSideBar.Controls.Add($join)


#server list ---------------------
$publicServersLabel = New-Object System.Windows.Forms.Label
$publicServersLabel.Size = New-Object System.Drawing.Size(200, 20)
$publicServersLabel.Location = New-Object System.Drawing.Point(10, 17)
$publicServersLabel.Text = "Public Servers:"
$publicServersLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$otherServers.Controls.Add($publicServersLabel)

$serverList = New-Object System.Windows.Forms.DataGridView
$serverList.Size = New-Object System.Drawing.Size(808, 408)
$serverList.Location = New-Object System.Drawing.Point(10, 50)
$serverList.BorderStyle = 'None'
$serverList.BackgroundColor = $menu.BackColor
$serverList.RowHeadersVisible = $false
$serverList.ReadOnly = $true
$serverList.AllowUserToResizeColumns = $false
$serverList.AllowUserToResizeRows = $false
$serverList.EnableHeadersVisualStyles = $false
$serverList.AllowUserToOrderColumns = $false
$serverList.ColumnHeadersDefaultCellStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
$serverList.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$serverList.ColumnHeadersDefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$serverList.SelectionMode = 'FullRowSelect'
$serverList.ColumnCount = 2
$serverList.RowCount = $database.online.Count
$serverList.ColumnHeadersVisible = $true
$serverList.TabIndex = 0
$serverList.Columns[0].Name = "Server Name"
$serverList.Columns[0].Width = 200
$serverList.Columns[1].Name = "Server Description"
$serverList.Columns[1].Width = 590


$sideBar = New-Object System.Windows.Forms.Panel
$sideBar.Size = New-Object System.Drawing.Size(385, 721)
$sideBar.Location = New-Object System.Drawing.Point(895, -1)
$sideBar.BackColor = 'LightGray'
$sideBar.BorderStyle = 'FixedSingle'
$sideBar.Visible = $false
$otherServers.Controls.Add($sideBar)

$serverName = New-Object System.Windows.Forms.Label
$serverName.Size = New-Object System.Drawing.Size(380, 50)
$serverName.Location = New-Object System.Drawing.Point(0, 0)
$serverName.Text = "Server Name"
$serverName.TextAlign = 'MiddleCenter'
$serverName.Font = New-Object System.Drawing.Font("Arial", 20, [System.Drawing.FontStyle]::Bold)
$serverName.BackColor = 'LightGray'
$sideBar.Controls.Add($serverName)

$serverImage = New-Object System.Windows.Forms.PictureBox
$serverImage.Size = New-Object System.Drawing.Size(340, 203)
$serverImage.Location = New-Object System.Drawing.Point(12, 50)
$serverImage.SizeMode = 'Zoom'
$serverImage.Image = [System.Drawing.Image]::FromFile(".\loading.gif")
$sideBar.Controls.Add($serverImage)

$serverDescription = New-Object System.Windows.Forms.Label
$serverDescription.Size = New-Object System.Drawing.Size(360, 100)
$serverDescription.Location = New-Object System.Drawing.Point(10, 260)
$serverDescription.Text = "Server Description"
$serverDescription.Font = New-Object System.Drawing.Font("Arial", 12)
$serverDescription.BackColor = 'LightGray'
$sideBar.Controls.Add($serverDescription)

$select = New-Object System.Windows.Forms.Button
$select.Size = New-Object System.Drawing.Size(165, 50)
$select.Location = New-Object System.Drawing.Point(10, 600)
$select.Text = "Select"
$select.Font = New-Object System.Drawing.Font("Arial", 12)
$select.add_click({
    if ($global:clientselected -eq $true) {
        clientJoinServer
    } else {
        joinServer
    }
})
$sideBar.Controls.Add($select)

$selectPlay = New-Object System.Windows.Forms.Button
$selectPlay.Size = New-Object System.Drawing.Size(165, 50)
$selectPlay.Location = New-Object System.Drawing.Point(190, 600)
$selectPlay.Text = "Select and Play"
$selectPlay.add_click({
    $selectPlay.text = "Game Running"
    $selectPlay.Enabled = $false
    $select.Enabled = $false
    if ($global:clientselected -eq $true) {
        clientJoinServer
    } else {
        joinServer
    }

    if ($global:clientselected -eq $true) {
        if ($global:config.$($config.servers[$global:rowIndex].ip) -ne $null) {
            start-process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -wait
        }
    } else {
        if ($global:config.$($database.online[$global:rowIndex].ip) -ne $null) {
            start-process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -wait
        }
    }
    $selectPlay.text = "Select and Play"
    $selectPlay.Enabled = $true
    $select.Enabled = $true
})
$selectPlay.Font = New-Object System.Drawing.Font("Arial", 12)
if ($config.quest) {
    $selectPlay.Enabled = $false
}
$sideBar.Controls.Add($selectPlay)

$serverList.Add_CellMouseDown({
    param($sender, $e)

    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
        $serverList.ClearSelection()
        $serverList.Rows[$e.RowIndex].Selected = $true
        $clientServerList.ClearSelection()
        $global:rowIndex = $e.RowIndex
        $global:clientselected = $false
    }
})

$addPublicServer = New-Object System.Windows.Forms.Button
$addPublicServer.Size = New-Object System.Drawing.Size(165, 50)
$addPublicServer.Location = New-Object System.Drawing.Point(185, 600)
$addPublicServer.Text = "Add Public Server"
$addPublicServer.TabIndex = 3
$addPublicServer.Font = New-Object System.Drawing.Font("Arial", 12)
$addPublicServer.add_click({addOnlineServer})


$otherServers.controls.add($addPublicServer)

$serverRightClick = New-Object System.Windows.Forms.ContextMenuStrip
$selectRightClick = New-Object System.Windows.Forms.ToolStripMenuItem
$selectRightClick.Text = "Select"
$selectRightClick.add_Click({
    joinServer
})
$serverRightClick.Items.Add($selectRightClick)

$selectPlayRightClick = New-Object System.Windows.Forms.ToolStripMenuItem
$selectPlayRightClick.Text = "Select and Play"
$selectPlayRightClick.add_Click({
    $selectPlay.text = "Game Running"
    $selectPlay.Enabled = $false
    $select.Enabled = $false
    joinServer
    if ($global:config.$($database.online[$global:rowIndex].ip) -ne $null) {
        start-process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -wait
    }
    $selectPlay.text = "Select and Play"
    $selectPlay.Enabled = $true
    $select.Enabled = $true
})
if (!$config.quest) {
    $serverRightClick.Items.Add($selectPlayRightClick)
}

$separator1 = New-Object System.Windows.Forms.ToolStripSeparator
$serverRightClick.Items.Add($separator1)

$reportServer = New-Object System.Windows.Forms.ToolStripMenuItem
$reportServer.Text = "Report Server"
$reportServer.add_Click({

    if ($database.api -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("The API is not online right now, check back later.", "Echo Navigator", "OK", "Information")
        return
    }

    $reportServer = New-Object System.Windows.Forms.Form
    $reportServer.Text = "Echo Navigator"
    $reportServer.Size = New-Object System.Drawing.Size(330, 290)
    $reportServer.StartPosition = "CenterScreen"
    $reportServer.FormBorderStyle = "FixedDialog"
    $reportServer.showInTaskbar = $false
    $reportServer.MaximizeBox = $false
    if ($config.quest -ne $null) {
        $reportServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
    } else {
        $reportServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
    }

    $reportReasonLabel = New-Object System.Windows.Forms.Label
    $reportReasonLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $reportReasonLabel.Location = New-Object System.Drawing.Point(10, 10)
    $reportReasonLabel.Text = "Enter a reason for reporting this server"
    $reportReasonLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $reportServer.Controls.Add($reportReasonLabel)

    $reportReasonInput = New-Object System.Windows.Forms.TextBox
    $reportReasonInput.Size = New-Object System.Drawing.Size(250, 20)
    $reportReasonInput.Location = New-Object System.Drawing.Point(30, 30)
    $reportReasonInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $reportServer.Controls.Add($reportReasonInput)

    $reportDetailsLabel = New-Object System.Windows.Forms.Label
    $reportDetailsLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $reportDetailsLabel.Location = New-Object System.Drawing.Point(10, 60)
    $reportDetailsLabel.Text = "Enter more information about the issue"
    $reportDetailsLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $reportServer.Controls.Add($reportDetailsLabel)

    $reportDetailsInput = New-Object System.Windows.Forms.TextBox
    $reportDetailsInput.Size = New-Object System.Drawing.Size(250, 100)
    $reportDetailsInput.Location = New-Object System.Drawing.Point(30, 80)
    $reportDetailsInput.Multiline = $true
    $reportDetailsInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $reportServer.Controls.Add($reportDetailsInput)

    $reportButton = New-Object System.Windows.Forms.Button
    $reportButton.Size = New-Object System.Drawing.Size(250, 35)
    $reportButton.Location = New-Object System.Drawing.Point(30, 190)
    $reportButton.Text = "Report Server"

    $reportButton.add_click({
        if ($psversiontable.psversion.major -eq 7) {
            [system.windows.forms.messagebox]::Show("PowerShell 7 is not supported", "Echo Navigator", "OK", "Error")
            return
        }

        $reportButton.Enabled = $false
        $reportButton.text = "Reporting Server..."
        Start-Sleep -s 1
        $reportButton.Refresh()
        $jsonData = @{
            action = "report"
            reason = $reportReasonInput.Text
            details = $reportDetailsInput.Text
            username = $global:config.username
            serverName = $database.online[$global:rowIndex].name
            ip = $database.online[$global:rowIndex].ip
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
        } | ConvertTo-Json

        try {
            Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $jsonData
            [system.windows.forms.messagebox]::Show("Server reported`n`nWe care about your feedback and will deal with your report as fast as we can.", "Echo Navigator", "OK", "Information")
            $reportServer.Close()
        }
        catch {
            $errorMessage = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
            [system.windows.forms.messagebox]::Show("The report failed, the server replied with `"$errorMessage`"", "Echo Navigator", "OK", "Error")
            $reportButton.Enabled = $true
            $reportButton.text = "Report Server"
        }
    })
    $reportServer.Controls.Add($reportButton)

    $reportServer.showDialog()
})

$serverRightClick.Items.Add($reportServer)

$separator2 = New-Object System.Windows.Forms.ToolStripSeparator
$serverRightClick.Items.Add($separator2)

$serverProperties = New-Object System.Windows.Forms.ToolStripMenuItem
$serverProperties.Text = "Server Properties"
$serverProperties.add_Click({
    $serverPropertiesWindow = New-Object System.Windows.Forms.Form
    $serverPropertiesWindow.Text = "Echo Navigator"
    $serverPropertiesWindow.Size = New-Object System.Drawing.Size(600, 290)
    $serverPropertiesWindow.StartPosition = "CenterScreen"
    $serverPropertiesWindow.FormBorderStyle = "FixedDialog"
    $serverPropertiesWindow.showInTaskbar = $false
    $serverPropertiesWindow.MaximizeBox = $false
    if ($config.quest -ne $null) {
        $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
    } else {
        $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
    }


    $serverPropertiesName = New-Object System.Windows.Forms.Label
    $serverPropertiesName.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPropertiesName.Location = New-Object System.Drawing.Point(10, 10)
    $serverPropertiesName.Text = "Server Name: $($database.online[$global:rowIndex].name)"
    $serverPropertiesName.Font = New-Object System.Drawing.Font("Arial", 12)
    $serverPropertiesWindow.Controls.Add($serverPropertiesName)

    $serverPropertiesIP = New-Object System.Windows.Forms.Label
    $serverPropertiesIP.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPropertiesIP.Location = New-Object System.Drawing.Point(10, 40)
    $serverPropertiesIP.Text = "Server IP: $($database.online[$global:rowIndex].ip):$($database.online[$global:rowIndex].port)"
    $serverPropertiesIP.Font = New-Object System.Drawing.Font("Arial", 12)
    $serverPropertiesWindow.Controls.Add($serverPropertiesIP)

    $serverPropertiesDescription = New-Object System.Windows.Forms.Label
    $serverPropertiesDescription.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPropertiesDescription.Location = New-Object System.Drawing.Point(10, 70)
    $serverPropertiesDescription.Text = "Server Description: $($database.online[$global:rowIndex].description)"
    $serverPropertiesDescription.Font = New-Object System.Drawing.Font("Arial", 12)
    $serverPropertiesWindow.Controls.Add($serverPropertiesDescription)

    $serverPropertiesWindow.showDialog()
})
$serverRightClick.Items.Add($serverProperties)

$serverList.ContextMenuStrip = $serverRightClick

$i=0
foreach ($server in $database.online) {
    $serverList.Rows[$i].Cells[0].Value = $server.name
    $serverList.Rows[$i].Cells[1].Value = $server.description
    ++$i
}

$serverList.Add_CellClick({
    param($sender, $e)

    $global:rowIndex = $e.RowIndex
    $global:clientselected = $false
    $clientServerList.ClearSelection()
    $sideBar.Visible = $true
    $serverName.Text = $database.online[$rowIndex].name
    $serverDescription.Text = $database.online[$rowIndex].longDescription
    $serverImage.Image = [System.Drawing.Image]::FromFile(".\loading.gif")
    $serverImage.ImageLocation = $database.online[$rowIndex].image
})

$serverList.Add_KeyDown({
    param($sender, $e)

    if ($e.KeyCode -eq 'Enter') {
        $global:rowIndex = $serverList.CurrentCell.RowIndex
        $sideBar.Visible = $true
        $serverName.Text = $database.online[$rowIndex].name
        $serverDescription.Text = $database.online[$rowIndex].longDescription
        $serverImage.ImageLocation = $database.online[$rowIndex].image
        $global:clientselected = $false
        $clientServerList.ClearSelection()
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($database.online[$global:rowIndex].name)?", "Echo Navigator", "YesNo", "Question")
        if ($choice -eq "Yes") {
            joinServer
        }
    }
})


$serverList.Add_CellDoubleClick({
    param($sender, $e)
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $false
    $clientServerList.ClearSelection()
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($database.online[$global:rowIndex].name)?", "Echo Navigator", "YesNo", "Question")
    if ($choice -eq "Yes") {
        joinServer
    }
})

$otherServers.Controls.Add($serverList)

$refresh = New-Object System.Windows.Forms.Button
$refresh.Location = New-Object System.Drawing.Point(575, 25)
$refresh.Text = "Refresh"
$refresh.TabIndex = 4
$refresh.Font = New-Object System.Drawing.Font("Arial", 10)
$refresh.add_click({
    $refresh.Enabled = $false
    $refresh.text = "Refreshing..."
    $refresh.Font = New-Object System.Drawing.Font("Arial", 8)
    $refresh.Update()
    $file = Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/servers.json" -UseBasicParsing
    $newList = $file.content | ConvertFrom-Json
    $global:database.online = $newList.online
    $global:database.offline = $newList.offline
    if ($showOfflineServers.Checked -eq $true) {
        $i=0
        $newList = [System.Collections.ArrayList]@($database.online)
        foreach ($server in $global:database.offline) {
            $newList.Add($server)
        }
        $database.online = $newList.ToArray()
        $serverList.RowCount = $database.online.Count
        foreach ($server in $global:database.online) {
            $serverList.Rows[$i].Cells[0].Value = $server.name
            $serverList.Rows[$i].Cells[1].Value = $server.description
            ++$i
        }
    } else {
        $serverList.RowCount = $database.online.Count
        $i=0
        foreach ($server in $global:database.online) {
            $serverList.Rows[$i].Cells[0].Value = $server.name
            $serverList.Rows[$i].Cells[1].Value = $server.description
            ++$i
        }
    }
    $refresh.text = "Refresh"
    $refresh.Font = New-Object System.Drawing.Font("Arial", 10)
    $refresh.Enabled = $true
})
$otherServers.controls.add($refresh)

$showOfflineServers = New-Object System.Windows.Forms.CheckBox
$showOfflineServers.Size = New-Object System.Drawing.Size(250, 20)
$showOfflineServers.Location = New-Object System.Drawing.Point(657, 27)
$showOfflineServers.Text = "Show Offline Servers"
$showOfflineServers.Font = New-Object System.Drawing.Font("Arial", 10)
$showOfflineServers.add_CheckedChanged({
    if ($showOfflineServers.Checked -eq $true) {
        $i=0
        $newList = [System.Collections.ArrayList]@($database.online)
        foreach ($server in $database.offline) {
            $newList.Add($server)
        }
        $database.online = $newList.ToArray()
        $serverList.RowCount = $database.online.Count
        foreach ($server in $database.online) {
            $serverList.Rows[$i].Cells[0].Value = $server.name
            $serverList.Rows[$i].Cells[1].Value = $server.description
            ++$i
        }
    } else {
        $file = Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/servers.json" -UseBasicParsing
        $online = $file.content | ConvertFrom-Json
        $database.online = $online.online
        $serverList.RowCount = $database.online.Count
        $i=0
        foreach ($server in $database.online) {
            $serverList.Rows[$i].Cells[0].Value = $server.name
            $serverList.Rows[$i].Cells[1].Value = $server.description
            ++$i
        }
    }
})

$showOfflineServers.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq 'Enter') {
        $showOfflineServers.Checked = !$showOfflineServers.Checked
    }
})

$otherServers.Controls.Add($showOfflineServers)

$clientServersLabel = New-Object System.Windows.Forms.Label
$clientServersLabel.Size = New-Object System.Drawing.Size(2500, 20)
$clientServersLabel.Location = New-Object System.Drawing.Point(10, 470)
$clientServersLabel.Text = "Private Servers:"
$clientServersLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$otherServers.Controls.Add($clientServersLabel)

$clientServerList = New-Object System.Windows.Forms.DataGridView
$clientServerList.Size = New-Object System.Drawing.Size(218, 100)
$clientServerList.Location = New-Object System.Drawing.Point(10, 500)
$clientServerList.BorderStyle = 'None'
$clientServerList.BackgroundColor = $menu.BackColor
$clientServerList.RowHeadersVisible = $false
$clientServerList.ReadOnly = $true
$clientServerList.AllowUserToResizeColumns = $false
$clientServerList.AllowUserToResizeRows = $false
$clientServerList.EnableHeadersVisualStyles = $false
$clientServerList.ColumnHeadersDefaultCellStyle = New-Object System.Windows.Forms.DataGridViewCellStyle
$clientServerList.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$clientServerList.ColumnHeadersDefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$clientServerList.SelectionMode = 'FullRowSelect'
$clientServerList.ColumnCount = 1
$clientServerList.RowCount = $global:config.servers.Count
$clientServerList.ColumnHeadersVisible = $true
$clientServerList.TabIndex = 1
$clientServerList.Columns[0].Name = "Server Name"
$clientServerList.Columns[0].Width = 200

$clientServerList.Add_CellMouseDown({
    param($sender, $e)

    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
        $clientServerList.ClearSelection()
        $serverList.ClearSelection()
        $clientServerList.Rows[$e.RowIndex].Selected = $true
        $global:rowIndex = $e.RowIndex
        $global:clientselected = $true
        if ($global:config.servers -eq $null -or $global:config.servers.Count -eq 0) {
            $clientServerList.ClearSelection()
            $global:clientselected = $false
        }
    }
})

$clientServerList.Add_CellDoubleClick({
    param($sender, $e)

    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
    $serverList.ClearSelection()
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($global:config.servers[$global:rowIndex].name)?", "Echo Navigator", "YesNo", "Question")
    if ($choice -eq "Yes") {
        clientJoinServer
    }
})

$clientServerList.Add_KeyDown({
    param($sender, $e)

    if ($e.KeyCode -eq 'Enter') {
        $global:rowIndex = $clientServerList.CurrentCell.RowIndex
        $sideBar.Visible = $true
        $serverName.Text = $global:config.servers[$e.RowIndex].name
        $serverDescription.Text = $null
        $serverImage.ImageLocation = $null
        $global:clientselected = $true
        $serverList.ClearSelection()
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($global:config.servers[$global:rowIndex].name)?", "Echo Navigator", "YesNo", "Question")
        if ($choice -eq "Yes") {
            clientJoinServer
        }
    }
})

$clientServerList.Add_cellClick({
    param($sender, $e)

    $sideBar.Visible = $true
    $serverName.Text = $global:config.servers[$e.RowIndex].name
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
    $serverList.ClearSelection()
    $serverDescription.Text = $null
    $serverImage.ImageLocation = $null
    if ($global:config.servers -eq $null -or $global:config.servers.Count -eq 0) {
        $clientServerList.ClearSelection()
        $global:clientselected = $false
        $sideBar.Visible = $false
    }
})

$i=0
foreach ($server in $global:config.servers) {
    $clientServerList.Rows[$i].Cells[0].Value = $server.name
    ++$i
}

if ($global:config.servers.Count -eq 0) {
    $clientServerList.RowCount = 1
    $clientServerList.Rows[0].Cells[0].Value = "No servers added"
}



$clientRightClick = New-Object System.Windows.Forms.ContextMenuStrip
$clientSelectRightClick = New-Object System.Windows.Forms.ToolStripMenuItem
$clientSelectRightClick.Text = "Select"
$clientSelectRightClick.add_Click({
    clientJoinServer
})
$clientRightClick.Items.Add($clientSelectRightClick)

$clientPlayRightClick = New-Object System.Windows.Forms.ToolStripMenuItem
$clientPlayRightClick.Text = "Select and Play"
$clientPlayRightClick.add_Click({
    $selectPlay.text = "Game Running"
    $selectPlay.Enabled = $false
    $select.Enabled = $false
    clientJoinServer
    if ($global:config.$($config.servers[$global:rowIndex].ip) -ne $null) {
        start-process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -wait
    }
    $selectPlay.text = "Select and Play"
    $selectPlay.Enabled = $true
    $select.Enabled = $true
})
if (!$config.quest) {
    $clientRightClick.Items.Add($clientPlayRightClick)
}

$clientSeparator1 = New-Object System.Windows.Forms.ToolStripSeparator
$clientRightClick.Items.Add($clientSeparator1)

$clientProperties = New-Object System.Windows.Forms.ToolStripMenuItem
$clientProperties.Text = "Server Properties"
$clientProperties.add_Click({
    $serverPropertiesWindow = New-Object System.Windows.Forms.Form
    $serverPropertiesWindow.Text = "Echo Navigator"
    $serverPropertiesWindow.Size = New-Object System.Drawing.Size(600, 290)
    $serverPropertiesWindow.StartPosition = "CenterScreen"
    $serverPropertiesWindow.FormBorderStyle = "FixedDialog"
    $serverPropertiesWindow.showInTaskbar = $false
    $serverPropertiesWindow.MaximizeBox = $false
    if ($config.quest -ne $null) {
        $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
    } else {
        $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
    }


    $serverPropertiesName = New-Object System.Windows.Forms.Label
    $serverPropertiesName.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPropertiesName.Location = New-Object System.Drawing.Point(10, 10)
    $serverPropertiesName.Text = "Server Name: $($global:config.servers[$global:rowIndex].name)"
    $serverPropertiesName.Font = New-Object System.Drawing.Font("Arial", 12)
    $serverPropertiesWindow.Controls.Add($serverPropertiesName)

    $serverPropertiesIP = New-Object System.Windows.Forms.Label
    $serverPropertiesIP.Size = New-Object System.Drawing.Size(2500, 20)
    $serverPropertiesIP.Location = New-Object System.Drawing.Point(10, 40)
    $serverPropertiesIP.Text = "Server IP: $($global:config.servers[$global:rowIndex].ip):$($global:config.servers[$global:rowIndex].port)"
    $serverPropertiesIP.Font = New-Object System.Drawing.Font("Arial", 12)
    $serverPropertiesWindow.Controls.Add($serverPropertiesIP)

    $serverPropertiesWindow.showDialog()
})
$clientRightClick.Items.Add($clientProperties)

$clientSeparator3 = New-Object System.Windows.Forms.ToolStripSeparator
$clientRightClick.Items.Add($clientSeparator3)

$clientRemoveServer = New-Object System.Windows.Forms.ToolStripMenuItem
$clientRemoveServer.Text = "Remove Server"
$clientRemoveServer.add_Click({
    $servers = [System.Collections.ArrayList]($global:config.servers)
    $servers.RemoveAt($global:rowIndex)
    $global:config.servers = $servers.toArray()
    $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
    $clientServerList.RowCount = $global:config.servers.Count
    $i=0
    foreach ($server in $global:config.servers) {
        $clientServerList.Rows[$i].Cells[0].Value = $server.name
        ++$i
    }
    if ($global:config.servers.Count -eq 0) {
        $clientServerList.RowCount = 1
        $clientServerList.Rows[0].Cells[0].Value = "No servers added"
    }
})
$clientRightClick.Items.Add($clientRemoveServer)

$clientServerList.ContextMenuStrip = $clientRightClick

$otherServers.Controls.Add($clientServerList)
$addServer = New-Object System.Windows.Forms.Button
$addServer.Size = New-Object System.Drawing.Size(165, 50)
$addServer.Location = New-Object System.Drawing.Point(10, 600)
$addServer.Text = "Add Private Server"
$addServer.tabIndex = 2
$addServer.Font = New-Object System.Drawing.Font("Arial", 12)
$addServer.add_Click({
    $addServerMenu = New-Object System.Windows.Forms.Form
    $addServerMenu.Text = "Echo Navigator"
    $addServerMenu.Size = New-Object System.Drawing.Size(330, 290)
    $addServerMenu.StartPosition = "CenterScreen"
    $addServerMenu.FormBorderStyle = "FixedDialog"
    $addServerMenu.showInTaskbar = $false
    $addServerMenu.MaximizeBox = $false
    if ($config.quest -ne $null) {
        $addServerMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($config.quest)
    } else {
        $addServerMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\EchoNavigator.exe")
    }


    $addServerNameLabel = New-Object System.Windows.Forms.Label
    $addServerNameLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $addServerNameLabel.Location = New-Object System.Drawing.Point(10, 10)
    $addServerNameLabel.Text = "Enter a friendly name for the server"
    $addServerNameLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerNameLabel)

    $addServerNameInput = New-Object System.Windows.Forms.TextBox
    $addServerNameInput.Size = New-Object System.Drawing.Size(250, 20)
    $addServerNameInput.Location = New-Object System.Drawing.Point(30, 30)
    $addServerNameInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerNameInput)

    $addServerIPLabel = New-Object System.Windows.Forms.Label
    $addServerIPLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $addServerIPLabel.Location = New-Object System.Drawing.Point(10, 60)
    $addServerIPLabel.Text = "Enter the IP of the server"
    $addServerIPLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerIPLabel)

    $addServerIPInput = New-Object System.Windows.Forms.TextBox
    $addServerIPInput.Size = New-Object System.Drawing.Size(250, 20)
    $addServerIPInput.Location = New-Object System.Drawing.Point(30, 80)
    $addServerIPInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerIPInput)

    $addServerPortLabel = New-Object System.Windows.Forms.Label
    $addServerPortLabel.Size = New-Object System.Drawing.Size(2500, 20)
    $addServerPortLabel.Location = New-Object System.Drawing.Point(10, 110)
    $addServerPortLabel.Text = "Enter the port of the server"
    $addServerPortLabel.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerPortLabel)

    $addServerPortInput = New-Object System.Windows.Forms.TextBox
    $addServerPortInput.Size = New-Object System.Drawing.Size(250, 20)
    $addServerPortInput.Location = New-Object System.Drawing.Point(30, 130)
    $addServerPortInput.Font = New-Object System.Drawing.Font("Arial", 12)
    $addServerMenu.Controls.Add($addServerPortInput)

    $addServerButton = New-Object System.Windows.Forms.Button
    $addServerButton.Size = New-Object System.Drawing.Size(250, 35)
    $addServerButton.Location = New-Object System.Drawing.Point(30, 190)
    $addServerButton.Text = "Add Server"
    $addServerButton.add_Click({
        $server = @{
            "name" = $addServerNameInput.Text
            "ip" = $addServerIPInput.Text
            "port" = $addServerPortInput.Text
        }
        $global:config | Add-Member -Name "servers" -Type NoteProperty -Value @()
        $servers = [System.Collections.ArrayList]($global:config.servers)
        $servers.add($server)
        $global:config.servers = $servers.toArray()
        $global:config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
        [system.windows.forms.messagebox]::Show("Server added", "Echo Navigator", "OK", "Information")
        $addServerMenu.Close()
        $addServerMenu.Dispose()
        $addServerButton.Dispose()
        $addServerPortInput.Dispose()
        $addServerPortLabel.Dispose()
        $addServerIPInput.Dispose()
        $addServerIPLabel.Dispose()
        $addServerNameInput.Dispose()
        $addServerNameLabel.Dispose()
    })
    $addServerMenu.Controls.Add($addServerButton)

    $addServerMenu.showDialog()
    $clientServerList.RowCount = $global:config.servers.Count
    $i=0
    foreach ($server in $global:config.servers) {
        $clientServerList.Rows[$i].Cells[0].Value = $server.name
        ++$i
    }
})

$otherServers.Controls.Add($addServer)

$menu.showDialog()
if ($global:gameMode) {
    $data = @{
        action = "cancel$($global:gamemode)Matchmaking"
        userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
        userName = $global:config.username
    } | ConvertTo-Json
    Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data
    $getMatchTimer.Stop()
    $gameRunTimer.Stop()
}

$config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
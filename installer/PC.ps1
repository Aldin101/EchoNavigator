$ProgressPreference = 'SilentlyContinue'

function chooseFolder {
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
    $pickMenu.text = "Echo Navigator Installer"
    $pickMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
    $pickMenu.Size = New-Object Drawing.Size @(320, 270)
    $pickMenu.StartPosition = "CenterScreen"
    $pickMenu.FormBorderStyle = "FixedDialog"
    $pickMenu.MaximizeBox = $false
    $pickMenu.ShowInTaskbar = $false

    $pickLabel = New-Object System.Windows.Forms.Label
    $pickLabel.Location = New-Object System.Drawing.Size(10,10)
    $pickLabel.Size = New-Object System.Drawing.Size(280,20)
    $pickLabel.Text = "Where would you like to install Echo VR?"
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
        $global:gamePath = Read-FolderBrowserDialog -Message "Where would you like to install Echo VR?"
        $pickMenu.Close()
    })
    $pickMenu.Controls.Add($customPath)

    $pickButton = New-Object System.Windows.Forms.Button
    $pickButton.Location = New-Object System.Drawing.Size(10,180)
    $pickButton.Size = New-Object System.Drawing.Size(280,30)
    $pickButton.Text = "Select"
    $pickButton.Font = "Microsoft Sans Serif,10"
    $pickButton.Add_Click({
        $global:gamePath = "$($pickList.SelectedItem)\Software\ready-at-dawn-echo-arena"
        $pickMenu.Close()
    })
    $pickMenu.Controls.Add($pickButton)

    $pickMenu.ShowDialog()
}

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
    if ($folder) { return $folder.Self.Path } else { return 'C:\Program Files\Oculus\Software' }
}

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

function downgrade {
    $downgradeMenu = new-object System.Windows.Forms.Form
    $downgradeMenu.text = "Downgrader"
    $downgradeMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($fileLocation1)
    $downgradeMenu.Size = New-Object Drawing.Size @(240, 200)
    $downgradeMenu.StartPosition = "CenterScreen"
    $downgradeMenu.FormBorderStyle = "FixedDialog"
    $downgradeMenu.showInTaskbar = $false
    $downgradeMenu.MaximizeBox = $false

    $downgradeLabel = New-Object System.Windows.Forms.Label
    $downgradeLabel.Location = New-Object System.Drawing.Size(10,10)
    $downgradeLabel.Size = New-Object System.Drawing.Size(200,20)
    $downgradeLabel.Text = "Echo Navigator Downgrader"
    $downgradeLabel.Font = "Microsoft Sans Serif,11"
    $downgradeLabel.TextAlign = "MiddleCenter"
    $downgradeMenu.Controls.Add($downgradeLabel)

    $segmentLabel = New-Object System.Windows.Forms.Label
    $segmentLabel.Location = New-Object System.Drawing.Size(10,70)
    $segmentLabel.Size = New-Object System.Drawing.Size(200,20)
    $segmentLabel.Text = "Downloaded Segments"
    $segmentLabel.Font = "Microsoft Sans Serif,10"
    $segmentLabel.Visible = $false
    $downgradeMenu.Controls.Add($segmentLabel)

    $segmentProgress = New-Object System.Windows.Forms.ProgressBar
    $segmentProgress.Location = New-Object System.Drawing.Size(10,90)
    $segmentProgress.Size = New-Object System.Drawing.Size(200,15)
    $segmentProgress.Style = "Continuous"
    $segmentProgress.Maximum = 100
    $segmentProgress.Value = 0
    $segmentProgress.Visible = $false
    $downgradeMenu.Controls.Add($segmentProgress)

    $sizeLabel = New-Object System.Windows.Forms.Label
    $sizeLabel.Location = New-Object System.Drawing.Size(10,110)
    $sizeLabel.Size = New-Object System.Drawing.Size(200,20)
    $sizeLabel.Text = "Downloaded Size"
    $sizeLabel.Font = "Microsoft Sans Serif,10"
    $sizeLabel.Visible = $false
    $downgradeMenu.Controls.Add($sizeLabel)

    $sizeProgress = New-Object System.Windows.Forms.ProgressBar
    $sizeProgress.Location = New-Object System.Drawing.Size(10,130)
    $sizeProgress.Size = New-Object System.Drawing.Size(200,15)
    $sizeProgress.Style = "Continuous"
    $sizeProgress.Maximum = 100
    $sizeProgress.Value = 0
    $sizeProgress.Visible = $false
    $downgradeMenu.Controls.Add($sizeProgress)

    $timeRemainingLabel = New-Object System.Windows.Forms.Label
    $timeRemainingLabel.Location = New-Object System.Drawing.Size(10, 110)
    $timeRemainingLabel.Size = New-Object System.Drawing.Size(200,20)
    $timeRemainingLabel.Text = "Time Till Cancel Option: 1:00"
    $timeRemainingLabel.Font = "Microsoft Sans Serif,10"
    $timeRemainingLabel.Visible = $false
    $downgradeMenu.Controls.Add($timeRemainingLabel)


    $downgradeButton = New-Object System.Windows.Forms.Button
    $downgradeButton.Location = New-Object System.Drawing.Size(10,40)
    $downgradeButton.Size = New-Object System.Drawing.Size(200,30)
    $downgradeButton.Text = "Downgrade"
    $downgradeButton.Font = "Microsoft Sans Serif,10"
    $downgradeButton.Add_Click({

        if ($global:gamePath -eq $null -or $global:gamePath -eq "") {
            chooseFolder
        }

        $downgradeButton.enabled = $false
        $folderPicker.enabled = $false

        $downgradeButton.text = "Waiting for login..."
        $downgradeButton.Refresh()

        $registryPath = "HKCU\SOFTWARE\Classes\oculus"
        $backupPath = "$env:temp\oculus.reg"

        if (Test-Path $backupPath) {
            reg import $backupPath
            Remove-Item $backupPath
        }

        reg export $registryPath $backupPath


        New-Item -Path "HKCU:\Software\Classes\Oculus"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus" -Name "URL Protocol" -Value ""
        Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus" -Name "(Default)" -Value "URL:Oculus Protocol"
        New-Item -Path "HKCU:\Software\Classes\Oculus\shell"
        New-Item -Path "HKCU:\Software\Classes\Oculus\shell\open"
        New-Item -Path "HKCU:\Software\Classes\Oculus\shell\open\command"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Oculus\shell\open\command" -Name "(Default)" -Value "`"powershell.exe`" -executionPolicy bypass -windowStyle hidden -file $("$env:temp\setToken.ps1") `%1"

        'param($keys)' | Out-File -FilePath "$env:temp\setToken.ps1"
        '$keys | Out-File -FilePath "$env:temp\token"' | Out-File -FilePath "$env:temp\setToken.ps1" -Append
        '[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")' | Out-File -FilePath "$env:temp\setToken.ps1" -Append
        '[System.Windows.Forms.Application]::EnableVisualStyles()' | Out-File -FilePath "$env:temp\setToken.ps1" -Append
        '[System.Windows.Forms.MessageBox]::show("You have successfully logged in. You can close your browser and return to Echo Navigator", "Echo Navigator Downgrader","OK", "Information")' | Out-File -FilePath "$env:temp\setToken.ps1" -Append

        Start-Process "$(StartLogin)"

        while (1) {
            $startTime = Get-Date
            while (!(test-path "$env:temp\token") -and ((Get-Date) -lt ($startTime.AddMinutes(1)))) {
                start-sleep -Milliseconds 100
                $timeRemainingLabel.Visible = $true
                $timeRemainingLabel.Text = "Time Till Cancel Option: $((($startTime.AddMinutes(1)) - (Get-Date)).Minutes):$((($startTime.AddMinutes(1)) - (Get-Date)).Seconds)"
            }

            if (!(test-path "$env:temp\token")) {
                $choice = [System.Windows.Forms.MessageBox]::show("Looks like you have been logging in for a while, would you like to cancel the login?", "Echo Navigator Downgrader","YesNo", "Question")
                if ($choice -eq "Yes") {
                    if (Test-Path $backupPath) {
                        reg import $backupPath
                        Remove-Item $backupPath
                    }
                    $downgradeButton.text = "Try again"
                    $downgradeButton.enabled = $true
                    $folderPicker.enabled = $true
                    $timeRemainingLabel.Visible = $false
                    return
                }
            } else {
                break
            }
        }

        if (Test-Path $backupPath) {
            reg import $backupPath
            Remove-Item $backupPath
        }

        $timeRemainingLabel.Visible = $false
        $downgradeButton.text = "Logging in..."

        $tokenFile = get-content "$env:temp\token"
        remove-item "$env:temp\token"
        remove-item "$env:temp\setToken.ps1"
        $frl = UriCallback $tokenFile

        $downgradeButton.text = "Downloading Manifest..."
        $downgradeButton.Refresh()
        $folderPicker.Visible = $false
        $segmentProgress.Value = 0
        $segmentProgress.Refresh()
        try {
            Invoke-WebRequest -uri "https://securecdn.oculus.com/binaries/download/?id=6323983201049540&access_token=$frl&get_manifest=1" -OutFile "$env:temp\manifest.zip"
        } catch {
            [System.Windows.Forms.MessageBox]::show("Failed to start download. This is usually caused by you not owning Echo VR on the account you logged in with, or are disconnected from the internet.", "Echo Navigator Server Browser","OK", "Error")
            $downgradeButton.text = "Try again"
            $downgradeButton.enabled = $true
            return
        }
        Expand-Archive -Path "$env:temp\manifest.zip" -DestinationPath "$env:temp\manifest" -force
        $manifest = get-content "$env:temp\manifest\manifest.json" | convertfrom-json
        remove-item "$env:temp\manifest.zip"
        remove-item "$env:temp\manifest" -recurse -force
        $segmentCount = 0
        $totalSize = 0
        $downgradeButton.text = "Calculating Size..."
        $downgradeButton.Refresh()
        $fileNames = $manifest.files | Get-Member -MemberType NoteProperty | ForEach-Object { $_.Name }
        foreach ($fileName in $fileNames) {
            $file = $manifest.files.$fileName
            $segmentCount += $file.segments.count
            $totalSize += $file.size
        }

        if ($totalSize -gt (Get-PSDrive $global:gamePath[0]).Free) {
            [System.Windows.Forms.MessageBox]::show("You do not have enough free space to download the game. Please free up some space on your $($global:gamePath[0]) drive and try again.", "Echo Navigator Downgrader","OK", "Error")
            $downgradeButton.text = "Try again"
            $downgradeButton.enabled = $true
            return
        }

        if ($totalSize -gt ((Get-PSDrive $global:gamePath[0]).Free + 5GB)) {
            $choice = [System.Windows.Forms.MessageBox]::show("While you appear to have sufficient free space to download the game, Windows storage reservations may reduce the actual available space. It's recommended to free up additional space before proceeding with the download. Would you like to attempt the download regardless?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                $downgradeButton.text = "Try again"
                $downgradeButton.enabled = $true
                return
            }
        }

        $segmentsDownloaded = 0
        $segmentLabel.Visible = $true
        $segmentProgress.Visible = $true
        $sizeLabel.Visible = $true
        $sizeProgress.Visible = $true
        $downgradeButton.text = "Downloading..."
        $downgradeMenu.Refresh()
        Add-Type -AssemblyName System.Net.Http
        $client = [System.Net.Http.HttpClient]::new()
        for ($i=0; $i -lt $($manifest.files | get-member).name.count; $i++) {
            $folderName = $($($manifest.files | get-member).name[$i])
            $folderName = $folderName -split "\\"
            $folderName = $folderName[0..($folderName.Length - 2)]
            $folderName = $folderName -join "\"
            mkdir "$global:gamepath\..\evr.downloading\$folderName\" -ErrorAction SilentlyContinue
            $fileStream = New-Object System.IO.FileStream("$global:gamepath\..\evr.downloading\$($($manifest.files | get-member).name[$i])", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            $bufferSize = 10KB
            foreach ($segment in $manifest.files.$($($manifest.files | get-member).name[$i]).segments) {
                $targetStream = New-Object -TypeName System.IO.MemoryStream
                $uri = New-Object "System.Uri" "https://securecdn.oculus.com/binaries/segment/?access_token=$frl&binary_id=6323983201049540&segment_sha256=$($segment[1])"
                $client = New-Object System.Net.Http.HttpClient
                $response = $client.GetAsync($uri).Result
                $responseStream = $response.Content.ReadAsStreamAsync().Result
                $responseStream.CopyTo($targetStream, $bufferSize)
                $targetStream.Position = 0
                $targetStream.SetLength($targetStream.Length - 4)
                $targetStream.Position = 2
                $deflateStream = New-Object System.IO.Compression.DeflateStream($targetStream, [System.IO.Compression.CompressionMode]::Decompress)
                $deflateStream.CopyTo($fileStream, $bufferSize)
                $deflateStream.Close()
                $targetStream.Close()
                $responseStream.Close()
                $segmentsDownloaded++
                $segmentProgress.value = ($segmentsDownloaded / $segmentCount) * 100
                $segmentProgress.Refresh()
                $sizeProgress.value = (((Get-ChildItem "$global:gamepath\..\evr.downloading" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum + $fileStream.Length)/ $totalSize) * 100
                $sizeProgress.Refresh()
            }
            $fileStream.Close()
        }
        $segmentLabel.Visible = $false
        $sizeLabel.Visible = $false
        $sizeProgress.Visible = $false
        $downgradeButton.text = "Verifying..."
        $downgradeButton.Refresh()

        for ($i=0; $i -lt $($manifest.files | get-member).name.count; $i++) {
            $hash = (Get-FileHash -Path "$global:gamepath\..\evr.downloading\$($($manifest.files | get-member).name[$i])" -Algorithm SHA256).hash
            if ($hash -ne $manifest.files.$($($manifest.files | get-member).name[$i]).sha256) {
                $downgradeButton.text = "Downloading..."
                $fileStream = New-Object System.IO.FileStream("$global:gamepath\..\evr.downloading\$($($manifest.files | get-member).name[$i])", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
                $bufferSize = 10KB
                $segmentsDownloaded = 0
                foreach ($segment in $manifest.files.$($($manifest.files | get-member).name[$i]).segments) {
                    $targetStream = New-Object -TypeName System.IO.MemoryStream
                    $uri = New-Object "System.Uri" "https://securecdn.oculus.com/binaries/segment/?access_token=$frl&binary_id=6323983201049540&segment_sha256=$($segment[1])"
                    $client = New-Object System.Net.Http.HttpClient
                    $response = $client.GetAsync($uri).Result
                    $responseStream = $response.Content.ReadAsStreamAsync().Result
                    $responseStream.CopyTo($targetStream, $bufferSize)
                    $targetStream.Position = 0
                    $targetStream.SetLength($targetStream.Length - 4)
                    $targetStream.Position = 2
                    $deflateStream = New-Object System.IO.Compression.DeflateStream($targetStream, [System.IO.Compression.CompressionMode]::Decompress)
                    $deflateStream.CopyTo($fileStream, $bufferSize)
                    $deflateStream.Close()
                    $targetStream.Close()
                    $responseStream.Close()
                    $segmentsDownloaded++
                    $segmentProgress.value = ($segmentsDownloaded / $manifest.files.$($($manifest.files | get-member).name[$i]).segments.count) * 100
                    $segmentProgress.Refresh()
                }
                $fileStream.Close()
                $hash = (Get-FileHash -Path "$global:gamepath\..\evr.downloading\$($($manifest.files | get-member).name[$i])" -Algorithm SHA256).hash
                if ($hash -ne $manifest.files.$($($manifest.files | get-member).name[$i]).sha256) {
                    [System.Windows.Forms.MessageBox]::show("The download was corrupt even after a second download attempt. Please try again.", "Echo Navigator Downgrader","OK", "Error")
                    $downgradeButton.text = "Try again"
                    $downgradeButton.enabled = $true
                    return
                } else {
                    $downgradeButton.text = "Verifying..."
                    $downgradeButton.Refresh()
                }
            }
            $segmentProgress.value = ($i / $($manifest.files | get-member).name.count) * 100
            $segmentProgress.Refresh()
        }
        $segmentProgress.Visible = $false
        $folderPicker.Visible = $true
        $frl = $null

        rmdir "$global:gamepath\..\evr.downloading\Equals" -recurse -force
        rmdir "$global:gamepath\..\evr.downloading\GetHashCode" -recurse -force
        rmdir "$global:gamepath\..\evr.downloading\GetType" -recurse -force
        rmdir "$global:gamepath\..\evr.downloading\ToString" -recurse -force
        New-Item "$global:gamepath\..\evr.downloading\_local" -ItemType Directory -Force
        $downgradeButton.text = "Finished!"
        $downgradeButton.Refresh()
        $choice = [System.Windows.Forms.MessageBox]::show("Would you like to delete your old install?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Question)
        if ($choice -eq "Yes") {
            remove-item $global:gamePath -recurse -force
        } else {
            rename-item $global:gamePath "$global:gamePath.old"
        }
        rename-item "$global:gamepath\..\evr.downloading\" "ready-at-dawn-echo-arena" -force
        start-sleep -s 2
        $downgradeMenu.Close()
    })
    $downgradeMenu.Controls.Add($downgradeButton)

    $folderPicker = New-Object System.Windows.Forms.Button
    $folderPicker.Location = New-Object System.Drawing.Size(10,80)
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
        $pickMenu.text = "Echo Navigator Downgrader"
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
            $choice = [System.Windows.Forms.MessageBox]::Show("It is recommended that you use the pre-selected folder so that the Oculus app launches the downgraded version of the game.`n`n`While you can use a custom path it is not recommended. Would you still like to use a custom path?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
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
                $choice = [System.Windows.Forms.MessageBox]::show("It is recommended that you use the pre-selected folder so that the Oculus app launches the downgraded version of the game.`n`n`While you can still pick this folder it is not recommended. Would you still like to use the selected folder?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
                if ($choice -eq "No") {
                    return
                }
            }
            $global:gamePath = "$($pickList.SelectedItem)\Software\ready-at-dawn-echo-arena"
            $pickMenu.Close()
        })
        $pickMenu.Controls.Add($pickButton)

        $pickMenu.ShowDialog()
    })
    $downgradeMenu.Controls.Add($folderPicker)

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
    if ($global:gamePath -eq "Please select game folder") {
        $noUsernameOrPassword.Text = "Please select game folder"
        $noUsernameOrPassword.Visible = $true
        $currentPath.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $currentPath.ForeColor = "Black"
        start-sleep -Milliseconds 150
        $currentPath.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $currentPath.ForeColor = "Black"
        start-sleep -Milliseconds 150
        $currentPath.ForeColor = "Red"
        start-sleep -Milliseconds 150
        $currentPath.ForeColor = "Black"
        return
    }
    if (!(Test-Path $env:localappdata\rad-backup)) {
        Copy-Item "$env:localappdata\rad" "$env:localappdata\rad-backup" -Recurse
    }
    if ((Get-FileHash -Path $global:gamePath\bin\win10\echovr.exe).hash -ne "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043") {
        $noUsernameOrPassword.Text = "You are on the wrong version of EchoVR"
        $noUsernameOrPassword.Visible = $true
        $choice = [System.windows.forms.messagebox]::show("You are on the wrong version of EchoVR, would you like to downgrade?" , "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
        if ($choice -eq "Yes") {
            downgrade
        } else {
            return
        }
    }
    if ((Get-FileHash -Path $global:gamePath\bin\win10\echovr.exe).hash -ne "B6D08277E5846900C81004B64B298DF6ACBA834B69700A640B758BDA94A52043") {
        [system.windows.forms.messagebox]::Show("The game was not downgraded, please try again.", "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Warning)
        return
    }
    mkdir "$env:appdata\EchoNavigator\"
    $config = @{}
    $config | Add-Member -Name 'username' -Type NoteProperty -Value "$($usernameBox.text)"
    $config | Add-Member -Name 'password' -Type NoteProperty -Value "$($passwordBox.text)"
    $config | Add-Member -Name 'gamePath' -Type NoteProperty -Value "$($global:gamePath)"
    $config | convertto-json | set-content "$env:appdata\EchoNavigator\config.json"
    Invoke-WebRequest "https://aldin101.github.io/EchoNavigatorAPI/EchoNavigator.exe" -OutFile "$global:gamePath\bin\win10\EchoNavigator.exe"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Echo Navigator.lnk")
    $Shortcut.TargetPath = "$global:gamePath\bin\win10\EchoNavigator.exe"
    $Shortcut.Save()
    if (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EchoNavigator") {
        Remove-Item HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EchoNavigator -Recurse -Force
        Remove-Item HKCU:\Software\Classes\EchoNavigator -Recurse -Force
    }
    [system.windows.forms.messagebox]::Show("Echo Navigator installed!`n`nSelect a server to get started!", "Echo Navigator Installer", [system.windows.forms.messageboxbuttons]::OK, [system.windows.forms.messageboxicon]::Information)
    start-process "$global:gamePath\bin\win10\EchoNavigator.exe" -WorkingDirectory "C:\"
    $menu.Close()
}

function pickGameFolder {
    $locations = Get-ChildItem "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\*"
    $locationList = [System.Collections.ArrayList]@()
    foreach ($location in $locations) {
        $locationList.Add($(Get-ItemProperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\$($location.PSChildName)" -Name OriginalPath | select -ExpandProperty OriginalPath))
    }

    $pickMenu = new-object System.Windows.Forms.Form
    $pickMenu.text = "Echo Navigator Installer"
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
        $choice = [System.Windows.Forms.MessageBox]::Show("It is recommended that you use the pre-selected folder so that the Oculus app launches the correct version of the game.`n`n`While you can use a custom path it is not recommended. Would you still like to use a custom path?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
        if ($choice -eq "No") {
            return
        }
        $newFolder = Read-FolderBrowserDialog -Message "Select the folder Echo VR is installed in"
        if (!(test-path "$newFolder\bin\win10\echovr.exe")) {
            $choice = [System.Windows.Forms.MessageBox]::show("Echo VR was not found in this folder, would you like to continue anyways?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                return
            }
        }
        $global:gamePath = $newFolder
        $pickMenu.Close()
    })
    $pickMenu.Controls.Add($customPath)

    $pickButton = New-Object System.Windows.Forms.Button
    $pickButton.Location = New-Object System.Drawing.Size(10,180)
    $pickButton.Size = New-Object System.Drawing.Size(280,30)
    $pickButton.Text = "Select"
    $pickButton.Font = "Microsoft Sans Serif,10"
    $pickButton.Add_Click({
        if (!(test-path "$($locationList[$picklist.SelectedIndex])\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe")) {
            $choice = [System.Windows.Forms.MessageBox]::show("Echo VR was not found in this folder, would you like to continue anyways?", "Echo Navigator Downgrader", [system.windows.forms.messageboxbuttons]::YesNo, [system.windows.forms.messageboxicon]::Warning)
            if ($choice -eq "No") {
                return
            }
        }
        $global:gamePath = "$($pickList.SelectedItem)\Software\ready-at-dawn-echo-arena"
        $pickMenu.Close()
    })
    $pickMenu.Controls.Add($pickButton)

    $pickMenu.ShowDialog()
}

function findGameFolder {
    $locations = Get-ChildItem "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\*"
    $locationList = [System.Collections.ArrayList]@()
    foreach ($location in $locations) {
        $locationList.Add($(Get-ItemProperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries\$($location.PSChildName)" -Name OriginalPath | select -ExpandProperty OriginalPath)) | Out-Null
    }
    $locations = [system.Collections.ArrayList]@()
    foreach ($location in $locationList) {
        if (test-path "$location\Software\ready-at-dawn-echo-arena\bin\win10\echovr.exe") {
            $locations.Add($location) | Out-Null
        }
    }
    if ($locations.count -eq 1) {
        return "$($locations)\Software\ready-at-dawn-echo-arena"
    } else {
        return $null
    }
}

$global:gamePath = findGameFolder
if ($global:gamePath -eq $null) {
    $global:gamePath = "Please select game folder"
}

[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
$menu = new-object System.Windows.Forms.Form
$menu.text = "Echo Navigator Installer"
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
$credits.Text = "Echo Navigator Created By: Aldin101`nOriginal Echo Relay Created By:Xenomega"
$credits.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($credits)

$currentPath = New-Object System.Windows.Forms.Label
$selectGameFolder = New-Object System.Windows.Forms.Button
$selectGameFolder.Location = New-Object System.Drawing.Size(10,220)
$selectGameFolder.Size = New-Object System.Drawing.Size(200,30)
$selectGameFolder.Text = "Select Game Folder"
$selectGameFolder.Font = "Microsoft Sans Serif,10"
$selectGameFolder.Add_Click({
    pickGameFolder
    $currentPath.Text = "Current Game Folder:`n$global:gamePath"
})
$currentPath.Text = "Current Game Folder:`n$global:gamePath"
$menu.Controls.Add($selectGameFolder)

$currentPath.Location = New-Object System.Drawing.Size(10,250)
$currentPath.Size = New-Object System.Drawing.Size(2000,200)
$currentPath.Font = "Microsoft Sans Serif,10"
$menu.Controls.Add($currentPath)

$menu.ShowDialog()


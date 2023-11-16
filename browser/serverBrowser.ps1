#start-sleep -s 3

function joinServer {
    if ($global:config.$($database.online[$global:rowIndex].ip) -eq $null) {
        $usernamePicker = New-Object System.Windows.Forms.Form
        $usernamePicker.Text = "Echo Relay Server Browser"
        $usernamePicker.Size = New-Object System.Drawing.Size(280, 150)
        $usernamePicker.StartPosition = "CenterScreen"
        $usernamePicker.FormBorderStyle = "FixedDialog"
        $usernamePicker.MaximizeBox = $false
        $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")

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
            $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
        })
        $usernamePicker.Controls.Add($usernameButton)

        $usernamePicker.showDialog()
    }

    if ($global:config.$($database.online[$global:rowIndex].ip) -eq $null) {
        [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Relay Server Browser", "OK", "Warning")
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
    $gameConfig | convertto-json | set-content "$($global:config.gamePath)\_local\config.json"
    if ($selectPlay.enabled -eq $true) {
        [system.windows.forms.messagebox]::Show("You will now load into $($database.online[$global:rowIndex].name) when you start Echo VR", "Echo Relay Server Browser", "OK", "Information")
    }
}

function clientJoinServer {
    if ($global:config.$($config.servers[$global:rowIndex].ip) -eq $null) {
        $usernamePicker = New-Object System.Windows.Forms.Form
        $usernamePicker.Text = "Echo Relay Server Browser"
        $usernamePicker.Size = New-Object System.Drawing.Size(280, 150)
        $usernamePicker.StartPosition = "CenterScreen"
        $usernamePicker.FormBorderStyle = "FixedDialog"
        $usernamePicker.MaximizeBox = $false
        $usernamePicker.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")


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
            $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
        })
        $usernamePicker.Controls.Add($usernameButton)

        $usernamePicker.showDialog()
    }

    if ($global:config.$($global:config.servers[$global:rowIndex].ip) -eq $null) {
        [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Relay Server Browser", "OK", "Warning")
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
    $gameConfig | convertto-json | set-content "$($global:config.gamePath)\_local\config.json"
    if ($selectPlay.enabled -eq $true) {
        [system.windows.forms.messagebox]::Show("You will now load into $($config.servers[$global:rowIndex].name) when you start Echo VR", "Echo Relay Server Browser", "OK", "Information")
    }
}

function addOnlineServer {

    if ($database.api -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("The API is not online right now, check back later.", "Echo Relay Server Browser", "OK", "Information")
        return
    }

    $addServer = New-Object System.Windows.Forms.Form
    $addServer.Text = "Echo Relay Server Browser"
    $addServer.Size = New-Object System.Drawing.Size(330, 500)
    $addServer.StartPosition = "CenterScreen"
    $addServer.FormBorderStyle = "FixedDialog"
    $addServer.MaximizeBox = $false
    $addServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")

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
            [system.windows.forms.messagebox]::Show("PowerShell 7 is not supported", "Echo Relay Server Browser", "OK", "Error")
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
            [system.windows.forms.messagebox]::Show("Server added successfully, it might take 5 minutes before it can be found in the server list.", "Echo Relay Server Browser", "OK", "Information")
            $addServer.Close()
        }
        catch {
            $errorMessage = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
            [system.windows.forms.messagebox]::Show("Failed to add server, the server replied with `"$errorMessage`"", "Echo Relay Server Browser", "OK", "Error")
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
            $usernamePicker.Text = "Echo Relay Server Browser"
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
                $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
            })
            $usernamePicker.Controls.Add($usernameButton)

            $usernamePicker.ShowDialog()
        }

        if ($global:config.'62.68.167.123' -eq $null) {
            [system.windows.forms.messagebox]::Show("You must enter a username", "Echo Relay Server Browser", "OK", "Warning")
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

function stopMatchmaking {
    $cancelMatchmaking.Dispose()
    $searchingLabel.Dispose()
    $screenCover.Dispose()
    $playerSlots.Dispose()
    $playerSlotsSearching.Dispose()
    $cancelMatchmaking.Dispose()
    $getMatchTimer.Dispose()
    $voteForEarlyStart.Dispose()
    $voteCountLabel.Dispose()
    $otherServers.Enabled = $true

}
function matchmaking {

    $config.username = random -Minimum 100000 -Maximum 999999

    $otherServers.Enabled = $false
    $global:screenCover = New-Object System.Windows.Forms.Label
    $screenCover.Size = New-Object System.Drawing.Size(1280, 720)
    $screenCover.Location = New-Object System.Drawing.Point(0, -80)
    $screenCover.Text = "Finding Match"
    $screenCover.TextAlign = 'MiddleCenter'
    $screenCover.Font = New-Object System.Drawing.Font("Arial", 50)
    $combatLounge.Controls.Add($screenCover)
    $screenCover.BringToFront()

    $joinMatchmaker = start-job {
        param($config, $api)
        $data = @{
            action = "joinMatchmaker"
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
            userName = $config.username
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$api" -Method Post -ContentType "application/json" -Body $data
        return $response
    } -ArgumentList $global:config, $database.api

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(400, 20)
    $progressBar.Location = New-Object System.Drawing.Point(440, 325)
    $progressBar.Style = 'Marquee'
    $combatLounge.Controls.Add($progressBar)
    $progressBar.BringToFront()

    do {
        $screenCover.Refresh()
        $progressBar.Refresh()
        Start-Sleep -Milliseconds 10
    } while ($joinMatchmaker.State -eq "Running")
    $screenCover.text = ""
    $progressBar.Dispose()
    $global:getMatch = $joinMatchmaker | receive-job
    $global:playerInfo = $global:getMatch.Players
    $joinMatchmaker | remove-job

    if ($getMatch -eq $null) {
        $screenCover.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 0, 0)
        $screenCover.Text = "Failed to join matchmaking"
        $screenCover.Refresh()
        Start-Sleep -Seconds 3
        stopMatchmaking
        return
    }

    if ($getMatch.players.count -gt 8) {
        $getMatchTimer.Interval = 99999
        $getMatchTimer.stop()
        $screenCover.text = "`nAn error has occurred."
        $screenCover.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 0, 0)
        $screenCover.bringToFront()
        $screenCover.Refresh()
        Start-Sleep -Seconds 3
        $data = @{
            action = "getMatch"
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
            userName = "Join error"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data
        stopMatchmaking
        return
    }

    $global:searchingLabel = New-Object System.Windows.Forms.Label
    $searchingLabel.Size = New-Object System.Drawing.Size(500, 70)
    $searchingLabel.Location = New-Object System.Drawing.Point(10, 10)
    $searchingLabel.Text = "Searching for players..."
    $searchingLabel.Font = New-Object System.Drawing.Font("Arial", 20)
    $combatLounge.Controls.Add($searchingLabel)
    $searchingLabel.BringToFront()

    $global:playerSlotsSearching = New-Object System.Windows.Forms.Label[] 8
    for ($i=0; $i -lt 8; ++$i) {
        $playerSlotsSearching[$i] = New-Object System.Windows.Forms.Label
        $playerSlotsSearching[$i].Size = New-Object System.Drawing.Size(200, 35)
        $playerSlotsSearching[$i].Location = New-Object System.Drawing.Point(10, (100+$i*40))
        $playerSlotsSearching[$i].BackColor = [System.Drawing.Color]::FromArgb(100, 0, 0, 0)
        $playerSlotsSearching[$i].BorderStyle = 'FixedSingle'
        $playerSlotsSearching[$i].Font = New-Object System.Drawing.Font("Arial", 20)
        $playerSlotsSearching[$i].Text = "Searching..."
        $combatLounge.Controls.Add($playerSlotsSearching[$i])
        $playerSlotsSearching[$i].BringToFront()
    }

    $global:voteForEarlyStart = New-Object System.Windows.Forms.Button
    $voteForEarlyStart.Size = New-Object System.Drawing.Size(200, 35)
    $voteForEarlyStart.Location = New-Object System.Drawing.Point(10, 450)
    $voteForEarlyStart.Text = "Vote to begin"
    $voteForEarlyStart.Visible = $false
    $voteForEarlyStart.add_click({
        $voteForEarlyStart.Text = "Voting..."
        $voteForEarlyStart.Enabled = $false
        $voteForEarlyStart.Refresh()
        $data=@{
            action = "voteForEarlyStart"
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
            userName = $global:config.username
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data
        $voteForEarlyStart.text = "Voted!"
        $voteCountLabel.Text = "$($getMatch.voted.count+1)/$($getMatch.neededToStart)"
        foreach ($playerSlot in $playerSlots) {
            if ($config.username -eq $playerSlot.Text) {
                $playerSlot.BackColor = [System.Drawing.Color]::FromArgb(100, 0, 255, 0)
                $playerSlot.Refresh()
            }
        }
        $voteForEarlyStart.Refresh()
        $voteCountLabel.Refresh()
    })
    $combatLounge.Controls.Add($voteForEarlyStart)
    $voteForEarlyStart.BringToFront()

    $global:voteCountLabel = New-Object System.Windows.Forms.Label
    $voteCountLabel.Size = New-Object System.Drawing.Size(200, 35)
    $voteCountLabel.Location = New-Object System.Drawing.Point(220, 450)
    $voteCountLabel.Text = "$($getMatch.voted.count)/Loading..."
    $voteCountLabel.Font = New-Object System.Drawing.Font("Arial", 20)
    $voteCountLabel.Visible = $false
    $combatLounge.Controls.Add($voteCountLabel)
    $voteCountLabel.BringToFront()

    if ($getMatch.players.count -gt 3) {
        $voteForEarlyStart.Visible = $true
        $voteCountLabel.Visible = $true
    } else {
        $voteForEarlyStart.Visible = $false
        $voteCountLabel.Visible = $false
    }

    $global:cancelMatchmaking = New-Object System.Windows.Forms.Button
    $cancelMatchmaking.Size = New-Object System.Drawing.Size(200, 35)
    $cancelMatchmaking.Location = New-Object System.Drawing.Point(10, 600)
    $cancelMatchmaking.Text = "Cancel Matchmaking"
    $cancelMatchmaking.add_click({
        $data = @{
            action = "cancelMatchmaking"
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
            userName = $global:config.username
        } | ConvertTo-Json
        Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data
        stopMatchmaking
    })
    $combatLounge.Controls.Add($cancelMatchmaking)
    $cancelMatchmaking.BringToFront()

    $global:playerSlots = New-Object System.Windows.Forms.Label[] 8
    for ($i = 0; $i -lt $playerSlots.Length; $i++) {
        $playerSlots[$i] = New-Object System.Windows.Forms.Label
        $playerSlots[$i].Size = New-Object System.Drawing.Size(200, 35)
        $playerSlots[$i].Location = New-Object System.Drawing.Point(-300, (100+$i*40))
        $playerSlots[$i].Text = $playerInfo[$i]
        $playerSlots[$i].BackColor = [System.Drawing.Color]::FromArgb(100, 0, 0, 255)
        $playerSlots[$i].BorderStyle = 'FixedSingle'
        $playerSlots[$i].Font = New-Object System.Drawing.Font("Arial", 20)
        $combatLounge.Controls.Add($playerSlots[$i])
        $playerSlots[$i].BringToFront()
    }

    $i=0
    foreach ($player in $playerInfo) {
        $playerSlots[$i].Text = $player
        if ($config.username -eq $player) {
            while ($playerSlotsSearching[$i].Location.X -gt -300) {
                $playerSlotsSearching[$i].Location = New-Object System.Drawing.Point($($playerSlotsSearching[$i].Location.X-10), $playerSlotsSearching[$i].Location.Y)
                $playerSlotsSearching[$i].Refresh()
                start-sleep -Milliseconds 1
            }
            while ($playerSlots[$i].Location.X -lt 10) {
                $playerSlots[$i].Location = New-Object System.Drawing.Point($($playerSlots[$i].Location.X+10), $playerSlots[$i].Location.Y)
                $playerSlots[$i].Refresh()
                start-sleep -Milliseconds 1
            }
        }
        $playerSlotsSearching[$i].Location = New-Object System.Drawing.Point($(-300), $playerSlotsSearching[$i].Location.Y)
        $playerSlots[$i].Location = New-Object System.Drawing.Point($(10), $playerSlots[$i].Location.Y)
        $i++
    }

    $global:getMatchTimer = New-Object System.Windows.Forms.Timer
    $getMatchTimer.Interval = 3000

    $getMatchTimer.add_Tick({
        if ($getMatch.players.count -gt 8) {
            $getMatchTimer.Stop()
            $getMatchTimer.Interval = 99999
            $screenCover.text = "`nAn error has occurred."
            $screenCover.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 0, 0)
            $screenCover.bringToFront()
            $screenCover.Refresh()

            $global:ErrorOK = New-Object System.Windows.Forms.Button
            $ErrorOK.Size = New-Object System.Drawing.Size(200, 35)
            $ErrorOK.Location = New-Object System.Drawing.Point(10, 600)
            $ErrorOK.Text = "OK"
            $ErrorOK.add_click({
                stopMatchmaking
                $ErrorOK.Dispose()
            })
            $combatLounge.Controls.Add($ErrorOK)
            $ErrorOK.BringToFront()
            $ErrorOK.Refresh()

            return
        }
        if ($getMatch.players.count -lt $oldGetMatch.players.count) {
            write-output "player left"
            foreach ($slot in $playerSlotsSearching) {
                if ($slot.Location.X -lt 10) {
                    $slot.Location = New-Object System.Drawing.Point(10, $slot.Location.Y)
                    $slot.Refresh()
                }
            }
            for($i=0; $i -lt 8; $i++) {
                while ($playerSlots[0].Location.X -gt -300) {
                    foreach ($slot in $playerSlots) {
                        if ($slot.Location.X -gt -300) {
                            $slot.Location = New-Object System.Drawing.Point($($slot.Location.X-10), $slot.Location.Y)
                            $slot.Refresh()
                        }
                    }
                    start-sleep -Milliseconds 1
                }
            }
            foreach ($slot in $playerSlots) {
                $slot.Text = ""
                $slot.Refresh()
            }
            for($i=0; $i -lt $getMatch.players.count; $i++) {
                $playerSlots[$i].Text = $getMatch.players[$i]
            }
            $i=0
            while ($playerSlots[0].Location.X -lt 10) {
                foreach ($slot in $playerSlots) {
                    if ($slot.Location.X -lt 10 -and $getMatch.players -contains $slot.Text) {
                        $slot.Location = New-Object System.Drawing.Point($($slot.Location.X+10), $slot.Location.Y)
                        $slot.Refresh()
                    }
                }
                start-sleep -Milliseconds 1
            }
            for($i=0; $i -lt $getMatch.players.count; $i++) {
                $playerSlotsSearching[$i].Location = New-Object System.Drawing.Point(-300, $playerSlotsSearching[$i].Location.Y)
                $playerSlotsSearching[$i].Refresh()
            }
        }
        if ($getMatch.players.count -gt $oldGetMatch.players.count) {
            write-output "new player"
            for($i=0; $i -lt $getMatch.players.count; $i++) {
                $playerSlots[$i].Text = $getMatch.players[$i]
                while ($playerSlotsSearching[$i].Location.X -gt -300) {
                    $playerSlotsSearching[$i].Location = New-Object System.Drawing.Point($($playerSlotsSearching[$i].Location.X-10), $playerSlotsSearching[$i].Location.Y)
                    $playerSlotsSearching[$i].Refresh()
                    start-sleep -Milliseconds 1
                }
                while ($playerSlots[$i].Location.X -lt 10) {
                    $playerSlots[$i].Location = New-Object System.Drawing.Point($($playerSlots[$i].Location.X+10), $playerSlots[$i].Location.Y)
                    $playerSlots[$i].Refresh()
                    start-sleep -Milliseconds 1
                }
            }
        }
        if ($getMatch.players.count -gt 3) {
            $voteForEarlyStart.Visible = $true
            $voteCountLabel.Visible = $true
            $voteCountLabel.Text = "$($getMatch.voted.count)/$($getMatch.neededToStart)"
            foreach ($playerSlot in $playerSlots) {
                if ($getMatch.voted -notcontains $playerSlot.Text) {
                    $playerSlot.BackColor = [System.Drawing.Color]::FromArgb(100, 255, 0, 0)
                    $playerSlot.Refresh()
                } else {
                    $playerSlot.BackColor = [System.Drawing.Color]::FromArgb(100, 0, 255, 0)
                    $playerSlot.Refresh()
                }
            }
        } else {
            $voteForEarlyStart.Visible = $false
            $voteCountLabel.Visible = $false
        }
        if ($getMatch.startTime -ne $null) {
            $getMatchTimer.Stop()
            if ($getMatch.ID -eq $null) {
                $searchingLabel.text = "No game servers are available to host this match, try again later."
                $searchingLabel.Refresh()
                start-sleep -s 5
                stopMatchmaking
                return
            }
            while ([int][double]::Parse((Get-Date (get-date).ToUniversalTime() -UFormat %s)) -lt $getMatch.startTime) {
                $searchingLabel.Text = "Match ready, starting in $([int](($getMatch.startTime - (Get-Date (get-date).ToUniversalTime() -UFormat %s)))) seconds..."
                if ($searchingLabel.Text -eq "Match ready, starting in 1 seconds...") {
                    $searchingLabel.Text = "Match ready, starting in 1 second..."
                }
                $searchingLabel.Refresh()
                start-sleep -Milliseconds 100
            }
            $global:getMatchTimer.stop()
            $screenCover.text = "Game running"
            $screenCover.BringToFront()
            $screenCover.Refresh()
            $global:job = start-job ({
                param($getMatch, $config)
                Start-Process "$($config.gamePath)\bin\win10\EchoVR.exe" -wait #-ArgumentList "-join $($getMatch.ID)"
                return
            }) -ArgumentList $getMatch, $global:config
            $global:gameRunTimer = New-Object System.Windows.Forms.Timer
            $gameRunTimer.Interval = 1000
            $gameRunTimer.add_tick({
                if ($job.state -ne "Running") {
                    Remove-Job $job
                    $gameRunTimer.Stop()
                    stopMatchmaking
                }
            })
            $gameRunTimer.Start()
        }
        $global:oldGetMatch = $getMatch
        $data = @{
            action = "getMatch"
            userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
            userName = $config.username
        } | ConvertTo-Json
        try {
            $global:getMatch = Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data

            $searchingLabel.text = "Searching for players..."
            $searchingLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)
            $searchingLabel.BackColor = [System.Drawing.Color]::Transparent
            $searchingLabel.Refresh()
        } catch {
            if ($searchingLabel.text -eq "Searching for players...`nThe connection is unstable!") {
                $getMatchTimer.Stop()
                $screenCover.text = "`nA communication error has occurred."
                $screenCover.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 0, 0)
                $screenCover.bringToFront()
                $screenCover.Refresh()

                $global:commErrorOK = New-Object System.Windows.Forms.Button
                $commErrorOK.Size = New-Object System.Drawing.Size(200, 35)
                $commErrorOK.Location = New-Object System.Drawing.Point(10, 600)
                $commErrorOK.Text = "OK"
                $commErrorOK.add_click({
                    $commErrorOK.Dispose()
                    stopMatchmaking
                })
                $combatLounge.Controls.Add($commErrorOK)
                $commErrorOK.BringToFront()

                return
            }
            $searchingLabel.text = "Searching for players...`nThe connection is unstable!"
            $searchingLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 255, 0)
            $searchingLabel.BackColor = [System.Drawing.Color]::FromArgb(100, 0, 0, 0)
            $searchingLabel.Refresh()
        }
        if ($getMatch.players.count -eq 8 -and $searchingLabel.text -ne "Searching for players...`nThe connection is unstable!" -and $match.startTime -eq $null) {
            $searchingLabel.text = "Match ready, preparing..."
            $searchingLabel.Refresh()
        }
    })

    $getMatchTimer.Start()
}

$ProgressPreference = 'SilentlyContinue'

[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[system.windows.forms.application]::enablevisualstyles()

$file = Invoke-WebRequest "https://aldin101.github.io/echo-relay-server-browser/servers.json" -UseBasicParsing
$database = $file.content | ConvertFrom-Json
$global:config = Get-Content "$env:appdata\Echo Relay Server Browser\config.json" | ConvertFrom-Json

if ($database -eq $null) {
    [System.Windows.Forms.MessageBox]::Show("Failed to download online resources. Check your internet connection and try again.", "Echo Relay Server Browser", "OK", "Error")
    exit
}

if ((get-item -path "$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe").VersionInfo.FileVersion -ne $database.currentVersion) {
    taskkill /f /im "Echo Relay Server Browser.exe"
    remove-item "$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe"
    Invoke-WebRequest "https://aldin101.github.io/echo-relay-server-browser/Echo%20Relay%20Server%20Browser.exe" -OutFile "$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe"
    start-process "$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe"
    exit
}

$global:clientselected = $false

$menu = New-Object System.Windows.Forms.Form
$menu.Text = "Echo Relay Server Browser"
$menu.Size = New-Object System.Drawing.Size(1280, 720)
$menu.StartPosition = "CenterScreen"
$menu.FormBorderStyle = "FixedDialog"
$menu.MaximizeBox = $false
$menu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")


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
        $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
    }
    if ($tabs.SelectedTab -eq $otherServers) {
        $global:config.tab = 1
        $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
    }
})
$menu.Controls.Add($tabs)
$combatLounge = New-Object System.Windows.Forms.TabPage
$combatLounge.Text = "Combat Lounge"
$combatLounge.Size = New-Object System.Drawing.Size(1280, 720)
$combatLounge.Location = New-Object System.Drawing.Point(0, 0)
$tabs.Controls.Add($combatLounge)

$otherServers = New-Object System.Windows.Forms.TabPage
$otherServers.Text = "Other Servers"
$otherServers.Size = New-Object System.Drawing.Size(1280, 720)
$otherServers.Location = New-Object System.Drawing.Point(0, 0)
$tabs.Controls.Add($otherServers)

if ($global:config.tab -eq $null) {
    $global:config | Add-Member -Type NoteProperty -Name 'tab' -Value 1
    $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
}

$tabs.SelectedIndex = $global:config.tab

#combat lounge ---------------------

$currentServer = Get-Content "$($global:config.gamePath)\_Local\config.json" | ConvertFrom-Json
if ($currentServer.apiservice_host -ne "http://62.68.167.123:1234/api") {combatLoungeNotSelected}


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
$combatLoungeList.ColumnCount = 4
$combatLoungeList.RowCount = $database.combatLounge.Count
$combatLoungeList.ColumnHeadersVisible = $true
$combatLoungeList.TabIndex = 0
$combatLoungeList.Columns[0].Name = "Players"
$combatLoungeList.Columns[0].Width = 50
$combatLoungeList.Columns[1].Name = "Game Mode"
$combatLoungeList.Columns[1].Width = 200
$combatLoungeList.Columns[2].Name = "Region"
$combatLoungeList.Columns[2].Width = 50
$combatLoungeList.Columns[3].Name = "Ping"
$combatLoungeList.Columns[3].Width = 50
$combatLoungeList.Columns[3].DefaultCellStyle.Alignment = 'MiddleCenter'

$combatLoungeList.Add_CellClick({
    param($sender, $e)
    $combatLoungeList.ClearSelection()
    $combatLoungeList.Rows[$e.RowIndex].Selected = $true
    $combatSideBar.Visible = $true
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
})

$combatLoungeList.Add_KeyDown({
    param($sender, $e)

    if ($e.KeyCode -eq 'Enter') {
        $combatLoungeList.ClearSelection()
        $combatLoungeList.Rows[$e.RowIndex].Selected = $true
        $global:rowIndex = $e.RowIndex
        $global:clientselected = $true
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to join $($combatGames.gameServers[$global:RowIndex].gameMode)?", "Echo Relay Server Browser", "YesNo", "Question")
        if ($choice -eq "Yes") {
            Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-join $($combatGames.gameServer[$global:RowIndex].sessionID)" -Wait
        }
    }
})

$combatLoungeList.Add_CellDoubleClick({
    param($sender, $e)
    $combatLoungeList.ClearSelection()
    $combatLoungeList.Rows[$e.RowIndex].Selected = $true
    $global:rowIndex = $e.RowIndex
    $global:clientselected = $true
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to join $($combatGames.gameServers[$global:RowIndex].gameMode)?", "Echo Relay Server Browser", "YesNo", "Question")
    if ($choice -eq "Yes") {
        Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-join $($combatGames.gameServer[$global:RowIndex].sessionID)" -Wait
    }
})

$combatGames = Invoke-WebRequest "http://51.75.140.182:3000/api/listGameServers/62.68.167.123"
$combatGames = $combatGames.content | ConvertFrom-Json


ForEach-Object -InputObject $combatGames.gameServers {
    $PingServer = Test-Connection -count 1 -ComputerName $_.serverIP.ip
    $combatLoungeList.Rows.Add($_.players, $_.gameMode, $_.region, $PingServer)
}

$combatLounge.Controls.Add($combatLoungeList)

$matchmakingLabel = New-Object System.Windows.Forms.Label
$matchmakingLabel.Size = New-Object System.Drawing.Size(200, 20)
$matchmakingLabel.Location = New-Object System.Drawing.Point(10, 470)
$matchmakingLabel.Text = "Matchmaking:"
$matchmakingLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$combatLounge.Controls.Add($matchmakingLabel)

$matchmakingButton = New-Object System.Windows.Forms.Button
$matchmakingButton.Size = New-Object System.Drawing.Size(250, 35)
$matchmakingButton.Location = New-Object System.Drawing.Point(10, 500)
$matchmakingButton.Text = "Join Matchmaking"
$matchmakingButton.add_click({matchmaking})
$combatLounge.Controls.Add($matchmakingButton)

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
$currentGameModeDescription.Text = "Game Mode Objective Placeholder"
$currentGameModeDescription.Font = New-Object System.Drawing.Font("Arial", 12)
$currentGameModeDescription.BackColor = 'LightGray'
$combatSideBar.Controls.Add($currentGameModeDescription)

$join = New-Object System.Windows.Forms.Button
$join.Size = New-Object System.Drawing.Size(345, 50)
$join.Location = New-Object System.Drawing.Point(10, 600)
$join.Text = "Join Game"
$join.Font = New-Object System.Drawing.Font("Arial", 12)
$join.add_click({
    Start-Process "$($global:config.gamePath)\bin\win10\EchoVR.exe" -ArgumentList "-join $($combatGames.gameServers[$global:RowIndex].sessionID)" -Wait
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
$serverRightClick.Items.Add($selectPlayRightClick)

$separator1 = New-Object System.Windows.Forms.ToolStripSeparator
$serverRightClick.Items.Add($separator1)

$reportServer = New-Object System.Windows.Forms.ToolStripMenuItem
$reportServer.Text = "Report Server"
$reportServer.add_Click({

    if ($database.api -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("The API is not online right now, check back later.", "Echo Relay Server Browser", "OK", "Information")
        return
    }

    $reportServer = New-Object System.Windows.Forms.Form
    $reportServer.Text = "Echo Relay Server Browser"
    $reportServer.Size = New-Object System.Drawing.Size(330, 290)
    $reportServer.StartPosition = "CenterScreen"
    $reportServer.FormBorderStyle = "FixedDialog"
    $reportServer.MaximizeBox = $false
    $reportServer.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")

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
            [system.windows.forms.messagebox]::Show("PowerShell 7 is not supported", "Echo Relay Server Browser", "OK", "Error")
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
            [system.windows.forms.messagebox]::Show("Server reported`n`nWe care about your feedback and will deal with your report as fast as we can.", "Echo Relay Server Browser", "OK", "Information")
            $reportServer.Close()
        }
        catch {
            $errorMessage = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
            [system.windows.forms.messagebox]::Show("The report failed, the server replied with `"$errorMessage`"", "Echo Relay Server Browser", "OK", "Error")
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
    $serverPropertiesWindow.Text = "Echo Relay Server Browser"
    $serverPropertiesWindow.Size = New-Object System.Drawing.Size(600, 290)
    $serverPropertiesWindow.StartPosition = "CenterScreen"
    $serverPropertiesWindow.FormBorderStyle = "FixedDialog"
    $serverPropertiesWindow.MaximizeBox = $false
    $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")


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
    $serverImage.ImageLocation = $database.online[$rowIndex].image
})

$serverList.Add_KeyDown({
    param($sender, $e)

    if ($e.KeyCode -eq 'Enter') {
        $global:rowIndex = $serverList.CurrentCell.RowIndex
        $global:clientselected = $false
        $clientServerList.ClearSelection()
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($database.online[$global:rowIndex].name)?", "Echo Relay Server Browser", "YesNo", "Question")
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
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($database.online[$global:rowIndex].name)?", "Echo Relay Server Browser", "YesNo", "Question")
    if ($choice -eq "Yes") {
        joinServer
    }
})

$otherServers.Controls.Add($serverList)

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
    $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($global:config.servers[$global:rowIndex].name)?", "Echo Relay Server Browser", "YesNo", "Question")
    if ($choice -eq "Yes") {
        clientJoinServer
    }
})

$clientServerList.Add_KeyDown({
    param($sender, $e)

    if ($e.KeyCode -eq 'Enter') {
        $global:rowIndex = $clientServerList.CurrentCell.RowIndex
        $global:clientselected = $true
        $serverList.ClearSelection()
        $choice = [System.Windows.Forms.MessageBox]::Show("Would you like to select $($global:config.servers[$global:rowIndex].name)?", "Echo Relay Server Browser", "YesNo", "Question")
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
$clientRightClick.Items.Add($clientPlayRightClick)

$clientSeparator1 = New-Object System.Windows.Forms.ToolStripSeparator
$clientRightClick.Items.Add($clientSeparator1)

$clientProperties = New-Object System.Windows.Forms.ToolStripMenuItem
$clientProperties.Text = "Server Properties"
$clientProperties.add_Click({
    $serverPropertiesWindow = New-Object System.Windows.Forms.Form
    $serverPropertiesWindow.Text = "Echo Relay Server Browser"
    $serverPropertiesWindow.Size = New-Object System.Drawing.Size(600, 290)
    $serverPropertiesWindow.StartPosition = "CenterScreen"
    $serverPropertiesWindow.FormBorderStyle = "FixedDialog"
    $serverPropertiesWindow.MaximizeBox = $false
    $serverPropertiesWindow.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")


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
    $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
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
    $addServerMenu.Text = "Echo Relay Server Browser"
    $addServerMenu.Size = New-Object System.Drawing.Size(330, 290)
    $addServerMenu.StartPosition = "CenterScreen"
    $addServerMenu.FormBorderStyle = "FixedDialog"
    $addServerMenu.MaximizeBox = $false
    $addServerMenu.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$($global:config.gamePath)\bin\win10\Echo Relay Server Browser.exe")


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
        $global:config | convertto-json | set-content "$env:appdata\Echo Relay Server Browser\config.json"
        [system.windows.forms.messagebox]::Show("Server added", "Echo Relay Server Browser", "OK", "Information")
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

$data = @{
    action = "cancelMatchmaking"
    userID = (get-itemproperty "HKCU:\SOFTWARE\Oculus VR, LLC\Oculus\Libraries" -Name DefaultLibrary).DefaultLibrary
    userName = $global:config.username
} | ConvertTo-Json
Invoke-RestMethod -Uri $database.api -Method Post -ContentType "application/json" -Body $data
$getMatchTimer.Stop()
$gameRunTimer.Stop()
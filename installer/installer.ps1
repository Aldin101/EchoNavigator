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
makeMovableObject -object $label

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
makeMovableObject -object $pcButton

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
makeMovableObject -object $questButton

$platformMenu.ShowDialog()

[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($global:database.Script)) | iex
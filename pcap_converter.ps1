[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$iconBase64 = "iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAB7UExURUdwTAAAAAAAAAAAAObo6gQFBgAAAAUGB3x8fAAAAAAAAAAAAAAAAOTn6Obp6wAAAFhvgQAAAAAAANbc4cDGywAAALW8wllvgVpvgeTm6eLl6AAAAFdtfszS2bG4vnmLmWh7i5ypstne4Yybp/L09bzEylVsfVRrfFBneb2JqG8AAAAadFJOUwD6746cLFINA2l/oNJA6ESodN+VHbrZjH/HDLfBMwAAA0dJREFUaN7tmW1zoyAQxwWLICa11qRz51OsJva+/yc8U00aySos+OJuxn8fp1P5ucAuy67nbdq0aRMkzoJQ+r1kGDC+/viChdF7PtF7FLJVCb4CuIP8lTg83OUL2oXqxAn0THJJc41oMhlVRAFyohIt4hsTigdGjoPEu9xQO/bDQEG4nyMkxY2BgbBdjtKOjwxziIgpjpETygaGOSQkOVrkmKMgSe6gwJVBCKWErAEJYW84yiEuij5SyiN1g8TAm5IoVqIFDyJiD2HP70h9KB6JmZhjAOFP/kF6hJhzWGIF8WdDhqnP6iGx+kikidzCR0OE8mIk1D4hjliI4iFkeOCwV3V4jO04iOAUYuxfM1Ufh1mG1hI5/fdhrsTvJ0ZWjRSAoYMohkTjy74CkIECMXSQ8OmEmIdcKSBDA5luLXI/UmFIT2EhJIbwEd/TQKqPg0WKNXEryrUQG4p4Bw0BIRdbCpusCF+ENJUlJZxuX7EE6THl5fqRImdrsh9jz1uG9JSrkBDvcUmo0EIGChLCHw05enrINyV1WHdpArlSkJBgLjTMQ3pK6rC5mBkka5AQCXvJMiR7sQ8q5L4bfvX6hFU6Qujtj29Fr64oxh/3z6vqVSEzqtearrUh4MIPkLr+/n77qu0h4BYeIOcsO9VN1hSnc1u056y0hoDO+DaM9uezKtuu6C5V2bVV15wsIQIMK6MlZXbKrpPU1E3dZk1jbQkYIEdIXXflZ1G35+bctheHNZmGev4Iab76IZusrNqv06WtHHaXFwGLAmzhrnOAiBDIHtf2EzCRWB0CpUSrQ6Dkjr31OsG6WFnCoDRVCK+E1VhZgki4bQ8t1NXBAWJ+CborRUOU69zt6pvOM173nqsp48XU26cvsFILxswVWwhNgSFx2WAmxYL+ICKThNOkDqVeM31d2UOqaS3W7Q0KOMfn5NmmFLVgDJcEStFXLKophXwcxbA8GKvlQekQXX7KvmOh0+MsTqBCp3Txlmkhm85XbFejLHYFkPHYpoyeYOMLuiGQ0wAfxdCtDaseGq5J49s2HhHtptihw2jYOEuEW5fRoAUo3Vu0PEE2M//Ztuxw/M41mIW3pnqQ0ipfd/wfEPjrpk2b/hv9BbzjVDoXOXmQAAAAAElFTkSuQmCC"
$iconBytes = [Convert]::FromBase64String($iconBase64)
$stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
$icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))
$Dark = "#212121"
$White = "White"
$copy = [char]0x00A9
function FBD_Function {
    param( $Label, $Folder, $Description )
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.SelectedPath = "C:\Users\$env:USERNAME\Desktop"
    $FolderBrowserDialog.ShowNewFolderButton = $false
    $FolderBrowserDialog.Description = "$Description"
    $response = $FolderBrowserDialog.ShowDialog( )
    if ( $response -eq 'OK' ) { 
        $Global:Path = $FolderBrowserDialog.SelectedPath
        $Label.text = $Global:Path 
        $Folder.Visible = $true
    }
}
function ConvertFunction {
    #Stolen from https://pastebin.com/crWJ5PF4 (FATMANN66)
    $here = Get-Location
    $pcapPath = $pcapPathLabel.text
    $HashcatPath = $HashcatPathLabel.text

    #Check if merged folder exists
    if (!(Test-Path "$pcapPath\merged")) { mkdir "$pcapPath\merged" }
    $pcapFolder = Get-ChildItem "$pcapPath\" -Filter *.pcap
    Set-Location $pcapPath
    $ProgressBar.Maximum = $pcapFolder.Count;
    #Loop to convert pcap to hccapx
    for ($i = 0; $i -lt $pcapFolder.Count; $i++) {
        $f = $pcapFolder[$i].FullName #Returns path with file name
        $o = $pcapFolder[$i].BaseName + '.hccapx' #Returns file name
        $ProgressBar.PerformStep()
        $pram = $f, $o
        $variable = & "$HashcatPath\cap2hccapx.exe" $pram #Convert .pcap files to .hccapx | & is the call operator which allows you to execute a command, a script, or a function.
        $CurrentFileLabel.Text = $variable | Select-String "Written"
        if ($variable -like '*Written 0 WPA*') { 
            Write-Output $o >> incomplete.txt
            Remove-Item $o
        }
    }
    cmd.exe /c copy /b *.hccapx merged\multi.2500 #Merge all created hccapx files
    Copy-Item $pcapPath\merged\multi.2500 $HashcatPath
    Set-Location $here
    $ProgressBar.Value = 0
    $hccapx = Get-ChildItem "$pcapPath\" -Filter *.hccapx
    $hccapxNumber = $hccapx.Count;
    $pcapNumber = $pcapFolder.Count;
    $percent = ($hccapxNumber / $pcapNumber).tostring("P")
    $CurrentFileLabel.Text = "Handshakes in $hccapxNumber of $pcapNumber ($percent)"
}
function EmptyFieldsFunction {
    if ($HashcatPathLabel.Text -and $pcapPathLabel.Text) { $ConvertButton.Enabled = $true }
    else { $ConvertButton.Enabled = $false } 
}
function AboutForm {
    Add-Type -assembly System.Windows.Forms
    $about_form = New-Object System.Windows.Forms.Form
    $about_form.Text = 'About PCAP Converter v.1.1.0 (x64)'
    $about_form.Icon = $icon
    $about_form.Width = 305
    $about_form.Height = 320
    $about_form.AutoSize = $true
    $about_form.FormBorderStyle = 'FixedSingle'
    $about_form.MaximizeBox = $false
    $about_form.MinimizeBox = $false
    $about_form.ForeColor = $White
    $about_form.BackColor = $Dark
    $about_form.StartPosition = 'CenterScreen'
    $about_form.Font = 'Arial, 8.25pt, style=Bold'
    $about_form.Topmost = $true

    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Size(10, 10)
    $pictureBox.Size = New-Object System.Drawing.Size(100, 100)
    $pictureBox.Image = $icon
    $about_form.controls.add($pictureBox)
    #App label
    $AppLabel = New-Object System.Windows.Forms.Label
    $AppLabel.Text = "PCAP Converter v.1.1.0 (x64)"
    $AppLabel.Location = New-Object System.Drawing.Point(10, 125)
    $AppLabel.AutoSize = $true
    $about_form.Controls.Add($AppLabel)
    #Date label
    $DateLabel = New-Object System.Windows.Forms.Label
    $DateLabel.Text = "2023.01.03"
    $DateLabel.Location = New-Object System.Drawing.Point(10, 145)
    $DateLabel.AutoSize = $true
    $about_form.Controls.Add($DateLabel)
    #GUI Version label
    $GUIVersionLabel = New-Object System.Windows.Forms.Label
    $GUIVersionLabel.Text = "GUI Version 1.1.0"
    $GUIVersionLabel.Location = New-Object System.Drawing.Point(10, 165)
    $GUIVersionLabel.AutoSize = $true
    $about_form.Controls.Add($GUIVersionLabel)
    #Copyright label
    $CopyrightLabel = New-Object System.Windows.Forms.Label
    $CopyrightLabel.Text = "Copyright $copy 2022-2023 Sebastian Henzmann"
    $CopyrightLabel.Location = New-Object System.Drawing.Point(10, 185)
    $CopyrightLabel.AutoSize = $true
    $about_form.Controls.Add($CopyrightLabel)

    $HashcatLinkLabel = New-Object System.Windows.Forms.LinkLabel
    $HashcatLinkLabel.Location = New-Object System.Drawing.Size(10, 215)
    $HashcatLinkLabel.Size = New-Object System.Drawing.Size(80, 20)
    $HashcatLinkLabel.LinkColor = $White
    $HashcatLinkLabel.ActiveLinkColor = "yellow"
    $HashcatLinkLabel.VisitedLinkColor = $White
    $HashcatLinkLabel.Text = "Hashcat.exe"
    $HashcatLinkLabel.add_Click({ [system.Diagnostics.Process]::start("https://github.com/hashcat/hashcat") })
    $about_form.Controls.Add($HashcatLinkLabel)

    $cap2hccapxLinkLabel = New-Object System.Windows.Forms.LinkLabel
    $cap2hccapxLinkLabel.Location = New-Object System.Drawing.Size(99, 215)
    $cap2hccapxLinkLabel.Size = New-Object System.Drawing.Size(95, 20)
    $cap2hccapxLinkLabel.LinkColor = $White
    $cap2hccapxLinkLabel.ActiveLinkColor = "yellow"
    $cap2hccapxLinkLabel.VisitedLinkColor = $White
    $cap2hccapxLinkLabel.Text = "Cap2hccapx.exe"
    $cap2hccapxLinkLabel.add_Click({ [system.Diagnostics.Process]::start("https://github.com/hashcat/hashcat-utils") })
    $about_form.Controls.Add($cap2hccapxLinkLabel)

    $RockyouLinkLabel = New-Object System.Windows.Forms.LinkLabel
    $RockyouLinkLabel.Location = New-Object System.Drawing.Size(210, 215)
    $RockyouLinkLabel.Size = New-Object System.Drawing.Size(80, 20)
    $RockyouLinkLabel.LinkColor = $White
    $RockyouLinkLabel.ActiveLinkColor = "yellow"
    $RockyouLinkLabel.VisitedLinkColor = $White
    $RockyouLinkLabel.Text = "Rockyou.txt"
    $RockyouLinkLabel.add_Click({ [system.Diagnostics.Process]::start("https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt") })
    $about_form.Controls.Add($RockyouLinkLabel)

    #Close Button
    $CloseButton = New-Object System.Windows.Forms.Button
    $CloseButton.Location = New-Object System.Drawing.Size(95, 240)
    $CloseButton.Size = New-Object System.Drawing.Size(100, 20)
    $CloseButton.Text = "&OK"
    $CloseButton.Add_Click({ $about_form.Close() })
    $about_form.Controls.Add($CloseButton)
    $about_form.ShowDialog()
}
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "PCAP Converter"
$main_form.Width = 400
$main_form.Height = 300
$main_form.Icon = $icon
$main_form.AutoSize = $false
$main_form.MaximizeBox = $false
$main_form.StartPosition = "CenterScreen"
$main_form.FormBorderStyle = "FixedSingle"
$main_form.BackColor = $Dark
$main_form.ForeColor = $White
$main_form.Font = "Arial Black, 8pt"

#Menubar
$menuMain = New-Object System.Windows.Forms.MenuStrip
$menuMain.BackColor = $Dark
$menuMain.ForeColor = $White
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
#Show Menu Bar
[void]$main_form.Controls.Add($menuMain)
#Menu: Help
$menuHelp.Text = "Help"
[void]$menuMain.Items.Add($menuHelp)
#Menu: Help -> About
$menuAbout.Text = "About"
$menuAbout.Add_Click({ AboutForm })
$menuAbout.BackColor = $Dark
$menuAbout.ForeColor = $white
[void]$menuHelp.DropDownItems.Add($menuAbout)

$HashcatLabel = New-Object System.Windows.Forms.Label
$HashcatLabel.Text = "Select folder containing Hashcat"
$HashcatLabel.Location = New-Object System.Drawing.Point(10, 33)
$HashcatLabel.AutoSize = $true
$main_form.Controls.Add($HashcatLabel)

$HashcatPathLabel = New-Object System.Windows.Forms.Label
$HashcatPathLabel.Location = New-Object System.Drawing.Point(10, 78)
$HashcatPathLabel.AutoSize = $true
$HashcatPathLabel.Add_TextChanged({ EmptyFieldsFunction })
$main_form.Controls.Add($HashcatPathLabel)

$pcapLabel = New-Object System.Windows.Forms.Label
$pcapLabel.Text = "Select folder containing PCAP-Files"
$pcapLabel.Location = New-Object System.Drawing.Point(10, 100)
$pcapLabel.AutoSize = $true
$main_form.Controls.Add($pcapLabel)

$pcapPathLabel = New-Object System.Windows.Forms.Label
$pcapPathLabel.Location = New-Object System.Drawing.Point(10, 145)
$pcapPathLabel.AutoSize = $true
$pcapPathLabel.Add_TextChanged({ EmptyFieldsFunction })
$main_form.Controls.Add($pcapPathLabel)

$CurrentFileLabel = New-Object System.Windows.Forms.Label
$CurrentFileLabel.Location = New-Object System.Drawing.Point(10, 230)
$CurrentFileLabel.Height = 45
$CurrentFileLabel.Width = 360
$CurrentFileLabel.AutoSize = $false
$main_form.Controls.Add($CurrentFileLabel)

$HashcatButton = New-Object System.Windows.Forms.Button
$HashcatButton.Location = New-Object System.Drawing.Size(20, 53)
$HashcatButton.Size = New-Object System.Drawing.Size(120, 20)
$HashcatButton.Text = "Hashcat"
$HashcatButton.Add_Click({ FBD_Function $HashcatPathLabel $HashcatResetButton "Select the folder containing Hashcat." })
$main_form.Controls.Add($HashcatButton)

$HashcatResetButton = New-Object System.Windows.Forms.Button
$HashcatResetButton.Location = New-Object System.Drawing.Size(145, 53)
$HashcatResetButton.Size = New-Object System.Drawing.Size(20, 20)
$HashcatResetButton.Text = "X"
$HashcatResetButton.Visible = $false
$HashcatResetButton.Add_Click({ 
    $HashcatPathLabel.Text = "" 
    $HashcatResetButton.Visible = $false })
$main_form.Controls.Add($HashcatResetButton)

$pcapButton = New-Object System.Windows.Forms.Button
$pcapButton.Location = New-Object System.Drawing.Size(20, 120)
$pcapButton.Size = New-Object System.Drawing.Size(120, 20)
$pcapButton.Text = "PCAP"
$pcapButton.Add_Click({ FBD_Function $pcapPathLabel $pcapResetButton "Select the folder containing PCAP files." })
$main_form.Controls.Add($pcapButton)

$pcapResetButton = New-Object System.Windows.Forms.Button
$pcapResetButton.Location = New-Object System.Drawing.Size(145, 120)
$pcapResetButton.Size = New-Object System.Drawing.Size(20, 20)
$pcapResetButton.Text = "X"
$pcapResetButton.Visible = $false
$pcapResetButton.Add_Click({ 
    $pcapPathLabel.Text = "" 
    $pcapResetButton.Visible = $false })
$main_form.Controls.Add($pcapResetButton)

$ConvertButton = New-Object System.Windows.Forms.Button
$ConvertButton.Location = New-Object System.Drawing.Size(130, 165)
$ConvertButton.Size = New-Object System.Drawing.Size(120, 30)
$ConvertButton.Text = "Convert!"
$ConvertButton.Enabled = $false
$ConvertButton.Add_Click({ ConvertFunction })
$main_form.Controls.Add($ConvertButton)

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location = New-Object System.Drawing.Point(10, 205)
$ProgressBar.Size = New-Object System.Drawing.Size(365, 20)
$ProgressBar.Step = 1
$ProgressBar.Value = 0
$main_form.Controls.Add($ProgressBar)

$main_form.ShowDialog()
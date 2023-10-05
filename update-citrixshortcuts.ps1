<#
.Synopsis
    Citrix Verknüpfungen, die durch die Workspace App im Startmenü erstellt werden und vom User per Verknüpfung auf Desktop oder Taskbar verbunden wurden
    werden durch dieses Script nachbearbeitet
.DESCRIPTION
   
.EXAMPLE
    Beispiel für die Verwendung dieses Cmdlets
.EXAMPLE
    Ein weiteres Beispiel für die Verwendung dieses Cmdlets
#>


function Pin-App {    param(
    [string]$appname,
    [switch]$unpin
)
try{
    if ($unpin.IsPresent){
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Taskbar" l sen|Unpin from Taskbar'} | %{$_.DoIt()}
        return "App '$appname' unpinned from Taskbar"
    }else{
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Taskbar" anheften|Pin to Taskbar'} | %{$_.DoIt()}
        return "App '$appname' pinned to Taskbar"
    }
}catch{
    Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
}
}

function Get-PinApp {    param(
    [string]$appname
    
)
try{
    if ($unpin.IsPresent){
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Taskbar" l sen|Unpin from Taskbar'} | %{$_.DoIt()}
        return "App '$appname' unpinned from Taskbar"
    }else{
        ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Taskbar" anheften|Pin to Taskbar'} | %{$_.DoIt()}
        return "App '$appname' pinned to Taskbar"
    }
}catch{
    Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
}
}



# Powershell snippet, verkn pfungen zu manipulieren
function Get-Shortcut {
param(
$path = $null
)

$obj = New-Object -ComObject WScript.Shell

if ($path -eq $null) {
$pathUser = [System.Environment]::GetFolderPath('StartMenu')
$pathCommon = $obj.SpecialFolders.Item('AllUsersStartMenu')
$path = dir $pathUser, $pathCommon -Filter *.lnk -Recurse 
}
if ($path -is [string]) {
$path = dir $path -Filter *.lnk
}
$path | ForEach-Object { 
if ($_ -is [string]) {
  $_ = dir $_ -Filter *.lnk
}
if ($_) {
  $link = $obj.CreateShortcut($_.FullName)

  $info = @{}
  $info.Hotkey = $link.Hotkey
  $info.TargetPath = $link.TargetPath
  $info.LinkPath = $link.FullName
  $info.Arguments = $link.Arguments
  $info.Target = try {Split-Path $info.TargetPath -Leaf } catch { 'n/a'}
  $info.Link = try { Split-Path $info.LinkPath -Leaf } catch { 'n/a'}
  $info.WindowStyle = $link.WindowStyle
  $info.IconLocation = $link.IconLocation

  New-Object PSObject -Property $info
}
}
}

function Set-Shortcut {
param(
[Parameter(ValueFromPipelineByPropertyName=$true)]
$LinkPath,
$Hotkey,
$IconLocation,
$Arguments,
$TargetPath
)
begin {
$shell = New-Object -ComObject WScript.Shell
}

process {
$link = $shell.CreateShortcut($LinkPath)

$PSCmdlet.MyInvocation.BoundParameters.GetEnumerator() |
  Where-Object { $_.key -ne 'LinkPath' } |
  ForEach-Object { $link.$($_.key) = $_.value }
$link.Save()
}
}

$myUserName = $env:username
$myUserProfile = $env:USERPROFILE

$myStartmenuPath = $myUserProfile + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" 
$myShortcuts = Get-ChildItem -Path $myStartmenuPath -filter *.lnk -Recurse

#$myShortcuts

$myShortcutsExport = @()
$myProgramLinks = @()

$ProgramLinks = Get-ChildItem -path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Include *.lnk -Recurse
foreach($programLink in $ProgramLinks) {
$myProgramLinks += $programLink -replace ".*\\", ""
}

#$ProgramLinks


write-host "::Startmenu::"
foreach($myShortCut in $myShortcuts) {
$myTarget = (Get-Shortcut -path $myShortcut)

If ($myTarget.Target -eq "SelfService.exe") {
    $myLinkPath = $myTarget.LinkPath -replace ".*\\", ""

    if ($myLinkPath -in $myProgramLinks) {
        $source = $myShortCut.FullName
        #$myShortcut.FullName
        #$myShortcut.DirectoryName
        $myShortCut.FullName
        ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myProgramShortcut = Get-Shortcut -path ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myTargetPath = $myProgramShortcut.TargetPath
        $myTargetArguments = $myProgramShortcut.Arguments

        Set-Shortcut -LinkPath $myShortCut.FullName -TargetPath $myTargetPath -Arguments $myTargetArguments
        
        #write-host $myTarget.LinkPath
        #write-host $myTarget.Target
        }
}

}


#Taskbar
$myTaskbarPath = $myUserProfile + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" 
$myShortcuts = Get-ChildItem -Path $myTaskbarPath -filter *.lnk -Recurse


write-host "::Taskbar::"
foreach($myShortCut in $myShortcuts) {
$myTarget = Get-Shortcut -path $myShortcut

If ($myTarget.Target -eq "SelfService.exe") {
    $myLinkPath = $myTarget.LinkPath -replace ".*\\", ""

    if ($myLinkPath -in $myProgramLinks) {
        $source = $myShortCut.FullName
        $myShortCut.FullName
        ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myProgramShortcut = Get-Shortcut -path ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myTargetPath = $myProgramShortcut.TargetPath
        $myTargetArguments = $myProgramShortcut.Arguments

        Set-Shortcut -LinkPath $myShortCut.FullName -TargetPath $myTargetPath -Arguments $myTargetArguments
        
        #write-host $myTarget.LinkPath
        #write-host $myTarget.Target
        }
    
}

}

#Desktop
$myDesktopPath = [Environment]::GetFolderPath("Desktop")
$myShortcuts = Get-ChildItem -Path $myDesktopPath -filter *.lnk -Recurse

write-host "::Desktop::"
foreach($myShortCut in $myShortcuts) {

$myTarget = Get-Shortcut -path $myShortcut


If ($myTarget.Target -eq "SelfService.exe") {
    $myLinkPath = $myTarget.LinkPath -replace ".*\\", ""

    if ($myLinkPath -in $myProgramLinks) {
        $source = $myShortCut.FullName
        $myShortCut.FullName
        ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myProgramShortcut = Get-Shortcut -path ($ProgramLinks | Where-Object Name -eq $myLinkPath).FullName
        $myTargetPath = $myProgramShortcut.TargetPath
        $myTargetArguments = $myProgramShortcut.Arguments

        Set-Shortcut -LinkPath $myShortCut.FullName -TargetPath $myTargetPath -Arguments $myTargetArguments
        
        #write-host $myTarget.LinkPath
        #write-host $myTarget.Target
        }

    
}

}





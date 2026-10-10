<#
.SYNOPSIS
    Bearbeitet Citrix-Verknüpfungen nach, die von der Workspace App erstellt wurden.
.DESCRIPTION
    Die Citrix Workspace App legt im Startmenü des Benutzers Verknüpfungen an, die auf SelfService.exe zeigen.
    Hat der Benutzer diese an Taskleiste oder Desktop angeheftet, zeigen auch dort die Verknüpfungen auf SelfService.exe.

    Das Script sucht im Startmenü, in der Taskleiste und auf dem Desktop des Benutzers nach solchen Verknüpfungen.
    Existiert im allgemeinen Startmenü (ProgramData) eine Verknüpfung mit gleichem Dateinamen, werden deren
    TargetPath und Arguments übernommen.
.EXAMPLE
    .\update-citrixshortcuts.ps1 -WhatIf
    Zeigt an, welche Verknüpfungen geändert würden, ohne etwas zu ändern.
.EXAMPLE
    .\update-citrixshortcuts.ps1
    Passt die Verknüpfungen an.
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$shell = New-Object -ComObject WScript.Shell

# Referenz-Verknüpfungen aus dem allgemeinen Startmenü, nach Dateiname
$commonLinks = @{}
Get-ChildItem -Path ([Environment]::GetFolderPath('CommonPrograms')) -Filter *.lnk -Recurse | ForEach-Object {
    if ($commonLinks.ContainsKey($_.Name)) {
        Write-Verbose "Verknüpfung '$($_.Name)' mehrfach im allgemeinen Startmenü vorhanden, verwende '$($commonLinks[$_.Name])'"
    } else {
        $commonLinks[$_.Name] = $_.FullName
    }
}

function Update-CitrixShortcuts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Label,
        [string]$Path
    )

    Write-Host "::$Label::"
    if (-not (Test-Path $Path)) {
        Write-Verbose "Ordner '$Path' existiert nicht"
        return
    }

    Get-ChildItem -Path $Path -Filter *.lnk -Recurse | ForEach-Object {
        $link = $shell.CreateShortcut($_.FullName)
        if ([IO.Path]::GetFileName($link.TargetPath) -ne 'SelfService.exe') { return }
        if (-not $commonLinks.ContainsKey($_.Name)) { return }

        $source = $shell.CreateShortcut($commonLinks[$_.Name])
        if ($link.TargetPath -eq $source.TargetPath -and $link.Arguments -eq $source.Arguments) { return }

        Write-Host "$($_.FullName) <- $($source.FullName)"
        if ($PSCmdlet.ShouldProcess($_.FullName, "Ziel auf '$($source.TargetPath) $($source.Arguments)' setzen")) {
            $link.TargetPath = $source.TargetPath
            $link.Arguments = $source.Arguments
            $link.Save()
        }
    }
}

Update-CitrixShortcuts -Label 'Startmenu' -Path ([Environment]::GetFolderPath('Programs'))
Update-CitrixShortcuts -Label 'Taskbar' -Path (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar')
Update-CitrixShortcuts -Label 'Desktop' -Path ([Environment]::GetFolderPath('Desktop'))

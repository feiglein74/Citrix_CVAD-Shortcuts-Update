# Citrix_CVAD-Shortcuts-Update
Citrix Shortcuts erstellt durch WorkspaceApp nachträglich editieren

Verknüpfungen im Startmenü, in der Taskleiste und auf dem Desktop des Benutzers, die auf `SelfService.exe` zeigen,
bekommen `TargetPath` und `Arguments` der gleichnamigen Verknüpfung aus dem allgemeinen Startmenü (`C:\ProgramData\...\Start Menu\Programs`).

```powershell
.\update-citrixshortcuts.ps1 -WhatIf    # nur anzeigen, was geändert würde
.\update-citrixshortcuts.ps1            # Verknüpfungen anpassen
.\update-citrixshortcuts.ps1 -Verbose   # mit Details (z. B. doppelte Namen im allgemeinen Startmenü)
```

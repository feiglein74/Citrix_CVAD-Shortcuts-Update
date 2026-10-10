# Citrix_CVAD-Shortcuts-Update

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)
![Citrix](https://img.shields.io/badge/Citrix-Workspace%20App-452170)

Fixes Citrix Workspace App (CVAD) shortcuts pointing to `SelfService.exe` in the user's Start Menu, Taskbar and Desktop
by copying target and arguments from the matching shortcut in the All Users Start Menu.

## Quickstart

```powershell
.\update-citrixshortcuts.ps1 -WhatIf   # preview changes
.\update-citrixshortcuts.ps1           # apply
```

Runs as the logged-on user, no admin rights required.

> Detailed documentation is in German.

---

PowerShell-Script, das Verknüpfungen der **Citrix Workspace App** nachträglich korrigiert – im Startmenü, in der Taskleiste und auf dem Desktop des Benutzers.

## Problem

Die Citrix Workspace App legt für veröffentlichte Anwendungen (CVAD) Verknüpfungen im Startmenü des Benutzers an, die auf `SelfService.exe` zeigen.
Heftet der Benutzer diese an die Taskleiste oder legt sie auf den Desktop, zeigen auch diese Kopien auf `SelfService.exe`.

Liegt im allgemeinen Startmenü (`C:\ProgramData\Microsoft\Windows\Start Menu\Programs`) bereits eine gleichnamige Verknüpfung mit dem gewünschten Ziel, sollen die Verknüpfungen des Benutzers dieses Ziel übernehmen.

## Funktionsweise

```
C:\ProgramData\...\Start Menu\Programs\App.lnk      ← Referenz (TargetPath + Arguments)
                       │
                       ▼
%APPDATA%\...\Start Menu\Programs\App.lnk           ┐
%APPDATA%\...\User Pinned\TaskBar\App.lnk           ├ zeigt auf SelfService.exe → wird angepasst
Desktop\App.lnk                                     ┘
```

| Ort         | Pfad                                                                   |
|-------------|------------------------------------------------------------------------|
| Startmenü   | `%APPDATA%\Microsoft\Windows\Start Menu\Programs`                      |
| Taskleiste  | `%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar` |
| Desktop     | `[Environment]::GetFolderPath('Desktop')`                              |

- Die Zuordnung erfolgt über den **Dateinamen** der Verknüpfung.
- Verknüpfungen, die schon das richtige Ziel haben, bleiben unverändert.
- Das allgemeine Startmenü wird nur gelesen. Es sind **keine Administratorrechte** nötig.

## Voraussetzungen

- Windows mit Windows PowerShell 5.1 oder PowerShell 7
- Citrix Workspace App
- Referenz-Verknüpfungen im allgemeinen Startmenü

## Verwendung

```powershell
# Nur anzeigen, was geändert würde
.\update-citrixshortcuts.ps1 -WhatIf

# Verknüpfungen anpassen
.\update-citrixshortcuts.ps1

# Mit Details, z. B. zu doppelten Namen im allgemeinen Startmenü
.\update-citrixshortcuts.ps1 -Verbose
```

Das Script läuft im Kontext des angemeldeten Benutzers, zum Beispiel als Anmeldescript oder als geplante Aufgabe bei der Anmeldung.

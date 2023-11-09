Start-Process -FilePath "${env:Windir}\System32\SFC.EXE" -ArgumentList '/scannow' -Wait -Verb RunAs
dism /online /cleanup-image /restorehealth
Start-Service -Name WinDefend -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue
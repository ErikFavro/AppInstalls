$ApplicationList =@("*Alertus*")
$Results = @()
$ClassesRegLocation = "HKLM:Software\Classes\Installer\Products"
$UninstRegLocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

$MSI = "alertus-desktopAlert-4.5_v5.4.48.0.msi"

$InstallPath = "`"" + $PSScriptRoot + "\$MSI" + "`""
$Logs = "`"C:\Windows\Temp\Alertus.log`""

$MSIArguments = @(
    '/i'
    $InstallPath
    '/qn'    
    '/L*v'
    $Logs
    'REBOOT=REALLYSUPPRESS'
    )

Try{
    $IssueReported = $null

    $Install = Start-Process "MsiExec.exe" -ArgumentList $MSIArguments -NoNewWindow -ErrorAction Stop -ErrorVariable $IssueReported -PassThru -Verbose
    $Install | Wait-Process -Timeout 120 -ErrorAction SilentlyContinue -ErrorVariable $IssueReported
    
    If ($IssueReported -or $Install.ExitCode){
        Stop-Process -Name "msi*" -Force -ErrorAction SilentlyContinue
        Exit Try
    }
    
    if (Test-Path  "$env:ProgramFiles\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe"){
        Start-Process "$env:ProgramFiles\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe" -ErrorAction SilentlyContinue
    }
    if (Test-Path "${env:ProgramFiles(x86)}\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe"){
        Start-Process "${env:ProgramFiles(x86)}\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe" -ErrorAction SilentlyContinue
    }
    Return $Install.ExitCode
}

Catch{


# Delete AlertusSecureDesktopLauncher
Get-ScheduledTask -TaskName "AlertusSecureDesktopLauncher" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# Stop Alertus Service
Stop-Service -Name "AlertusDesktopService" -Force -ErrorAction SilentlyContinue

# Stop All Alertus Applications that could be launched
Stop-Process -Name "AlertusDesktopSessionLocked" -Force -Confirm:$false -ErrorAction SilentlyContinue
Stop-Process -Name "AlertusDesktopSessionUnLocked" -Force -Confirm:$false -ErrorAction SilentlyContinue
Stop-Process -Name "Alertus.SecureDesktopLogonScreenLauncher" -Force -Confirm:$false -ErrorAction SilentlyContinue
Stop-Process -Name "AlertusDesktopAlert" -Force -Confirm:$false -ErrorAction SilentlyContinue

# Delete Alertus service
$AlertusDesktopService = Get-WmiObject -Class Win32_Service -Filter "Name='AlertusDesktopService'" -ErrorAction SilentlyContinue
if ($AlertusDesktopService -ne $null){
    $AlertusDesktopService.delete()
}

# Delete AlertusSessionLockedLauncherScheduledTask
Get-ScheduledTask -TaskName "AlertusSessionLockedLauncherScheduledTask" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# Delete AlertusSessionUnlockedLauncherScheduledTask 
Get-ScheduledTask -TaskName "AlertusSessionUnlockedLauncherScheduledTask" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

    #Clean up both HKLM are of the uninstall portion of the registry
    foreach($Location in $UninstRegLocations)
    {
        foreach($Application in $ApplicationList)
        {
            $Results += (Get-ChildItem -Path $Location | Get-ItemProperty | Where-Object {$_.DisplayName -like $Application} | Select-Object -Property DisplayName,PSChildName)
        }
    }
    
    foreach($UnInstRegRemoval in $Results)
        {
            $UninstCleanup = Join-path $UninstRegLocations $UnInstRegRemoval.PSChildName
            Remove-Item $UninstCleanup -Recurse -Force -ErrorAction SilentlyContinue
        }

    #Clean up HKCR area of the installs
    foreach($Location in $ClassesRegLocation)
        {
            foreach($Application in $ApplicationList)
            {
                $Results += (Get-ChildItem -Path $Location | Get-ItemProperty | Where-Object {$_.ProductName -like $Application} | Select-Object -Property ProductName,PSChildName)
            }
        }
    
    foreach($ClassesRegRemoval in $Results)
        {
            $ClassesCleanup = Join-path $ClassesRegLocation $ClassesRegRemoval.PSChildName 
            Remove-Item $ClassesCleanup -Recurse -Force -ErrorAction SilentlyContinue
                    
        }

        #Try the install again
        $Install = Start-Process "MsiExec.exe" -ArgumentList "$MSIArguments"  -Wait -NoNewWindow -ErrorAction Stop -PassThru
        
        
        if (Test-Path "${env:ProgramFiles(x86)}\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe"){
            Start-Process "${env:ProgramFiles(x86)}\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe" -ErrorAction SilentlyContinue
        }
        if (Test-Path  "$env:ProgramFiles\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe"){
            Start-Process "$env:ProgramFiles\Alertus Technologies\Alertus Desktop\AlertusDesktopAlert.exe" -ErrorAction SilentlyContinue
        }
        

        Return $Install.ExitCode
}

      
#Variables
$applicationlist =@("Python 3*")
$results = @()
$reglocations = @("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")


#Folder containing this script. VHD should reside in the root alongside the script.
if(!$PSScriptRoot){$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

#Get installer name
$OldPythonEXEs = (Get-ChildItem "$PSScriptRoot\OldInstallers\Python*")

#Uninstall old Python

foreach($CurrentPythonEXE in $OldPythonEXEs){
    Start-Process $CurrentPythonEXE -ArgumentList "/uninstall /silent" -Wait
    }

#Clear registry of any remaining components.  Usually leaves behind the launcher since it's installed as System
foreach($location in $reglocations)
    {
        foreach($application in $applicationlist)
        {
            $results += (Get-ChildItem -Path $location | Get-ItemProperty | Where-Object {$_.DisplayName -like $application} | Select-Object -Property DisplayName, PSChildName, Version)
        }
    }
    
foreach($UnInstall in $results)
    {
                
        $MSIArguments = @(
        '/x'
        $UnInstall.PSChildName
        '/qn'    
        #'/L*v "C:\Windows\Temp\' + $($UnInstall.DisplayName)+'.log"'
        'REBOOT=REALLYSUPPRESS'
        )
               
        $Uninstaller = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -ErrorAction Stop -PassThru
                    
    }
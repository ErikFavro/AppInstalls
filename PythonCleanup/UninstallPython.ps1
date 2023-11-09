#Get installer name
$OldPythonEXEs = (Get-ChildItem "$PSScriptRoot\OldInstallers\Python*")

#Uninstall old Python
foreach($CurrentPythonEXE in $OldPythonEXEs){
    Start-Process $CurrentPythonEXE -ArgumentList "/uninstall /silent" -Wait
}

#Try to clean anything remaining
$applicationlist =@("Python 3.5.*","Python 3.6.*","Python 3.7.*","Python 3.8.*","Python 3.9.*","Python 3.10.*")
$results = @()
$reglocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

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
        '/L*v "C:\Windows\Temp\' + $($UnInstall.DisplayName)+'.log"'
        'REBOOT=REALLYSUPPRESS'
        )
               
        $Uninstaller = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -ErrorAction Stop -PassThru
                    
    }
#Variables
$applicationlist =@("IBM SPSS Statistics*")
$results = @()
$reglocations = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")

#Install Varialbles
$MSIName = '"IBM SPSS Statistics.msi"'
$FUllMSIInstaller = @(
    '/i'
    $MSIName
    'ALLUSERS=1'
    'LICENSE_TYPE=Network'
    'LSHOST=swlicense.wwu.edu'
    '/norestart'
    '/qn'
    )

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

Try{

    $Installer = Start-Process "msiexec.exe" -ArgumentList $FUllMSIInstaller -Wait -NoNewWindow -ErrorAction Stop -PassThru
    Remove-Item "$env:PUBLIC\Desktop\IBM SPSS Statistics.lnk" -Force -ErrorAction SilentlyContinue

}

Catch{
    return $LASTEXITCODE
}
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

if ($results.count -ne "0")
{
    Return $true
}
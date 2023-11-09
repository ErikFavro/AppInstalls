$ServiceName = "WinDefend"
$StatusRunning = "Running" 

$ServiceStatus = Get-Service -Name $ServiceName | Select Status

If ($ServiceStatus.Status -eq $StatusRunning) {
    Return $true
}

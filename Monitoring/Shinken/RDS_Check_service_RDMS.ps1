$StatutRDMS = (Get-Service "RDMS" | select-object status)


[int]$ExitCode = 0

#Check if service RDMS is running
if($StatutRDMS.status -like "Running") {
Write-Host "Le service RDMS est OK"
}
else {
Write-Host "CRITICAL: Le service RDMS est NOK"
$ExitCode = 2
}

exit $ExitCode
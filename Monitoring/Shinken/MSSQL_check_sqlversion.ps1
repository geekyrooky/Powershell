# Script Powershell pour intégration à NSCLIENT++
# Get SQL SERVER Version 

# VARIABLE

$computername=$env:computername
$instances=(Get-ItemProperty -Path "HKLM:\Software\Microsoft\Microsoft SQL Server" -name "InstalledInstances").InstalledInstances

if ($instances[0] -match "MSSQLSERVER") { # no instance name for default instance, just localhost
    $serverInstance="localhost"
} else {
    $serverInstance="$($computername)\$($instances[0])" # We only check first found Instance
    $portsql = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Microsoft SQL Server\$($instances[0])\MSSQLServer\SuperSocketNetLib\Tcp" -name "TcpPort").TcpPort
    $serverInstance = "$($serverInstance),$($portsql)"

}
# OverRide here to only check a specific instance
# $serverInstance="$($computername)\MY_NAMED_INSTANCE"

$version = $null

[int]$ExitCode = 0
$cmdName = 'Invoke-Sqlcmd'

# CODE

push-location

if (! (Get-Command $cmdName -errorAction SilentlyContinue)) {
     Add-PSSnapin SqlServerCmdletSnapin100
     Add-PSSnapin SqlServerProviderSnapin100
}

$version = Invoke-Sqlcmd -ServerInstance $serverInstance -Query "SELECT @@VERSION;" -QueryTimeout 3

if ($version -eq $null) {
     Write-Host "UNKNOWN: SQL Check Failed"
     $ExitCode = 3
} elseif ($version -ne $null) {
     Write-Host "OK: $($serverInstance) " $version[0].replace("`n`t"," ")
}

pop-location

exit $ExitCode

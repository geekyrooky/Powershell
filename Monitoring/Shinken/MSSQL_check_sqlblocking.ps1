
# Script Powershell pour intégration à NSCLIENT++
# Get request list blocked

# VARIABLES

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

# SQL Request
$mysqlrequest = "USE master
SELECT db.name DBName,
tl.request_session_id,
wt.blocking_session_id,
OBJECT_NAME(p.OBJECT_ID) BlockedObjectName,
tl.resource_type,
h1.TEXT AS RequestingText,
h2.TEXT AS BlockingTest,
tl.request_mode
FROM sys.dm_tran_locks AS tl
INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
INNER JOIN sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2
GO"

# CODE


if (! (Get-Command $cmdName -errorAction SilentlyContinue)) {

     Add-PSSnapin SqlServerCmdletSnapin100
     Add-PSSnapin SqlServerProviderSnapin100
}

push-location

try {
    $version = Invoke-Sqlcmd -serverinstance $serverInstance -Query $mysqlrequest -QueryTimeout 60 -ErrorAction Stop
   if ( $version -eq $null ) {
        $Message = "OK: $($serverInstance) No Blocking Requests"
   } else {
        $Message = "Error : $($version[0])"
        $ExitCode = 1
   }
} catch {
   $Message = "Error : $($Error[0])"
   $ExitCode = 1
}

pop-location

$Message = (($Message -replace "`t|`n|`r"," ") -replace "  "," ").trim()
write-host $Message

Exit $ExitCode

# Test IIS SSL Certificate Date
# 
# To execute from within NSClient++
#
#[NRPE Handlers]
#
# in NSCLIENT.INI
#
# $ARG1$ warning value for queue
# $ARG2$ critical value for queue
#
# check_iis_ssl=cmd /c echo Scripts\Certificat_check_ssl_expiration.ps1 $ARG1$ $ARG2$ | PowerShell.exe -Command -
#

$warn = $Args[0]
$crit = $Args[1]

if ($warn -eq $null) { $warn = 15 }
if ($crit -eq $null) { $crit = 5 }

$mysslscm = @()
$mysslscw = @()
$mysslscm += get-childitem cert:\localmachine\my  | where { ($_.notafter -le (get-date).AddDays($crit)) } | select subject, NotAfter
$mysslscw += get-childitem cert:\localmachine\webhosting  | where { ($_.notafter -le (get-date).AddDays($crit)) } | select subject, NotAfter

$mysslswm = @()
$mysslsww = @()
$mysslswm += get-childitem cert:\localmachine\my  | where { ($_.notafter -le (get-date).AddDays($warn)) } | select subject, NotAfter
$mysslswm += get-childitem cert:\localmachine\webhosting  | where { ($_.notafter -le (get-date).AddDays($warn)) } | select subject, NotAfter


if ( ($mysslscm.count -eq 0) -and ($mysslscw.count -eq 0) ) {
	$retVal = "0"
	$msg = "NO Certificate to Renew"
    if ( ($mysslswm.count -gt 0) -or ($mysslswm.count -gt 0) ) {
	    $retval = 1
	    $msg = "Certificate(s) to Renew Warning !!!"
    }
} else {
	$retval = 2
	$msg = "Certificate(s) to Renew Critical !!!"
}

Write-Host "IIS SSL Certificates (warn:$warn jours,crit:$crit jours) : " $msg

exit $retval

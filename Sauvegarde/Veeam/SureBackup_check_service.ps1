param(
[string] $vm_ip, 	#%vm_ip%
[string] $service ) #Service name

$user = "administrateur"
$password = Get-Content "D:\script\SureBackup\Encrypted.txt" | ConvertTo-SecureString -Key (1..16)
$credential = New-Object System.Management.Automation.PsCredential($user, $password)


$result = Invoke-Command -Computername $vm_ip -ScriptBlock {get-Service} -Credential $credential
$res = $result | ?{$_.name -eq $service}

if($res.status -eq "Running")
{
    exit
}
else
{
write-host ("Error 1, Service '" + $service + "' not running or not found.") #if service not found or not running, then echo
$host.SetShouldExit(1)
exit
}
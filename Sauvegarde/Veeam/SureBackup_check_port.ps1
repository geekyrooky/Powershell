
Param {

 [Parameter(Mandatory=$True)]
        [string]$vm_ip

}
$user = "administrateur"
$password = Get-Content "D:\script\SureBackup\Encrypted.txt" | ConvertTo-SecureString -Key (1..16)
$credential = New-Object System.Management.Automation.PsCredential($user, $password)


$result = Invoke-Command -Computername $vm_ip  -ScriptBlock {Test-NetConnection -ComputerName localhost -Port 9000} -Credential $credential

if($result.TcpTestSucceeded -eq "True")
{
exit 0
}
else
{
write-host ("Error 1, Port not open or not found.")
exit 
}
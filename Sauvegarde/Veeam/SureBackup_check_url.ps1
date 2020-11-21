Param {

 [Parameter(Mandatory=$True)]
        [string]$vm_ip

}

$uri ="http://localhost/"

#credential
$user = "administrateur"
$password = Get-Content "D:\script\SureBackup\Encrypted.txt" | ConvertTo-SecureString -Key (1..16)
$credential = New-Object System.Management.Automation.PsCredential($user, $password)

#Check une url en localhost
$result = Invoke-Command -Computername  $vm_ip -Credential $credential -ScriptBlock {Invoke-WebRequest -URI $uri -UseBasicParsing}

if($result.Statuscode -eq 200)
	{
	exit 0
	}
else
	{
	write-host ("Error $($result.statuscode), Page introuvable.") 
	exit 1
	}
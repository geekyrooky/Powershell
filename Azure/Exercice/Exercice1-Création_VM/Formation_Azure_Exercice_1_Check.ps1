#############################################
### By Benjamin LALANDE
### Date 19/11/2020
###
### Script de correction d'un exercice Azure
###
###
### Prequis : 
### - Module Az powershell
### - Droit d'acces au tenant Azure et a la subscription
###
### Execution : 
###  .\formation_azure_exercice_1_check.ps1 -tenantid XXX-XXX-XXX-XXX -subscriptionId XXX-XXX-XXX-XXX -trigramme XXX
### Exemple : 
### .\formation_azure_exercice_1_check.ps1 -tenantid "6c6e4a03-xxxx-xxxx-xxxx-xxxx" -subscriptionId "15489102-xxxx-xxxx-xxxx-xxxx" -trigramme "BLA"
############################################

Param(
 [parameter(Mandatory=$true)][String]$tenantId=$(throw "Merci de renseigner le tenantId"),
 [parameter(Mandatory=$true)][String]$subscriptionId=$(throw "Merci de renseigner la subscriptionId"),
 [parameter(Mandatory=$true)][String]$trigramme=$(throw "Merci de renseigner le trigramme")
)

##Variable

$ResourcegroupName = "$($trigramme)-INFRA-FR-RG"
$VnetName = "$($trigramme)-FR-VNET"
$VnetaddSpace = "10.23.0.0/16"
$SubnetName = "$($trigramme)-10.23.1.0_24-SBNT"
$SubnetNetwork= "10.23.1.0/24"
$VmName = "$($trigramme)-IIS-1"
$VmInstance = "Standard_B2s"
$VmPrivIp = "10.23.1.10"
$VmDnsName = "$($VmName).francecentral.cloudapp.azure.com"
$IpPublicName = "$($vmName)-PIP"
$VaultName = "$($trigramme)-backup"
$VaultPolicyName = "$($trigramme)-daily15j"
$VaultPolicyRentention = "15"
$NsgNameNic = "$($VmName)-NSG"
$NsgNameSubnet = "$($SubnetName)-NSG"
$IpAllowRdp = "80.74.64.33"
$IpAllowMonitoring = "80.74.64.60"
$MsgEnd = "Taper sur une touche pour fermer la fenetre"

##Connexion au tenant Azure + subscription
Write-Host "Connexion au tenant Azure ..." -ForegroundColor Yellow
Connect-AzAccount -TenantId $tenantId
Select-AzSubscription -Subscription $subscriptionId

## Check le groupe de ressource
Write-Host "Check du groupe de ressource ..." -ForegroundColor Yellow
$res = Get-AzResourceGroup -Name $ResourcegroupName
If ($res.ResourceGroupName -ne $ResourcegroupName){
    Write-Host "Le nom du groupe de ressources n'est pas $($ResourceGroupName)" 
    read-host $MsgEnd; exit
} else {
    Write-Host "==> Nom du groupe de ressource OK" -ForegroundColor Yellow
    Write-Host "Groupe de ressource OK" -ForegroundColor Yellow
}

## Check du reseau virtuel    
Write-Host "Check du reseau virtuel ..." -ForegroundColor Yellow

$res = get-AzVirtualNetwork -Name $VnetName
$ressbnt = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $res -Name $SubnetName  

if ($res.name -ne $VnetName) {
    Write-Host "==> Le nom du reseau virtuel n'est pas $($VnetName)" -ForegroundColor Red
    read-host $MsgEnd; read-host $MsgEnd; exit
}elseif ($res.AddressSpace.AddressPrefixes -ne $VnetaddSpace) {
        Write-Host "==> Nom du reseau virtuel est OK" -ForegroundColor Yellow
        Write-Host "==> La plage d'adresse n'est pas $($VnetaddSpace)" -ForegroundColor Red
        $PauseEnd 
        read-host $MsgEnd; exit    
}elseif ($ressbnt.name -ne $SubnetName) {
        Write-Host "==> Plage d'adresse du reseau virtuel OK" -ForegroundColor Yellow
        Write-Host "==> Le nom du sous-reseau n'est pas $($SubnetName)" -ForegroundColor Red
        read-host $MsgEnd; exit  
}elseif ($ressbnt.AddressPrefix -ne $SubnetNetwork) {
        Write-Host "==> Nom du sous-reseau OK" -ForegroundColor Yellow
        Write-Host "==> Le reseau du sous reseau n'est pas $($SubnetNetwork)" -ForegroundColor Red
        read-host $MsgEnd; exit  
}else{
    Write-Host "==> Le nom du reseau virtuel OK" -ForegroundColor Yellow
    Write-Host "==> Plage d'adresse du reseau virtuel OK" -ForegroundColor Yellow
    Write-Host "==> Nom du sous-reseau OK" -ForegroundColor Yellow
    Write-Host "==> Le reseau du sous-reseau OK" -ForegroundColor Yellow
    Write-Host "Check du reseau virtuel OK" -ForegroundColor Yellow
}

## Check de la machine virtuelle
Write-Host "Check de la machine virtuelle ..." -ForegroundColor Yellow
$res = Get-AzVM -Name $VmName
$resNic = Get-AzNetworkInterface | ? {$_.id -eq $res.NetworkProfile.NetworkInterfaces.id}
$resIpPriv= Get-AzNetworkInterfaceIpConfig -Name ipconfig1 -NetworkInterface $resNic
$resIpPub = Get-AzPublicIpAddress -name $IpPublicName

if ($res.Name -ne $vmName) {
    Write-Host "==> Le nom de la machine virtuelle n'est pas $($VmName)" -ForegroundColor Red
    read-host $MsgEnd; exit    
}elseif ($res.HardwareProfile.VmSize -ne $VmInstance) {
    Write-Host "==> Nom de la VM OK" -ForegroundColor Yellow
    Write-Host "==> L'instance n'est pas $($VmInstance)" -ForegroundColor Red
    read-host $MsgEnd; exit 
}elseif ($resIpPriv.PrivateIpAddress -ne $VmPrivIp) {
    Write-Host "==> Instance de la VM OK" -ForegroundColor Yellow
    Write-Host "==> L'ip statique n'est pas $($VmPrivIp)" -ForegroundColor Red
    read-host $MsgEnd; exit 
}elseif ($resIpPub.name -ne $IpPublicName) {
    Write-Host "==> Ip privee statique $($VmPrivIp) de la VM OK" -ForegroundColor Yellow
    Write-Host "==> Le nom de l'ip publique n'est pas $($IpPublicName)" -ForegroundColor Red
    read-host $MsgEnd; exit
} elseif ($resIpPub.PublicIpAllocationMethod -ne "Static") {
    Write-Host "==> Nom ip publique OK" -ForegroundColor Yellow
    Write-Host "==> L'ip publique n'est pas Static" -ForegroundColor Red
    read-host $MsgEnd; exit
}elseif ($resIpPub.DnsSettings.fqdn -ne $VmDnsName) {
    Write-Host "==> Ip publique static OK" -ForegroundColor Yellow
    Write-Host "==> Le Nom DNS n'est pas $($VmDnsName)" -ForegroundColor Red
    read-host $MsgEnd; exit
}else {
    Write-Host "==> Nom de la VM OK" -ForegroundColor Yellow
    Write-Host "==> Instance de la VM OK" -ForegroundColor Yellow
    Write-Host "==> Ip privee statique $($VmPrivIp) de la VM OK" -ForegroundColor Yellow
    Write-Host "==> Nom ip publique OK" -ForegroundColor Yellow
    Write-Host "==> Ip publique static OK" -ForegroundColor Yellow
    Write-Host "==> Nom DNS de la VM OK" -ForegroundColor Yellow
    Write-Host "Check de la machine virtuelle OK" -ForegroundColor Yellow
}

## Check de la sauvegarde
Write-Host "Check de la sauvegarde ..." -ForegroundColor Yellow
$res = Get-AzRecoveryServicesVault -Name $VaultName
$resPolicy= Get-AzRecoveryServicesBackupProtectionPolicy -name $VaultPolicyName -vaultId $res.id
$backupContainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVm" -Status Registered -FriendlyName $VmName -vaultId $res.id
$resItem = Get-AzRecoveryServicesBackupItem -container $backupContainer -workloadType "AzureVm" -vaultId $res.id

if ($res.name -ne $VaultName) {
    Write-Host "==> Le Nom du vault de sauvegarde n'est pas $($VaultName)" -ForegroundColor Red
    read-host $MsgEnd; exit
} elseif ($resPolicy.name -ne $VaultPolicyName) {
    Write-Host "==> Nom du vault de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> Le Nom de la policy n'est pas $($VaultPolicyName)" -ForegroundColor Red
    read-host $MsgEnd; exit
}elseif ($resPolicy.RetentionPolicy.DailySchedule.DurationCountInDays -ne $VaultPolicyRentention) {
    Write-Host "==> Nom de la regle de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> La retention n'est pas de $($VaultPolicyRentention) jours" -ForegroundColor Red
    read-host $MsgEnd; exit  
}elseif ($resItem.ProtectionPolicyName -ne $VaultPolicyName) {
    Write-Host "==> Retention de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> La vm $($VmName) n'est pas lie a la regle de sauvegarde $($VaultPolicyName)" -ForegroundColor Red
    read-host $MsgEnd; exit  
}else {
    Write-Host "==> Nom du vault de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> Nom de la regle de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> Retention de sauvegarde OK" -ForegroundColor Yellow
    Write-Host "==> Liaison de la VM a la regle de sauvegarde OK" -ForegroundColor Yellow
}
Write-Host "Check de la sauvegarde OK" -ForegroundColor Yellow

## Check des NSG
Write-Host "Check des NSG ..." -ForegroundColor Yellow
$resNsgNic = Get-AzNetworkSecurityGroup -Name $NsgNameNic
$RuleRdp = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $resNsgNic | ? {$_.DestinationPortRange -match "3389"}
$RuleWeb = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $resNsgNic | ? {$_.DestinationPortRange -match "443"}
$RuleMonitoring = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $resNsgNic | ? {$_.DestinationPortRange -match "5666"}

Write-Host "=> Check des NSG de la carte reseau ..." -ForegroundColor Yellow
if ($resNsgNic.name -ne $NsgNameNic) {
    Write-Host "==> Le Nom du NSG n'est pas $($NsgNameNic)" -ForegroundColor Red
    read-host $MsgEnd; exit
}elseif ($RuleRdp.SourceAddressPrefix -ne $IpAllowRdp) {
    Write-Host "==> Nom du NSG OK" -ForegroundColor Yellow
    Write-Host "==> La regle RDP n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit   
}elseif ($RuleMonitoring.SourceAddressPrefix -ne $IpAllowMonitoring) {
    Write-Host "==> Regle RDP du NSG OK" -ForegroundColor Yellow
    Write-Host "==> La regle Monitoring n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit 
}elseif ($RuleWeb.SourceAddressPrefix -ne "*") {
    Write-Host "==> Regle Monitroing du NSG OK" -ForegroundColor Yellow
    Write-Host "==> La regle Web n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit 
}else {
    Write-Host "==> Nom du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle RDP du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle Monitroing du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle Web du NSG OK" -ForegroundColor Yellow
}
Write-Host "=> Check des NSG de la carte reseau OK" -ForegroundColor Yellow

$ResNsgSbnt = Get-AzNetworkSecurityGroup -Name $NsgNameSubnet
$RuleRdp = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $ResNsgSbnt | ? {$_.DestinationPortRange -match "3389"}
$RuleWeb = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $ResNsgSbnt | ? {$_.DestinationPortRange -match "443"}
$RuleMonitoring = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $ResNsgSbnt | ? {$_.DestinationPortRange -match "5666"}

Write-Host "=> Check des NSG du subnet ..." -ForegroundColor Yellow
if ($ResNsgSbnt.name -ne $NsgNameSubnet) {
    Write-Host "==> Le Nom du NSG n'est pas $($NsgNameSubnet)" -ForegroundColor Red
    read-host $MsgEnd; exit
}elseif (($RuleRdp.SourceAddressPrefix -ne $IpAllowRdp ) -or ($RuleRdp.DestinationAddressPrefix -ne $SubnetNetwork)) {
    Write-Host "==> Nom du NSG est OK" -ForegroundColor Yellow
    Write-Host "==> La regle RDP n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit   
}elseif (($RuleMonitoring.SourceAddressPrefix -ne $IpAllowMonitoring) -or ($RuleMonitoring.DestinationAddressPrefix -ne $SubnetNetwork)) {
    Write-Host "==> Regle RDP du NSG OK" -ForegroundColor Yellow
    Write-Host "==> La regle Monitoring n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit 
}elseif (($RuleWeb.SourceAddressPrefix -ne "*") -or ($RuleWeb.DestinationAddressPrefix -ne $SubnetNetwork)) {
    Write-Host "==> Regle Monitroing du NSG OK" -ForegroundColor Yellow
    Write-Host "==> La regle Web n'est pas correcte" -ForegroundColor Red
    read-host $MsgEnd; exit 
}else {
    Write-Host "==> Nom du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle RDP du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle Monitroing du NSG OK" -ForegroundColor Yellow
    Write-Host "==> Regle Web du NSG OK" -ForegroundColor Yellow
}
Write-Host "=> Check des NSG du subnet OK" -ForegroundColor Yellow

Write-Host "Check des NSG OK" -ForegroundColor Yellow
Write-Host "###############################################" -ForegroundColor Yellow
Write-Host "Felicitation, vous avez reussi l'exercice 1 !!!" -ForegroundColor Yellow
Write-Host "###############################################" -ForegroundColor Yellow
read-host $MsgEnd
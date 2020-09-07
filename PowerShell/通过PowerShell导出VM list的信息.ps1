Connect-AzAccount -EnvironmentName AzureChinaCloud 

$sub = Get-AzSubscription 
Select-AzSubscription -Name $sub.Name -SubscriptionId $sub.Id -Force

#导出虚拟机信息
$report = @()
$vms = Get-AzVM -Status
$publicIps = Get-AzPublicIpAddress 
$nics = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    $info = "" | Select-Object  Region, ResourceGroupName, VmName, VMStatus, InstanceType, VirturalNetwork, Subnet, PrivateIpAddress, PublicIPAddress, NSG, LoadBalancers, OsType, OSDisk, Datadisk 
    $vm = $vms | Where-Object -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $info.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $info.OsType = $vm.StorageProfile.OsDisk.OsType 
        $info.VMName = $vm.Name 
        $info.VMStatus = $vm.PowerState
        $info.InstanceType = $vm.HardwareProfile.VmSize
        $info.ResourceGroupName = $vm.ResourceGroupName 
        $info.Region = $vm.Location 
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $info.NSG = $nic.NetworkSecurityGroup.Id.split("/")[-1]
        $info.LoadBalancers = $nic.IpConfigurations.LoadBalancerBackendAddressPools.Id.Split("/")[-1]
        $info.OSDisk = $vm.StorageProfile.OsDisk.DiskSizeGB
        $info.DataDisk = ($vm.StorageProfile.DataDisks.DiskSizeGB) -join '-'
        $report+=$info 
    } 
$report | Export-CSV ".\VM_list_CN.csv" -Encoding utf8
$report | Format-Table Region, ResourceGroupName, VmName, VMStatus, InstanceType, VirturalNetwork, Subnet, PrivateIpAddress, PublicIPAddress, NSG, LoadBalancers, OsType, OSDisk, DataDisk 



# 导出Public IP信息
Get-AzPublicIpAddress | Select-Object resourcegroupname,name,ipaddress,location,PublicIpAllocationMethod,@{Name="associate"; Expression={($_.IpConfiguration.id).Split("/")[-3]}} | Format-Table

# 导出 VNET 信息
$report2 = @()
$vnets = Get-AzVirtualNetwork

foreach ($vnet in $vnets) { 
    $info = "" | Select-Object  Region, ResourceGroupName, VnetName, AddressSpace, subnetname, subnetaddressspace
        $info.Region = $vnet.Location
        $info.ResourceGroupName = $vnet.ResourceGroupName 
        $info.VnetName = $vnet.Name
        $info.AddressSpace = $vnet.AddressSpace.AddressPrefixes
        $info.subnetname = $vnet.Subnets.Name
        $info.subnetaddressspace = $vnet.Subnets.AddressPrefix
        $report2+=$info 
    } 

$report2 | Format-Table Region, ResourceGroupName, VnetName, AddressSpace, subnetname, subnetaddressspace
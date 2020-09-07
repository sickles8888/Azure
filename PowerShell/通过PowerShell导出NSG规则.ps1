Import-Module Az
$AdminAccount = "admin@xxxx.partner.onmschina.cn"   # Azure管理员账户
$AdminPW = "xxxxxxxx" | ConvertTo-SecureString -AsPlainText -Force   # Azure管理员账户密码
$credential = New-Object System.Management.Automation.PSCredential($AdminAccount,$AdminPW)
Login-AzAccount -EnvironmentName azurechinacloud -Credential $credential


$nsgs = Get-AzNetworkSecurityGroup
$exportPath = 'd:\'      # 修改存放导出csv的名称

New-Item -ItemType file -Path "$exportPath\NSGRules.csv" -Force

Foreach ($nsg in $nsgs) {
    
    $nsg.SecurityRules | Select-Object @{Name=’NSGName’;Expression={[string]::join(",",($nsg.Name))}},Priority,@{Name=’RuleName’;Expression={[string]::join(“,”, ($_.name))}},Description,@{Name=’SourceAddressPrefix’;Expression={[string]::join(“,”, ($_.SourceAddressPrefix))}},@{Name=’SourcePortRange’;Expression={[string]::join(“,”, ($_.SourcePortRange))}},@{Name=’DestinationAddressPrefix’;Expression={[string]::join(“,”, ($_.DestinationAddressPrefix))}},@{Name=’DestinationPortRange’;Expression={[string]::join(“,”, ($_.DestinationPortRange))}},Protocol,Access,Direction `
    | Export-Csv "$exportPath\NSGRules.csv" -NoTypeInformation -Encoding ASCII -Append
}
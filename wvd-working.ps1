 #D:
 #CD D:\wvd\2ndPreview\RDPowershell
 #Import-module .\Microsoft.RDInfra.RDPowershell.dll -Verbose
 
Install-Module -Name Microsoft.RDInfra.RDPowerShell -verbose -force
Import-Module -Name Microsoft.RDInfra.RDPowerShell -verbose


Add-RdsAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com

Set-RdsContext –TenantGroupName "Microsoft Internal"
# Set-RdsContext –TenantGroupName "Default Tenant Group"

# New-RdsRoleAssignment -SignInName admin@wilsonjackhotmail.onmicrosoft.com -RoleDefinitionName "RDS Owner" -TenantName "johnwils"

# Connect-AzureRmAccount 
 
# Select-AzureRmSubscription -Subscription   22902682-4bf7-4083-963b-ca87ddecfd32

# Add-RdsAccount -DeploymentUrl https://rdbroker-3u3qbtdiyzjao.azurewebsites.net

 

 Get-RdsHostPool

 Get-RdsSessionHost
 
 Get-RdsHostPool -TenantName johnwils -Name w10-pool-04


Get-RdsTenant
Set-RdsTenant -Name johnwils -AadTenantId d5dda8a1-b633-4531-ba9a-892df9d8a5b9 

New-RdsRegistrationInfo -TenantName johnwils -HostPoolName w16-pool-01 -ExpirationHours 96 | Select-Object -ExpandProperty Token > .\token.reg.txt

Add-RdsAppGroupUser -TenantName johnwils -HostPoolName w10-pool-01 -AppGroupName “Desktop Application Group” -UserPrincipalName johnwils@jwwlabs.com
Add-RdsAppGroupUser -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName “Desktop Application Group” -UserPrincipalName user2@jwwlabs.com
Add-RdsAppGroupUser -TenantName johnwils -HostPoolName w10-pool-01 -AppGroupName “Desktop Application Group” -UserPrincipalName johnwils@microsoft.com
Add-RdsAppGroupUser -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName “Applications” -UserPrincipalName user3@jwwlabs.com
Add-RdsAppGroupUser -TenantName johnwils -HostPoolName csxpool01 -AppGroupName “Desktop Application Group” -UserPrincipalName user4@jwwlabs.com


New-RdsAppGroup johnwils w10-app-01  Finance -ResourceType “RemoteApp”
New-RdsRemoteApp johnwils w10-app-01 Finance "My Calculator 2" -Filepath "C:\Windows\system32\calc.exe"  -IconPath "C:\Windows\system32\calc.exe" -IconIndex 0
Add-RdsAppGroupUser -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName “Finance” -UserPrincipalName johnwils@jwwlabs.com

Remove-RdsRemoteApp -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName "Applications" -Name "Calculator"

New-RdsRemoteApp johnwils w10-app-01 Applications "Notepad" -Filepath "C:\Windows\system32\notepad.exe"  -IconPath "C:\Windows\system32\notepad.exe" -IconIndex 0

Remove-RdsRemoteApp -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName "Applications" -Name "Notepad"

Set-RdsRemoteDesktop -TenantName johnwils -HostPoolName w10-pool-04 -AppGroupName "Desktop Application Group" -FriendlyName "Win 10 Personal Desktop"

New-RdsRemoteApp johnwils w10-app-01 Applications "Remote Desktop Connection" -Filepath C:\Windows\system32\mstsc.exe  -IconPath C:\Winndows\system32\shell32.dll -IconIndex 26
Remove-RdsRemoteApp -TenantName johnwils -HostPoolName w10-app-01 -AppGroupName "Applications" -Name "Remote Desktop Connection"
 
 
Set-RdsRemoteDesktop -TenantName KEMET -HostPoolName KEMET_AZURE_VDI -AppGroupName "Desktop Application Group" -FriendlyName "KEMETW10"

Set-RdsRemoteDesktop -TenantName johnwils -HostPoolName W7-Pool-01 -AppGroupName "Desktop Application Group" -FriendlyName "W7-PERS-1"

Set-RdsRemoteDesktop -TenantName johnwils -HostPoolName W10-Pool-04 -AppGroupName "Desktop Application Group" -FriendlyName "W10-PERS-1"

 Remove-RdsAppGroup -TenantName johnwils -HostPoolName mohawk01 -Name "Desktop Application Group"

Remove-RdsHostPool -TenantName johnwils -Name mohawk01

$remoteapp4 = "Edge"

New-RdsRemoteApp johnwils w10-app-01 Applications -Name "Edge" -FriendlyName "Edge" -FilePath "C:\Windows\explorer.exe" -IconPath "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe" -IconIndex 0 -CommandLineSetting Require -RequiredCommandLine "microsoft-edge:"

Get-RdsSessionHost -TenantName johnwils -HostPoolName mohawk01

Remove-RdsSessionHost -TenantName johnwils -HostPoolName psp01 -Name psp01-0.jwwlabs.com -Force
Remove-RdsSessionHost -TenantName johnwils -HostPoolName mohawk01 -Name mohawk-1.jwwlabs.com -Force

New-RdsRemoteApp johnwils w10-app-01 Applications "Microsoft Edge" -Filepath C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe  -IconPath C:\Windows\system32\shell32.dll -IconIndex 27
# WINDOWS VIRTUAL DESKTOPS POWERSHELL BREAKDOWN
# JOHN WILSON JOHNWILS@MICROSOFT.COM 
# 
# URLS SUPPLIED BY PG FOR THIS SERVICE
# RDWEB FOR CONSENT # RDWeb              : https://rdweb-3u3qbtdiyzjao.azurewebsites.net# RDBroker           : https://rdbroker-3u3qbtdiyzjao.azurewebsites.net
# RDWebClient        : https://rdweb-3u3qbtdiyzjao.azurewebsites.net/webclient
#
# using the azure marketplace template (WINDOWS VIRTUAL DESKTOP), this is my win 2016rdsh vhd file
# https://win2016rdshrdmi.blob.core.windows.net/vhds/win2016rdsh-b120180905142612.vhd
# win 10 multi session image, must search in marketplace for windows virtual desktop - provision a host pool
# https://azurewvd1.blob.core.windows.net/wvd/10ERS_17743_optimized_office_fixed_type_of_hd_V2.vhd
# Windows Virtual Desktop - Provision a host pool (Staged)
"---------------------------------------------------------------------------------------------------------------------"

# STEP 1
Login-AzureRMAccount

# STEP 1A for Microsoft Azure Internal Consumption -johnwils
Select-AzureRmSubscription -Subscription 22902682-4bf7-4083-963b-ca87ddecfd32

# STEP 2 CHANGE PS DIRECTORY
cd "C:\RDPowershell"
Import-module .\Microsoft.RDInfra.RDPowershell.dll -Verbose

# STEP 3 LOGIN TO THE TENANT
# This has to be run everytime you login
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-RdsAccount -DeploymentUrl https://rdbroker-3u3qbtdiyzjao.azurewebsites.net

# STEP 4 - ASSIGN ROLES TO TENANT 
New-RdsRoleAssignment -SignInName admin@wilsonjackhotmail.onmicrosoft.com -RoleDefinitionName "RDS Owner" -TenantName "jwwtest"
Remove-RdsRoleAssignment -SignInName johnwils@microsoft.com -RoleDefinitionName "RDS Owner" -TenantName "jwwtest"
Get-RdsTenant -Name "jwwtest" -AadTenantId d5dda8a1-b633-4531-ba9a-892df9d8a5b9
Get-RdsRoleAssignment -SignInName admin@wilsonjackhotmail.onmicrosoft.com -RoleDefinitionName "RDS Owner" -TenantName "jwwtest"

$remoteapp4 = "Edge"

New-RdsRemoteApp $tenant1 $pool1 $appgroup1 -Name $$remoteapp3 -FriendlyName $remoteapp3 -FilePath "C:\Windows\explorer.exe" -IconPath "C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe" -IconIndex 0 -CommandLineSetting Require -RequiredCommandLine "microsoft-edge:"

# STEP 5 RUNNING LIST OF HOSTPOOL ASSIGNMENTS HOUSE CLEANING
$tenant = "jwwtest"
$Hostpool = "w16dsk"
$tenant1 = "jwwtest"
$Hostpool1 = "w16app"
$tenant = "jwwtest"
$Hostpool2 = "w16app2"
$Hostpool3 = "w16app3"
$Hostpool4 = "w16app4"
$Hostpool5 = "w10dsk"


# STEP 6 Create new host pools for desktop sharing and applications
# Get-RdsHostPool -TenantName $tenant -Name $Hostpool 
New-RdsHostPool -TenantName $tenant -Name $Hostpool 
New-RdsHostPool -TenantName $tenant1 -Name $Hostpool1
New-RdsHostPool -TenantName $tenant1 -Name $Hostpool2
 
# OPTIONAL STEP TO ENABLE OR DISABLE REVERSE CONNECT
# Use Reverse Connect is True by default, use "0" to turn it off when first starting out to get it working. Use "1" to turn it back on
Set-RdsHostPool $tenant $Hostpool -UseReverseConnect 0
Set-RdsHostPool $tenant1 $Hostpool1 -UseReverseConnect 0


# STEP 7 Create token key to be used on session hosts to register them to the pool
New-RdsRegistrationInfo -TenantName $tenant -HostPoolName $Hostpool -ExpirationHours 120 | Select-Object -ExpandProperty Token
Export-RdsRegistrationInfo -TenantName $tenant -HostPoolName $Hostpool | Select-Object -ExpandProperty Token

New-RdsRegistrationInfo -TenantName $tenant1 -HostPoolName $Hostpool1 -ExpirationHours 120 | Select-Object -ExpandProperty Token
Export-RdsRegistrationInfo -TenantName $tenant1 -HostPoolName $Hostpool1 | Select-Object -ExpandProperty Token

New-RdsRegistrationInfo -TenantName $tenant -HostPoolName $Hostpool2 -ExpirationHours 120 | Select-Object -ExpandProperty Token
Export-RdsRegistrationInfo -TenantName $tenant1 -HostPoolName $Hostpool1 | Select-Object -ExpandProperty Token

# OPTIONAL STEP TO QUERY HOSTS 
Get-RdsSessionHost $tenant $Hostpool  

# STEP 8 Add users to the desktop sharing group 
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool -AppGroupName “Desktop Application Group” -UserPrincipalName user1@jwwlabs.net

# Add users to hostpool3 session hosts with reverse connect 
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool3 -AppGroupName “Desktop Application Group” -UserPrincipalName user1@jwwlabs.net
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool4 -AppGroupName “Desktop Application Group” -UserPrincipalName user1@jwwlabs.net

# Add users to hostpool5 session hosts for win 10 desktops with reverse connect
Add-RdsAppGroupUser -TenantName $tenant1 -HostPoolName $Hostpool5 -AppGroupName “Desktop Application Group” -UserPrincipalName user1@jwwlabs.net

# STEP 9 Create new group for applications 
New-RdsAppGroup $tenant1 $Hostpool2 applications -ResourceType “RemoteApp”

# STEP 10 Add users to the application group -----NOTE these users can't belong to the same host pool if combining desktop sharing and application sharing groups, they can only beling to 1 group
Add-RdsAppGroupUser -TenantName $tenant1 -HostPoolName $Hostpool1 -AppGroupName “applications” -UserPrincipalName user2@jwwlabs.net
Add-RdsAppGroupUser -TenantName $tenant1 -HostPoolName $Hostpool1 -AppGroupName “applications” -UserPrincipalName user2@jwwlabs.net
Add-RdsAppGroupUser -TenantName $tenant1 -HostPoolName $Hostpool4 -AppGroupName “applications” -UserPrincipalName user2@jwwlabs.net
Add-RdsAppGroupUser -TenantName $tenant1 -HostPoolName $Hostpool2 -AppGroupName “applications” -UserPrincipalName user2@jwwlabs.net


# Set-RdsHostPoolAvailableApp $tenant1 $Hostpool1 > c:\listofapps.txt


# STEP 11 Create applications to be shared out of session hosts
# New-RdsRemoteApp $tenant1 $Hostpool1 applications <remoteappname> -Filepath <filepath>  -IconPath <iconpath> -IconIndex <iconindex>
New-RdsRemoteApp $tenant1 $Hostpool1 applications "Server Manager" -Filepath C:\Windows\system32\ServerManager.exe  -IconPath C:\Windows\system32\svrmgrnc.dll -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool1 applications "wordpad" -Filepath "C:\Program Files\Windows NT\Accessories\wordpad.exe"  -IconPath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool1 applications "Remote Desktop Connection" -Filepath C:\Windows\system32\mstsc.exe  -IconPath C:\Windows\system32\mstsc.exe -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool1 applications "System Information" -Filepath "C:\Windows\system32\msinfo32.exe"  -IconPath "C:\Windows\system32\msinfo32.exe" -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool1 applications "Calculator" -Filepath "C:\Windows\system32\win32calc.exe"  -IconPath "C:\Windows\system32\win32calc.exe" -IconIndex 0

New-RdsRemoteApp $tenant1 $Hostpool2 applications "Server Manager" -Filepath C:\Windows\system32\ServerManager.exe  -IconPath C:\Windows\system32\svrmgrnc.dll -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool2 applications "wordpad" -Filepath "C:\Program Files\Windows NT\Accessories\wordpad.exe"  -IconPath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool2 applications "Remote Desktop Connection" -Filepath C:\Windows\system32\mstsc.exe  -IconPath C:\Windows\system32\mstsc.exe -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool2 applications "System Information" -Filepath "C:\Windows\system32\msinfo32.exe"  -IconPath "C:\Windows\system32\msinfo32.exe" -IconIndex 0
New-RdsRemoteApp $tenant1 $Hostpool2 applications "Calculator" -Filepath "C:\Windows\system32\win32calc.exe"  -IconPath "C:\Windows\system32\win32calc.exe" -IconIndex 0


# OPTIONAL STEP RENAME SESSION HOST DESKTOP ICONS 
Set-RdsRemoteDesktop -TenantName $tenant1 -HostPoolName $Hostpool1 -AppGroupName "Desktop Application Group" -FriendlyName "w16app rdp"
Set-RdsRemoteDesktop -TenantName $tenant1 -HostPoolName $Hostpool3 -AppGroupName "Desktop Application Group" -FriendlyName "w16app3 rdp"
Set-RdsRemoteDesktop -TenantName $tenant1 -HostPoolName $Hostpool4 -AppGroupName "Desktop Application Group" -FriendlyName "w16app4 rdp"
Set-RdsRemoteDesktop -TenantName $tenant1 -HostPoolName $Hostpool5 -AppGroupName "Desktop Application Group" -FriendlyName "win10 desktop"

# Diagnostics
Get-RdsDiagnosticActivity
Get-RdsDiagnosticActivities
Add-RdsAccount -DeploymentUrl https://rdbroker-3u3qbtdiyzjao.azurewebsites.net
 
# 1 - Create local user and group

# 1.1.A - Get list of all local users
Get-LocalUser

# 1.1.B - List all the properties of Admin user
Get-LocalUser -Name Administrator | select-object *

# 1.1.C - Create a new user
#Prompt to enter new user name
$NewUser = Read-Host "New local admin username:"

#Set password for new user and convert it in secure string
$Password = Read-Host -AsSecureString "Create a password for $NewUser"

#Create New User
New-LocalUser "$NewUser" -Password $Password -FullName "$NewUser" -Description "Temporary local admin" -AccountExpires $((get-date).AddDays(90))

# 1.1.D - Set / Change properties of newly created user
Set-LocalUser -Name "$NewUser" -AccountNeverExpires -PasswordNeverExpires

# Verify changes
Get-LocalUser -Name "$NewUser" | select-object *




# 2 - Create local group

# 1.2.A Get list of all local groups
Get-LocalGroup

# 1.2.B Create a new local group
New-LocalGroup -Name "Group1" -Description "This is a test group"




# 3 - Add local user to local group

# 1.3.A - Get members of local admin group
Get-LocalGroupMember -Group Administrators

# 1.3.B - Add Admin1 user to local admin group
Add-LocalGroupMember -Member "$NewUser" -Group Administrators

# 1.3.C - Verify changes
Get-LocalGroupMember -Group Administrators



#########################################################################################################

# 2 - Install / Uninstall Windows Roles and Features


#########################################################################################################


# 3 - Install / Uninstall third-party apps

# 3.1.A - Install application from msi file 
#Install 7z
$Arguments = "/i C:\Users\Public\Desktop\7z2301-x64.msi /quiet /norestart /log C:\temp\7z_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose

#Install Node
$Arguments = "/i C:\Users\Public\Desktop\node-v18.17.1-x64.msi /quiet /norestart /log C:\temp\node_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose


# 2. Uninstall application using msiexec


$App = Get-WmiObject win32_product | Where-Object {$_.name -like "*7-z*"} | select-object *

$App

$Arguments = "/uninstall $($App.IdentifyingNumber) /quiet /norestart /log C:\temp\7z_uninstall.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait




# 3. Install exe
Invoke-WebRequest https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.6/npp.8.5.6.Installer.x64.exe -OutFile c:\temp\npp.8.5.6.Installer.x64.exe

Start-Process C:\Users\Public\Desktop\npp.8.5.6.Installer.x64.exe /S -NoNewWindow -Wait -PassThru



#Uninstall Application

$AllApps = Get-WmiObject win32_product
$Node = $AllApps | Where-Object {$_.name -like "*node*"}
$Node.Uninstall()

<#
Win32_Product will only return applications installed via Windows Installer.
There are many products used to assemble installers that don’t build Windows Installer packages.
Any applications that use these non-Windows Installer packages for deployment won’t be returned when Win32_Product is queried.

https://xkln.net/blog/please-stop-using-win32product-to-find-installed-software-alternatives-inside/#:~:text=Win32_Product%20will%20only%20return%20applications,returned%20when%20Win32_Product%20is%20queried.

https://learn.microsoft.com/en-us/answers/questions/685494/get-wmiobject-computername-computer-class-win32-pr
#>

$Apps32 = @()
$Apps = @()
$Apps32 += Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" # 32 Bit
$Apps += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"


$NPPlus = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"

$parts = $NPPlus.QuietUninstallString -split " "
$exe = $parts[0] + " " + $parts[1]
$Arguments = $parts[2]
Start-Process -FilePath $exe -ArgumentList $Arguments -Wait

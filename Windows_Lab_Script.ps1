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
New-LocalUser "$NewUser" -Password $Password -FullName "$NewUser" -Description "Additional local admin" -AccountExpires $((get-date).AddDays(90))

# Verify properties of new user
Get-LocalUser -Name "$NewUser" | select-object *

# 1.1.D - Set / Change properties of newly created user
Set-LocalUser -Name "$NewUser" -AccountNeverExpires -PasswordNeverExpires $true

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

# 1 - Retrieve Roles and Features
# 2.1.A - Retrieve Windows Roles and Features
Get-WindowsFeature | select Displayname, Name, Installstate

# 2.1.B - Retrieve only Windows Roles
Get-WindowsFeature | Where-Object{$_.featuretype -eq "Role"} | select Displayname, Installstate, featuretype

# 2.1.C - Retrieve only Windows Features
Get-WindowsFeature | Where-Object{$_.featuretype -eq "Feature"} | select Displayname, Installstate, featuretype





# 2 - Retrieve and install DNS role

# 2.2.A - Retrieve DNS Role
Get-WindowsFeature -Name DNS

# 2.2.B - Install DNS Role, its subfeatures and management tools
Install-WindowsFeature -Name DNS -IncludeAllSubFeature -IncludeManagementTools -Verbose

# 2.2.C - Verify DNS Role installation status
Get-WindowsFeature -Name DNS





# 3 - Retrieve sub-features of a Role

# 2.3.A - Retrieve list of sub features for a particular Windows Role
Get-WindowsFeature -name web-server | select -ExpandProperty SubFeatures





# 4 - Retrieve and install a Windows Feature

# 2.4.A - Retrieve Telnet-Client Feature
Get-WindowsFeature -Name Telnet-Client

# 2.4.B - Install Telnet-Client Feature
Install-WindowsFeature -Name Telnet-Client -IncludeAllSubFeature -IncludeManagementTools -Verbose

# 2.4.C - Verify Telnet-Client install status
Get-WindowsFeature -Name Telnet-Client





# 4 - Uninstall Windows Role and Feature

# 2.5.A - Uninstall Windows Role and Feature
"DNS", "Telnet-Client" | %{Uninstall-WindowsFeature -Name $_ -IncludeManagementTools -Verbose}


# 2.5.B - Verify Windows Role and Feature Installation Status
"DNS", "Telnet-Client" | %{Get-WindowsFeature -Name $_}

#########################################################################################################


# 3 - Install / Uninstall third-party apps

# 1 - Install application from msi file 

# 3.1.A Create Temp folder for log files
New-Item -ItemType Directory -Path C:\Temp

# 3.1.B Install 7z
$Arguments = "/i C:\Users\Public\Desktop\LAB_FILES\Apps\7z2301-x64.msi /quiet /norestart /log C:\temp\7z_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose

# 3.1.C Install NodeJS
$Arguments = "/i C:\Users\Public\Desktop\LAB_FILES\Apps\node-v18.17.1-x64.msi /quiet /norestart /log C:\temp\node_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose




# 2 - Install application using exe file

# 3.2.A Silently Install Notepad++ using exe file
Start-Process C:\Users\Public\Desktop\LAB_FILES\Apps\npp.8.5.6.Installer.x64.exe /S -NoNewWindow -Wait -PassThru




# 3 - Uninstall application using msiexec

# 3.3.A Retrieve 7z And store it in a variable
$App = Get-WmiObject win32_product | Where-Object {$_.name -like "*7-z*"} | select-object *
$App

# 3.3.B Uninstall 7z using msiexec
$Arguments = "/uninstall $($App.IdentifyingNumber) /quiet /norestart /log C:\temp\7z_uninstall.log"
Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait





# 4 - Uninstall Application using 

# 3.4.A Retrieve all apps under win_32 product class
$Apps32 = @()
$Apps = @()
$Apps32 += Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" # 32 Bit
$Apps += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"

# 3.4.B 
$NPPlus = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"

# 3.4.C 
$parts = $NPPlus.QuietUninstallString -split " "
$exe = $parts[0] + " " + $parts[1]
$Arguments = $parts[2]
Start-Process -FilePath $exe -ArgumentList $Arguments -Wait





# 5 - Uninstall Application using Uninstall() method

# 3.5.A Retrieve and uninstall NodeJS application
$AllApps = Get-WmiObject win32_product | Where-Object {$_.name -like "*node*"}
$Node.Uninstall()


#########################################################################################################

<#
PATH variable is a system environment variable that your operating system uses to locate executables from the command line interface. We usually use this 
when it comes to developing various programs with different types of programming languages. However, setting this up inside the PowerShell environment is quite different.
#>

# 4 - Managing Path variable

# 4.1.A - Retrieve environment variables
Get-ChildItem Env:\


# 4.2.A - Retrieve existing Path Settings
[Environment]::GetEnvironmentVariable("PATH", "Machine")

[Environment]::GetEnvironmentVariable("PATH", "User")


# 4.2.B - Display path variable's values in properly formatted way
[Environment]::GetEnvironmentVariable("PATH", "Machine") -split ";"



# 4.3.A - Set system and user environment variable
$NewPath = "C:\Temp"

$PathMac = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + $NewPath 

$PathUsr = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + $NewPath


[Environment]::SetEnvironmentVariable( "Path", $PathMac, "Machine")

[Environment]::SetEnvironmentVariable( "Path", $PathUsr, "User")


# 4.3.B - Verify newly added path
[Environment]::GetEnvironmentVariable("PATH", "Machine")

[Environment]::GetEnvironmentVariable("PATH", "User")
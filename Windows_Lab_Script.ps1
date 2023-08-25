# 1 Create local user and group.
#https://www.scriptinglibrary.com/languages/powershell/create-a-local-admin-account-with-powershell/



# Install



# 1. Install application using msi file

#Install 7z
$Arguments = "/i C:\Users\Public\Desktop\7z2301-x64.msi /quiet /norestart /log C:\temp\7z_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose

#Install Node
$Arguments = "/i C:\Users\Public\Desktop\node-v18.17.1-x64.msi /quiet /norestart /log C:\temp\node_install.log"
Start-process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -Verbose


# 2. Uninstall application using msiexec


$App = Get-WmiObject win32_product | Where-Object {$_.name -like "*7-z*"} | select *

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

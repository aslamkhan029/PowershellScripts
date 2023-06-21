##############################################################################
# This script resets the Windows update components
# Author: Aslam Khan
# Created: 05-Dec-2022
# Modified: 15-Jun-2023
# Version: 1.1.2
# Changelog: 
#	V1.1.2 => Added better error handling in the script.
# 	V1.1.1 => Updated the script to clear the staged Windows packages.
##############################################################################

# Setting error action preference
#$ErrorActionPreference = 'Stop'

# Function to start Windows Update related services.
$StartServices = {
    Write-Host "`nStarting the services again..."
    $Services = @("cryptsvc", "wuauserv", "msiserver", "dosvc", "appidsvc", "bits", "trustedinstaller")
    ForEach ($Svc in $Services) {
        If(Get-Service -Name $Svc -ErrorAction SilentlyContinue) {
            If ($Svc -eq "wuauserv" -or $Svc -eq "cryptsvc") {
                Set-Service $svc -StartupType Automatic -ErrorAction Ignore
                Start-Service $Svc -ErrorAction Ignore
            } Else {
                Set-Service $svc -StartupType Manual -ErrorAction Ignore
                Start-Service $Svc -ErrorAction Ignore
            }
        }
    }
    Write-Output "Windows Update related services started successfully."
}

# Function to stop Windows Update related services
$StopServices = {
    $Services = @("cryptsvc", "wuauserv", "msiserver", "dosvc", "appidsvc", "bits", "trustedinstaller")
    ForEach ($Service in $Services) {
        If(Get-Service -Name $Service -ErrorAction SilentlyContinue) {
            $Error.Clear()
            Write-Host "`nStopping service: $service"
            Stop-Service -Name $Service -Force -NoWait
            Start-Sleep -Seconds 2
            If ((Get-Service $Service).Status -ine "stopped") {
                Write-Host "Service could not be stopped normally. Trying to stop the service forcefully."
                $processID = (Get-WmiObject Win32_service | ? {$_.Name -eq $Service}).ProcessID
                If($processID) {taskkill /f /pid $processID}
                Start-Sleep -Seconds 1
            } 
            If ((Get-Service $Service).Status -ieq "stopped") {
                Write-Host "Service stopped successfully."
                If ($Service -ilike "wuauserv" -or $Service -ilike "cryptsvc") {
                    Set-Service $Service -StartupType Disabled
                }
            } 
            If ((Get-Service $Service).Status -ieq "*ing") {
                Write-Output "Unable to stop the services."
                &$StartServices
                Write-Host "`nPlease try to run the script again. Exiting..."
                Pause
                Exit
            }
        }
    }
}

# Try to stop Windows Update Services.
&$StopServices

Start-Sleep -Seconds 3

# Removing QMGR data files
Write-Host "`nRemoving QMGR Data file..."
Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue
Write-Host "Done."

# Clearing the Windows Update database folders
Write-Host "`nRemoving Windows Update Folders (SoftwareDistribution and catroot2)..."
$Folders = @("$env:WINDIR\SoftwareDistribution", "$env:WINDIR\System32\catroot2")

ForEach ($Folder in $Folders) {
    $Error.Clear()
    If(Test-Path "$Folder.old") {Remove-Item "$Folder.old" -Recurse -Force -ErrorAction SilentlyContinue}
    If(Test-Path $Folder) {
        Try {
            Rename-Item $Folder -NewName "$Folder.old"
        } Catch {
            Write-Host $Error[0].Exception.Message -ForegroundColor Yellow -BackgroundColor Red
            Write-Host "`nFailed to rename the folder: $Folder." -ForegroundColor Yellow -BackgroundColor Red
			Write-Host "`nStarting Windows Update Services...`nPlease try to run the script again." -ForegroundColor Yellow -BackgroundColor Red
            &$StartServices
            Exit
        }
    }
    If(Test-Path "$Folder.old") {
		Try {
			Remove-Item "$Folder.old" -Recurse -Force
			Write-Host "Successfully removed the folder: $Folder"
		} Catch {
			Write-Host $Error[0].Exception.Message -ForegroundColor Yellow -BackgroundColor Red
			Write-Host "`nFailed to rename the folder: $Folder." -ForegroundColor Yellow -BackgroundColor Black
			Write-Host "`nStarting Windows Update Services..." -ForegroundColor Yellow -BackgroundColor Black
            &$StartServices
			Write-Host "`nPlease try to run the script again." -ForegroundColor Yellow -BackgroundColor Black
            Exit
		}
	}
}

# Removing old Windows Update log
Write-Host "`nRemoving old Windows Update log file..."
Try {
	Remove-Item $env:SystemRoot\WindowsUpdate.log -ErrorAction SilentlyContinue
	Write-Host "Done."
} Catch {
	Write-Host $Error[0].Exception.Message -ForegroundColor Yellow -BackgroundColor Red
	Write-Host "`nFailed to remove Windows Update log file.`n`nMoving on..." -ForegroundColor Yellow -BackgroundColor Black
}

# Resetting Windows update services to default settings
Write-Host "`nResetting the Windows Update Services to defualt settings..."
Try {
	"sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
	"sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
	Write-Host "Done."
} Catch {
	Write-Host $Error[0].Exception.Message -ForegroundColor Yellow -BackgroundColor Red
	Write-Host "`nFailed to reset WU Service permissions.`n`nMoving on..." -ForegroundColor Yellow -BackgroundColor Black
}

# Registring Windows update DLLs again.
# Set-Location $env:systemroot\system32
Write-Host "`nRegistering Windows Update DLLs again..."
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll
Write-Host "Done."

# Deleting all BITS jobs.
Write-Host "`nDeleting all BITS jobs..."
Get-BitsTransfer | Remove-BitsTransfer -ErrorAction SilentlyContinue
Write-Host "Done."

# Removing Staged Windows Update packages causing Windows Update issue.
Write-Host "`nRemoving Staged packages..."
$StgPkg = $null
$StgPkg = Get-WindowsPackage -Online | where {$_.PackageState -eq 'Staged'}
If($StgPkg) {
	Write-Host "Number of staged packages: $($StgPkg.Count)"
	ForEach ($Pkg in $StgPkg) {
		Try {
			Write-Host "Trying to remove the package: $($Pkg.PackageName)"
			Remove-WindowsPackage -PackageName $Pkg.PackageName -Online –NoRestart
			Write-Host "Removed the package successfully."
		} 
		Catch {
			Write-Host $Error[0].Exception.Message.TrimEnd() -ForegroundColor Yellow -BackgroundColor Red
			Write-Host "Failed to remove the package.`n" -ForegroundColor Yellow -BackgroundColor Black
		}
	}
} Else {
	Write-Host "No Staged packages found.`n"
}
Write-Host "Moving on..."

# Starting Windows update services again.
&$StartServices
Write-Output "`nPlease restart the computer and check for Windows Updates again...`n"
#Pause
Exit
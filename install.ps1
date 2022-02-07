function Download-GitHubRepository { 
    param( 
       [Parameter()] [string] $Url,
       [Parameter()] [string] $Location
    ) 
     
    # Force to create a zip file 
    $ZipFile = "$location\temp.zip"
    New-Item $ZipFile -ItemType File -Force | Out-Null

    # download the zip 
    Write-Host 'Starting downloading the GitHub Repository'
    Invoke-RestMethod -Uri $Url -OutFile $ZipFile
    Write-Host 'Download finished'
 
    #Extract Zip File
    Write-Host 'Starting unzipping the GitHub Repository locally'
    Expand-Archive -Path $ZipFile -DestinationPath $Location -Force
    Get-ChildItem -Path $Location -Recurse | Unblock-File
    Write-Host 'Unzip finished'
     
    # remove the zip file
    Remove-Item -Path $ZipFile -Force
}

function Get-WingetStatus{
    $hasAppInstaller = Get-AppXPackage -name 'Microsoft.DesktopAppInstaller' 
    if (!($hasAppInstaller)){
        Write-Host -ForegroundColor Yellow "Installing WinGet..."
        $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $releases = Invoke-RestMethod -uri "$($releases_url)"
        $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith("msixbundle") } | Select-Object -First 1
        Add-AppxPackage -Path $latestRelease.browser_download_url
        Write-Host -ForegroundColor Green "WinGet successfully installed."
    }
else {
    Write-Host -ForegroundColor Green "WinGet is already installed."
    }
}

function Get-WingetCmd {
    #Get WinGet Location in User context
    $WingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($WingetCmd){
        $Script:winget = $WingetCmd.Source
    }
    #Get WinGet Location in System context (WinGet < 1.17)
    elseif (Test-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe"){
        $Script:winget = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe" | Select-Object -ExpandProperty Path
    }
    #Get WinGet Location in System context (WinGet > 1.17)
    elseif (Test-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"){
        $Script:winget = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path
    }
    else{
        break
    }
}

function Get-AppList{
    if (Test-Path "$PSScriptRoot\apps.txt"){
        return Get-Content -Path "$PSScriptRoot\apps.txt"
    }
}


<# MAIN #>

#Temp folder
$Location = "$env:ProgramData\Winget"

#Download Winget-AutoUpdate
Download-GitHubRepository "https://github.com/Romanitho/Winget-AutoUpdate/archive/refs/heads/main.zip" $Location

#Check Winget is installed, and install if not
Get-WingetStatus

#Install WAU
Write-Host 'Installing Winget-AutoUpdate...'
Start-Process "powershell.exe" -Argument "-windowstyle minimized -executionpolicy bypass -file `"$Location\Winget-AutoUpdate-main\winget-install-and-update.ps1`" -Silent -DoNotUpdate" -Wait

#Get App List
$AppToInstall = Get-AppList

#Run install or uninstall for all apps
Get-WingetCmd
foreach ($AppID in $AppToInstall){
    Write-Host "Installing $AppID..." -ForegroundColor Yellow
    & $winget install --id $AppID --silent --accept-package-agreements --accept-source-agreements
    Write-Host "$AppID OK!`n" -ForegroundColor Green
}

#Run WAU
Write-Host "Running Winget-AutoUpdate"
Get-ScheduledTask -TaskName "Winget Update" -ErrorAction SilentlyContinue | Start-ScheduledTask -ErrorAction SilentlyContinue

Remove-Item -Path $Location -Force -Recurse
Write-Host "End."
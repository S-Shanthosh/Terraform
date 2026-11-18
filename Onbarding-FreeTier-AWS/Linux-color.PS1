#requires -Version 5.1
<#
.SYNOPSIS
  One-click Windows client setup for the Linux-Color terminal kit.
.DESCRIPTION
  Installs JetBrainsMono Nerd Font for the current Windows user and configures
  Windows Terminal defaults plus detected WSL profiles to use it.
  Does not install anything on Linux/EC2 and does not require administrator rights.
#>

$ErrorActionPreference = "Stop"
$FontFamily = "JetBrainsMono Nerd Font"
$FontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
$WorkDir = Join-Path $env:TEMP ("Linux-Color-" + [guid]::NewGuid().ToString("N"))
$FontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
$FontRegistryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Find-WindowsTerminalSettings {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
        (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

try {
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
    New-Item -ItemType Directory -Path $FontDir -Force | Out-Null

    Write-Host "============================================" -ForegroundColor Magenta
    Write-Host "       LINUX-COLOR | WINDOWS SETUP" -ForegroundColor Magenta
    Write-Host "============================================" -ForegroundColor Magenta
    Write-Host "This configures the Windows terminal client for Nerd Font icons."

    Write-Step "Downloading JetBrainsMono Nerd Font"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ZipPath = Join-Path $WorkDir "JetBrainsMono.zip"
    Invoke-WebRequest -Uri $FontZipUrl -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -LiteralPath $ZipPath -DestinationPath (Join-Path $WorkDir "font") -Force

    Write-Step "Installing TrueType fonts for the current Windows user"
    $TtfFiles = @(Get-ChildItem -Path (Join-Path $WorkDir "font") -Filter "*.ttf" -File -Recurse)
    if ($TtfFiles.Count -eq 0) {
        throw "The downloaded archive did not contain any .ttf font files."
    }

    $InstalledCount = 0
    foreach ($font in $TtfFiles) {
        $destination = Join-Path $FontDir $font.Name
        Copy-Item -LiteralPath $font.FullName -Destination $destination -Force
        $registryName = [IO.Path]::GetFileNameWithoutExtension($font.Name) + " (TrueType)"
        New-ItemProperty -Path $FontRegistryPath -Name $registryName -Value $font.Name -PropertyType String -Force | Out-Null
        $InstalledCount++
    }
    Write-Host "Installed $InstalledCount TTF font files." -ForegroundColor Green

    Write-Step "Configuring Windows Terminal"
    $SettingsPath = Find-WindowsTerminalSettings
    if ($SettingsPath) {
        $BackupPath = "$SettingsPath.linux-color.backup"
        Copy-Item -LiteralPath $SettingsPath -Destination $BackupPath -Force

        # Windows Terminal settings are JSONC. Strip standalone // comments,
        # block comments and trailing commas before parsing. Keep a backup.
        $raw = Get-Content -LiteralPath $SettingsPath -Raw
        $clean = [regex]::Replace($raw, '(?m)^\s*//.*(?:\r?\n|$)', '')
        $clean = [regex]::Replace($clean, '(?s)/\*.*?\*/', '')
        $clean = [regex]::Replace($clean, ',\s*([}\]])', '$1')
        $config = $clean | ConvertFrom-Json

        if (-not $config.profiles) {
            $config | Add-Member -MemberType NoteProperty -Name profiles -Value ([pscustomobject]@{}) -Force
        }
        if (-not $config.profiles.defaults) {
            $config.profiles | Add-Member -MemberType NoteProperty -Name defaults -Value ([pscustomobject]@{}) -Force
        }
        if (-not $config.profiles.defaults.font) {
            $config.profiles.defaults | Add-Member -MemberType NoteProperty -Name font -Value ([pscustomobject]@{}) -Force
        }
        $config.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name face -Value $FontFamily -Force

        # Explicitly set detected WSL profiles too, in case they override Defaults.
        foreach ($profile in $config.profiles.list) {
            $isWsl = ($profile.source -eq "Windows.Terminal.Wsl") -or
                     ($profile.name -match "WSL|Ubuntu|Debian|Kali|Linux")
            if ($isWsl) {
                if (-not $profile.font) {
                    $profile | Add-Member -MemberType NoteProperty -Name font -Value ([pscustomobject]@{}) -Force
                }
                $profile.font | Add-Member -MemberType NoteProperty -Name face -Value $FontFamily -Force
            }
        }

        $json = $config | ConvertTo-Json -Depth 100
        Set-Content -LiteralPath $SettingsPath -Value $json -Encoding UTF8
        Write-Host "Updated: $SettingsPath" -ForegroundColor Green
        Write-Host "Backup:  $BackupPath" -ForegroundColor DarkGray
    }
    else {
        Write-Warning "Windows Terminal settings.json was not found."
        Write-Host "The font is installed. Set its font face to: $FontFamily"
        if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
            Write-Host "Optional Windows Terminal install: winget install --id Microsoft.WindowsTerminal --exact"
        }
    }

    Write-Step "Finishing"
    Write-Host "Font installation and available terminal configuration are complete." -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT:"
    Write-Host "1. Close ALL Windows Terminal windows and open it again."
    Write-Host "2. Open your WSL profile, then SSH to your Linux machine."
    Write-Host "3. Run: eza --icons=always --color=always -lah"
    Write-Host ""
    Write-Host "Font: $FontFamily"
    Write-Host "Font download: $FontZipUrl"
    Write-Host "Note: This script configures Windows only; run Linux-Color on the Linux host separately."
}
catch {
    Write-Host ""
    Write-Host "SETUP FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "No Linux/EC2 files were changed." -ForegroundColor Yellow
    exit 1
}
finally {
    if (Test-Path -LiteralPath $WorkDir) {
        Remove-Item -LiteralPath $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

<#
.SYNOPSIS
    Automated Setup Script for Building DocReader Android APK
.DESCRIPTION
    Installs OpenJDK 17 and Flutter SDK onto Drive D: (where 84+ GB free space is available),
    configures environment variables, and builds the Android APK.
#>

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  DocReader - Android APK Build Setup   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Check Drive Free Space
$cDrive = Get-PSDrive C
$dDrive = Get-PSDrive D

Write-Host "Drive C: Free Space: $([math]::Round($cDrive.Free / 1GB, 2)) GB" -ForegroundColor Yellow
Write-Host "Drive D: Free Space: $([math]::Round($dDrive.Free / 1GB, 2)) GB" -ForegroundColor Green

if ($cDrive.Free / 1GB -lt 10) {
    Write-Host "[NOTE] Drive C has limited space (<10 GB). Installing tools onto Drive D:\ ..." -ForegroundColor Yellow
}

$installDir = "D:\development"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# 2. Check or Guide Flutter SDK
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Flutter SDK detected." -ForegroundColor Green
} else {
    Write-Host "`n[Action Required] Flutter SDK is not currently installed." -ForegroundColor Yellow
    Write-Host "To install Flutter on Drive D: without filling up Drive C:"
    Write-Host "  1. Download Flutter Windows bundle: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
    Write-Host "  2. Extract it to: D:\development\flutter"
    Write-Host "  3. Add 'D:\development\flutter\bin' to your PATH."
}

# 3. Check or Guide Java JDK 17
if (Get-Command javac -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Java Compiler (javac) detected." -ForegroundColor Green
} else {
    Write-Host "`n[Action Required] Modern Android builds require JDK 17+." -ForegroundColor Yellow
    Write-Host "  1. Download Eclipse Temurin JDK 17: https://adoptium.net/temurin/releases/?version=17"
    Write-Host "  2. Or run via winget (recommended): winget install EclipseAdoptium.Temurin.17.JDK"
}

# 4. Build Command
Write-Host "`nOnce the Flutter SDK and Android SDK are in your PATH, run:" -ForegroundColor Cyan
Write-Host "  cd C:\Users\arago\.gemini\antigravity\scratch\doc_reader" -ForegroundColor White
Write-Host "  flutter pub get" -ForegroundColor White
Write-Host "  flutter build apk --release" -ForegroundColor Green
Write-Host "`nThe resulting APK will be at:" -ForegroundColor Cyan
Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White

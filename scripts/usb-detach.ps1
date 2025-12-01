# =============================================================================
# USB Device Detach Script for ESP32 Development
# =============================================================================
# This script detaches a USB device from WSL2, making it available to Windows.
# The BUSID can be provided as a parameter or read from the .env file.
#
# Usage:
#   .\usb-detach.ps1              (uses BUSID from .env)
#   .\usb-detach.ps1 <BUSID>      (uses provided BUSID)
#
# Examples:
#   .\usb-detach.ps1              (detach device from .env)
#   .\usb-detach.ps1 1-2          (detach specific device)
#
# Note: This command requires Administrator privileges
# =============================================================================

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$BusId
)

# Check if usbipd is installed
try {
    $null = Get-Command usbipd -ErrorAction Stop
} catch {
    Write-Host "ERROR: usbipd is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install usbipd-win from:" -ForegroundColor Yellow
    Write-Host "https://github.com/dorssel/usbipd-win/releases" -ForegroundColor Cyan
    exit 1
}

$busIdSource = "parameter"

# If BUSID not provided as parameter, read from .env file
if ([string]::IsNullOrWhiteSpace($BusId)) {
    $envPath = Join-Path $PSScriptRoot "..\\.env"
    
    if (-not (Test-Path $envPath)) {
        Write-Host "ERROR: .env file not found and no BUSID provided" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please either:" -ForegroundColor Yellow
        Write-Host "1. Provide BUSID as parameter: .\usb-detach.ps1 <BUSID>" -ForegroundColor Cyan
        Write-Host "2. Or ensure BUSID is set in .env" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Run .\usb-list.ps1 to see available devices" -ForegroundColor Yellow
        exit 1
    }
    
    # Parse .env file to find USB_BUSID
    $envContent = Get-Content $envPath
    foreach ($line in $envContent) {
        if ($line -match '^USB_BUSID=(.+)$') {
            $BusId = $matches[1].Trim()
            break
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($BusId)) {
        Write-Host "ERROR: USB_BUSID not found in .env and no BUSID provided" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please either:" -ForegroundColor Yellow
        Write-Host "1. Provide BUSID as parameter: .\usb-detach.ps1 <BUSID>" -ForegroundColor Cyan
        Write-Host "2. Or ensure BUSID is set in .env" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Run .\usb-list.ps1 to see available devices" -ForegroundColor Yellow
        exit 1
    }
    
    $busIdSource = ".env"
}

# Validate BUSID format
if ($BusId -notmatch '^\d+-\d+$') {
    Write-Host "ERROR: Invalid BUSID format: $BusId" -ForegroundColor Red
    Write-Host "Expected format: X-Y (e.g., '1-2', '2-3')" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run .\usb-list.ps1 to see available devices and their BUSIDs" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Detaching USB Device from WSL2" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "BUSID: $BusId (from $busIdSource)" -ForegroundColor Yellow
Write-Host ""

# Run usbipd detach command
Write-Host "Running: usbipd detach --busid $BusId" -ForegroundColor Gray
try {
    $output = usbipd detach --busid $BusId 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to detach USB device" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- This command requires Administrator privileges" -ForegroundColor White
        Write-Host "- The device might not be attached" -ForegroundColor White
        Write-Host "- The BUSID might be incorrect (run .\usb-list.ps1 to verify)" -ForegroundColor White
        exit 1
    }
    Write-Host $output
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "USB device detached successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "The device is now available on Windows" -ForegroundColor Cyan
Write-Host ""

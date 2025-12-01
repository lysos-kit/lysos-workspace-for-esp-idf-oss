# =============================================================================
# USB Device Attach Script for ESP32 Development
# =============================================================================
# This script attaches a USB device to WSL2, making it available in Docker.
# The BUSID can be provided as a parameter or read from the .env file.
#
# Usage:
#   .\usb-attach.ps1              (uses BUSID from .env)
#   .\usb-attach.ps1 <BUSID>      (uses provided BUSID)
#
# Examples:
#   .\usb-attach.ps1              (attach device from .env)
#   .\usb-attach.ps1 1-2          (attach specific device)
#
# Note: Devices must be bound first (run usb-bind.ps1 or manually bind)
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
        Write-Host "1. Provide BUSID as parameter: .\usb-attach.ps1 <BUSID>" -ForegroundColor Cyan
        Write-Host "2. Or run .\usb-bind.ps1 <BUSID> to set it in .env" -ForegroundColor Cyan
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
        Write-Host "1. Provide BUSID as parameter: .\usb-attach.ps1 <BUSID>" -ForegroundColor Cyan
        Write-Host "2. Or run .\usb-bind.ps1 <BUSID> to set it in .env" -ForegroundColor Cyan
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
Write-Host " Attaching USB Device to WSL2" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "BUSID: $BusId (from $busIdSource)" -ForegroundColor Yellow
Write-Host ""

# Run usbipd attach command
Write-Host "Running: usbipd attach --wsl --busid $BusId" -ForegroundColor Gray
try {
    $output = usbipd attach --wsl --busid $BusId 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to attach USB device" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- This command requires Administrator privileges" -ForegroundColor White
        Write-Host "- The device must be bound first (run .\usb-bind.ps1)" -ForegroundColor White
        Write-Host "- WSL2 might not be running (run 'wsl --list --verbose')" -ForegroundColor White
        Write-Host "- The device might already be attached" -ForegroundColor White
        exit 1
    }
    Write-Host $output
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "USB device attached successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "The device is now available in WSL2/Docker as /dev/ttyUSB0" -ForegroundColor Cyan
Write-Host "(or /dev/ttyUSB1, /dev/ttyUSB2, etc. if multiple devices)" -ForegroundColor Gray
Write-Host ""

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " IMPORTANT: Restart Docker Container" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The Docker container must be restarted to detect the USB device:" -ForegroundColor White
Write-Host ""
Write-Host "  docker compose restart" -ForegroundColor Cyan
Write-Host ""
Write-Host "After restart, you can verify the device is available:" -ForegroundColor White
Write-Host "  docker compose exec esp-idf ls -la /dev/ttyUSB*" -ForegroundColor Cyan
Write-Host ""

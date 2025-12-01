# =============================================================================
# USB Device Bind Script for ESP32 Development
# =============================================================================
# This script binds a USB device to WSL2, making it shareable with Docker.
# The BUSID will be saved to .env for future use.
#
# Usage:
#   .\usb-bind.ps1 <BUSID>
#
# Example:
#   .\usb-bind.ps1 1-2
#
# Note: This command requires Administrator privileges
# =============================================================================

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$BusId
)

# Validate BUSID format (should be like "1-2", "2-3", etc.)
if ($BusId -notmatch '^\d+-\d+$') {
    Write-Host "ERROR: Invalid BUSID format" -ForegroundColor Red
    Write-Host "Expected format: X-Y (e.g., '1-2', '2-3')" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run .\usb-list.ps1 to see available devices and their BUSIDs" -ForegroundColor Cyan
    exit 1
}

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

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Binding USB Device to WSL2" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "BUSID: $BusId" -ForegroundColor Yellow
Write-Host ""

# Run usbipd bind command
Write-Host "Running: usbipd bind --busid $BusId" -ForegroundColor Gray
try {
    $output = usbipd bind --busid $BusId 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to bind USB device" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- This command requires Administrator privileges" -ForegroundColor White
        Write-Host "- The BUSID might be incorrect (run .\usb-list.ps1 to verify)" -ForegroundColor White
        Write-Host "- The device might already be in use" -ForegroundColor White
        exit 1
    }
    Write-Host $output
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "USB device bound successfully!" -ForegroundColor Green
Write-Host ""

# Save BUSID to .env file
$envPath = Join-Path $PSScriptRoot "..\\.env"
$envExamplePath = Join-Path $PSScriptRoot "..\\.env.example"

# Create .env from .env.example if it doesn't exist
if (-not (Test-Path $envPath)) {
    if (Test-Path $envExamplePath) {
        Write-Host "Creating .env file from .env.example..." -ForegroundColor Yellow
        Copy-Item $envExamplePath $envPath
    } else {
        Write-Host "Creating new .env file..." -ForegroundColor Yellow
        "" | Out-File -FilePath $envPath -Encoding UTF8
    }
}

# Read existing .env content
$envContent = Get-Content $envPath -ErrorAction SilentlyContinue
$usbBusIdExists = $false
$newContent = @()

# Check if USB_BUSID already exists and update it
foreach ($line in $envContent) {
    if ($line -match '^USB_BUSID=') {
        $newContent += "USB_BUSID=$BusId"
        $usbBusIdExists = $true
        Write-Host "Updated USB_BUSID in .env file" -ForegroundColor Yellow
    } else {
        $newContent += $line
    }
}

# If USB_BUSID doesn't exist, append it
if (-not $usbBusIdExists) {
    $newContent += ""
    $newContent += "# USB Device BUSID for ESP32 Programmer"
    $newContent += "USB_BUSID=$BusId"
    Write-Host "Added USB_BUSID to .env file" -ForegroundColor Yellow
}

# Write back to .env
$newContent | Out-File -FilePath $envPath -Encoding UTF8

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Next Steps:" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "1. Run: .\usb-attach.ps1" -ForegroundColor Yellow
Write-Host "   (This will attach the device to WSL2/Docker)" -ForegroundColor White
Write-Host ""
Write-Host "2. After attaching, restart Docker container:" -ForegroundColor Yellow
Write-Host "   docker compose restart" -ForegroundColor Cyan
Write-Host ""

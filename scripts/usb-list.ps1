# =============================================================================
# USB Device List Script for ESP32 Development
# =============================================================================
# This script lists all USB devices connected to your Windows machine.
# Use this to identify the BUSID of your ESP32 programmer.
#
# Usage:
#   .\usb-list.ps1
#
# Look for your ESP32 programmer in the output (e.g., "USB Serial Converter")
# Note the BUSID (format: X-Y, like "1-2" or "2-3")
# =============================================================================

# Check if usbipd is installed
try {
    $null = Get-Command usbipd -ErrorAction Stop
} catch {
    Write-Host "ERROR: usbipd is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install usbipd-win from:" -ForegroundColor Yellow
    Write-Host "https://github.com/dorssel/usbipd-win/releases" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install via winget:" -ForegroundColor Yellow
    Write-Host "  winget install --interactive --exact dorssel.usbipd-win" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " USB Devices Connected to Windows" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Looking for your ESP32 programmer..." -ForegroundColor Yellow
Write-Host "Common names: USB Serial Converter, FTDI, CP210x, CH340" -ForegroundColor Yellow
Write-Host ""

# Run usbipd list
usbipd list

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Next Steps:" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "1. Find your ESP32 programmer in the list above" -ForegroundColor White
Write-Host "2. Note the BUSID (format: X-Y, e.g., '1-2')" -ForegroundColor White
Write-Host "3. Run: .\usb-bind.ps1 <BUSID>" -ForegroundColor Yellow
Write-Host "   Example: .\usb-bind.ps1 1-2" -ForegroundColor Cyan
Write-Host ""

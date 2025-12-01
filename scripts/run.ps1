# =============================================================================
# Generic Command Runner for ESP-IDF Docker Container
# =============================================================================
# This script provides a convenient wrapper to run any ESP-IDF command inside
# the Docker container without having to type the full docker compose command.
#
# Usage:
#   .\run.ps1 <command> [arguments...]
#
# Common ESP-IDF Tools:
#   - idf.py         : Main build system
#   - esptool.py     : Flash and chip communication
#   - espcoredump.py : Core dump analysis
#   - espsecure.py   : Security features
#   - espefuse.py    : eFuse management
#   - parttool.py    : Partition table operations
#   - monitor.py     : Serial monitor
#
# Examples:
#   .\run.ps1 idf.py build
#   .\run.ps1 idf.py flash monitor
#   .\run.ps1 esptool.py --version
#   .\run.ps1 esptool.py chip_id
#   .\run.ps1 espcoredump.py info_corefile coredump.bin
#   .\run.ps1 espsecure.py --help
#   .\run.ps1 espefuse.py summary
#   .\run.ps1 python --version
#   .\run.ps1 ls -la
# =============================================================================

# Get all arguments passed to the script
$command = $args -join " "

# Check if any arguments were provided
if ([string]::IsNullOrWhiteSpace($command)) {
    Write-Host ""
    Write-Host "ERROR: No command provided" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage: .\run.ps1 <command> [arguments...]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common ESP-IDF Tools:" -ForegroundColor Cyan
    Write-Host "  idf.py         - Main build system" -ForegroundColor White
    Write-Host "  esptool.py     - Flash and chip communication" -ForegroundColor White
    Write-Host "  espcoredump.py - Core dump analysis" -ForegroundColor White
    Write-Host "  espsecure.py   - Security features" -ForegroundColor White
    Write-Host "  espefuse.py    - eFuse management" -ForegroundColor White
    Write-Host "  parttool.py    - Partition table operations" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 idf.py build" -ForegroundColor White
    Write-Host "  .\run.ps1 idf.py flash monitor" -ForegroundColor White
    Write-Host "  .\run.ps1 esptool.py --version" -ForegroundColor White
    Write-Host "  .\run.ps1 esptool.py chip_id" -ForegroundColor White
    Write-Host "  .\run.ps1 espcoredump.py info_corefile coredump.bin" -ForegroundColor White
    Write-Host "  .\run.ps1 espefuse.py summary" -ForegroundColor White
    Write-Host "  .\run.ps1 python --version" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Running: $command" -ForegroundColor Cyan
Write-Host ""

# Change to parent directory (where docker-compose.yml is located)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
Push-Location $projectDir

# Execute command inside the Docker container
# Using bash -i -c ensures the ESP-IDF environment is loaded
docker compose exec esp-idf bash -i -c "$command"

Pop-Location

$exitCode = $LASTEXITCODE

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "Command completed successfully" -ForegroundColor Green
} else {
    Write-Host "Command failed with exit code: $exitCode" -ForegroundColor Red
}
Write-Host ""

exit $exitCode

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build distribution package for ESP32 Starter OSS

.DESCRIPTION
    Creates a distributable ZIP archive containing essential project files
    for end users. CMakeLists.txt and main.c are packaged as .example files
    to avoid overwriting existing user code.

.PARAMETER Version
    Version string for the package (e.g., "1.0.0"). If not provided,
    attempts to detect from git tag or defaults to "dev".

.EXAMPLE
    .\build-dist.ps1 -Version "1.0.0"
    Creates esp32-starter-oss-v1.0.0.zip

.EXAMPLE
    .\build-dist.ps1
    Auto-detects version from git tag or uses "dev"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Version
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Determine version
if (-not $Version) {
    Write-Host "No version specified, attempting to detect from git tag..." -ForegroundColor Yellow
    
    try {
        # Try to get current git tag
        $gitTag = git describe --exact-match --tags HEAD 2>$null
        if ($gitTag) {
            # Remove 'v' prefix if present
            $Version = $gitTag -replace '^v', ''
            Write-Host "Detected version from git tag: $Version" -ForegroundColor Green
        }
    } catch {
        # Silently continue if git command fails
    }
    
    # Default to "dev" if still no version
    if (-not $Version) {
        $Version = "dev"
        Write-Host "Using default version: $Version" -ForegroundColor Yellow
    }
}

# Project root directory
$ProjectRoot = $PSScriptRoot
$PackageName = "esp32-starter-oss"
$DistDir = Join-Path $ProjectRoot "dist"
$TempDir = Join-Path $ProjectRoot "temp-dist-$([guid]::NewGuid().ToString().Substring(0,8))"
$StagingDir = Join-Path $TempDir "$PackageName-v$Version"
$ZipFileName = "$PackageName-v$Version.zip"
$ZipFilePath = Join-Path $DistDir $ZipFileName

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ESP32 Starter OSS - Build Distribution" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor White
Write-Host "Package: $ZipFileName" -ForegroundColor White
Write-Host ""

# Create directories
Write-Host "[1/6] Creating directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null
Write-Host "      Created: $StagingDir" -ForegroundColor Gray

# Copy essential files
Write-Host "[2/6] Copying project files..." -ForegroundColor Cyan

# Root files
$rootFiles = @(
    "docker-compose.yml",
    "Dockerfile",
    "LICENSE",
    "sdkconfig.defaults",
    ".env.example"
)

foreach ($file in $rootFiles) {
    $srcPath = Join-Path $ProjectRoot $file
    if (Test-Path $srcPath) {
        Copy-Item -Path $srcPath -Destination $StagingDir -Force
        Write-Host "      * $file" -ForegroundColor Gray
    } else {
        Write-Host "      x $file (not found, skipping)" -ForegroundColor Yellow
    }
}

# Copy CMakeLists.txt as .example
$cmakeRoot = Join-Path $ProjectRoot "CMakeLists.txt"
if (Test-Path $cmakeRoot) {
    Copy-Item -Path $cmakeRoot -Destination (Join-Path $StagingDir "CMakeLists.txt.example") -Force
    Write-Host "      * CMakeLists.txt -> CMakeLists.txt.example" -ForegroundColor Gray
}

# Copy README-DIST.md and rename to README.md
$readmeDist = Join-Path $ProjectRoot "README-DIST.md"
if (Test-Path $readmeDist) {
    Copy-Item -Path $readmeDist -Destination (Join-Path $StagingDir "README.md") -Force
    Write-Host "      * README-DIST.md -> README.md" -ForegroundColor Gray
} else {
    Write-Host "      x README-DIST.md (not found)" -ForegroundColor Red
    throw "README-DIST.md is required for distribution package"
}

# Copy scripts directory
Write-Host "[3/6] Copying scripts directory..." -ForegroundColor Cyan
$scriptsSource = Join-Path $ProjectRoot "scripts"
$scriptsDestination = Join-Path $StagingDir "scripts"
if (Test-Path $scriptsSource) {
    Copy-Item -Path $scriptsSource -Destination $scriptsDestination -Recurse -Force
    Write-Host "      * scripts/" -ForegroundColor Gray
} else {
    Write-Host "      x scripts/ (not found, skipping)" -ForegroundColor Yellow
}

# Copy main directory
Write-Host "[4/6] Copying main directory..." -ForegroundColor Cyan
$mainSource = Join-Path $ProjectRoot "main"
$mainDestination = Join-Path $StagingDir "main"
if (Test-Path $mainSource) {
    New-Item -ItemType Directory -Path $mainDestination -Force | Out-Null
    
    # Copy .gitkeep if exists
    $gitkeep = Join-Path $mainSource ".gitkeep"
    if (Test-Path $gitkeep) {
        Copy-Item -Path $gitkeep -Destination $mainDestination -Force
        Write-Host "      * main/.gitkeep" -ForegroundColor Gray
    }
    
    # Copy CMakeLists.txt as .example
    $mainCMake = Join-Path $mainSource "CMakeLists.txt"
    if (Test-Path $mainCMake) {
        Copy-Item -Path $mainCMake -Destination (Join-Path $mainDestination "CMakeLists.txt.example") -Force
        Write-Host "      * main/CMakeLists.txt -> main/CMakeLists.txt.example" -ForegroundColor Gray
    }
    
    # Copy main.c as .example
    $mainC = Join-Path $mainSource "main.c"
    if (Test-Path $mainC) {
        Copy-Item -Path $mainC -Destination (Join-Path $mainDestination "main.c.example") -Force
        Write-Host "      * main/main.c -> main/main.c.example" -ForegroundColor Gray
    }
} else {
    Write-Host "      x main/ (not found, creating empty directory)" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $mainDestination -Force | Out-Null
}

# Create ZIP archive
Write-Host "[5/6] Creating ZIP archive..." -ForegroundColor Cyan
if (Test-Path $ZipFilePath) {
    Remove-Item -Path $ZipFilePath -Force
    Write-Host "      Removed existing: $ZipFileName" -ForegroundColor Gray
}

Compress-Archive -Path (Join-Path $TempDir "*") -DestinationPath $ZipFilePath -CompressionLevel Optimal
Write-Host "      * Created: $ZipFileName" -ForegroundColor Gray

# Get file size
$fileSize = (Get-Item $ZipFilePath).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)

# Cleanup
Write-Host "[6/6] Cleaning up temporary files..." -ForegroundColor Cyan
Remove-Item -Path $TempDir -Recurse -Force
Write-Host "      * Removed: $TempDir" -ForegroundColor Gray

# Success message
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "* Distribution package created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Package: $ZipFileName" -ForegroundColor White
Write-Host "Size:    $fileSizeMB MB" -ForegroundColor White
Write-Host "Path:    $ZipFilePath" -ForegroundColor White
Write-Host ""

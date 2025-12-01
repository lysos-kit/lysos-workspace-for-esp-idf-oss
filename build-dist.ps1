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
$VersionedFolderName = "$PackageName-v$Version"
$StagingDir = Join-Path $TempDir $VersionedFolderName
$ProjectRootFolder = Join-Path $StagingDir "project-root-folder"
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
New-Item -ItemType Directory -Path $ProjectRootFolder -Force | Out-Null
Write-Host "      Created: $StagingDir" -ForegroundColor Gray
Write-Host "      Created: $ProjectRootFolder" -ForegroundColor Gray

# Copy essential files
Write-Host "[2/6] Copying project files..." -ForegroundColor Cyan

# Root files
$rootFiles = @(
    "docker-compose.yml",
    "Dockerfile",
    "LICENSE",
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

# Create a placeholder README in project-root-folder
Write-Host "[4/6] Creating project-root-folder..." -ForegroundColor Cyan
$projectReadmeContent = @"
# Your ESP-IDF Project Goes Here

Copy your entire ESP-IDF project folder into this directory (not just the contents, the whole folder).

## Quick Start

1. Copy your project folder here:
   ``````bash
   cp -r /path/to/my-esp32-project ./project-root-folder/
   ``````
   
   Result structure:
   ``````
   project-root-folder/
   └── my-esp32-project/  ← your project folder
       ├── main/
       ├── CMakeLists.txt
       └── ...
   ``````

2. Edit .env and set PROJECT_NAME to your folder name:
   ``````bash
   cd ..
   cp .env.example .env
   # Edit .env and set: PROJECT_NAME=my-esp32-project
   ``````

3. Start Docker:
   ``````bash
   docker compose up -d
   docker compose exec esp-idf bash
   ``````

4. Inside the container, build your project:
   ``````bash
   idf.py set-target esp32s3
   idf.py build
   idf.py flash monitor
   ``````

See the main README.md in the parent directory for complete documentation.
"@
$projectReadmePath = Join-Path $ProjectRootFolder "README.md"
Set-Content -Path $projectReadmePath -Value $projectReadmeContent -Force
Write-Host "      * project-root-folder/README.md (placeholder)" -ForegroundColor Gray

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

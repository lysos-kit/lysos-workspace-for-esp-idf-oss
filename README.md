[![Version](https://img.shields.io/badge/version-v1.0.0-green)](https://github.com/lysos-kit/lysos-workspace-for-esp-idf-oss/releases/latest)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](#quick-start)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](LICENSE)

# Lysos Workspace for ESP-IDF

A clean, isolated ESP-IDF environment built for professional firmware teams. It removes setup pain, dependency conflicts, and version issues. Drop in your project, choose the IDF version, and everything just works.

## Why Use This Workspace?

- **No Python Conflicts**: ESP-IDF runs in an isolated Docker container
- **Version Locked**: Pin specific ESP-IDF versions per project
- **Cross-Platform**: Works on Windows and Linux (macOS NOT tested yet)
- **USB Passthrough**: Full hardware debugging and flashing support
- **Production Ready**: Includes safe defaults and best practices

## Quick Start

### 1. Download The Release Package

Download the latest release package that contains only the required files.

### 2. Follow Our Quick Start Guide

See [README-DIST.md](README-DIST.md).

### 3. You Have A Complete ESP-IDF Environment Set Up

...and be able to run commands like this:


#### Linux

```bash
cd scripts

# Configure target (ESP32-S3 by default)
./run.sh idf.py set-target esp32s3

# Build the project
./run.sh idf.py build

# Flash to device (after USB setup - see below)
./run.sh idf.py flash

# Monitor serial output
./run.sh idf.py monitor
```

#### Windows

```bash
cd scripts

# Configure target (ESP32-S3 by default)
.\run.ps1 idf.py set-target esp32s3

# Build the project
.\run.ps1 idf.py build

# Flash to device (after USB setup - see below)
.\run.ps1 idf.py flash

# Monitor serial output
.\run.ps1 idf.py monitor
```

...and switch between ESP-IDF versions quickly just by changing the version number in the .env file...

Now download the release and then follow the guide above ^^^.


## License

AGPLv3 License (OSS edition).

Pro edition available under commercial license.

## Trademarks

ESP-IDF and ESP32 are trademarks of Espressif Systems. This project is not affiliated with or endorsed by Espressif.

[![Version](https://img.shields.io/badge/version-v1.0.0-green)](https://github.com/lysos-kit/lysos-workspace-for-esp-idf-oss/releases/latest)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](#quick-start)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](LICENSE)

# Lysos Workspace for ESP-IDF

A clean, isolated ESP-IDF environment built for professional firmware teams. It removes setup pain, dependency conflicts, and version issues. Drop in your project, choose the IDF version, and everything just works.

## Why Use This Workspace?

- **No Python Conflicts**: ESP-IDF runs in an isolated Docker container
- **Version Locked**: Pin specific ESP-IDF versions per project
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **USB Passthrough**: Full hardware debugging and flashing support
- **Production Ready**: Includes safe defaults and best practices

## Quick Start

### 1. Set Up

```bash
# Copy environment template
cp .env.example .env

# Copy your ESP-IDF project folder into project-root-folder
cp -r /path/to/your/my-esp32-project ./project-root-folder/

# Edit .env to set your project folder name
nano .env  # Set: PROJECT_NAME=my-esp32-project
```

### 2. Start Docker Environment

```bash
# Build and start the container
docker compose up -d

# Enter the container
docker compose exec esp-idf bash
```

### 3. Build and Flash

Inside the container:

```bash
# Configure target (e.g., ESP32-S3)
idf.py set-target esp32s3

# Build the project
idf.py build

# Flash to device (after USB setup - see full README-DIST.md)
idf.py flash

# Monitor serial output
idf.py monitor
```

Press `Ctrl+]` to exit the monitor.

## Project Structure

```
project-root-folder/
└── your-project-name/     # Your ESP-IDF project folder
    ├── main/
    ├── CMakeLists.txt
    └── ...
```

Copy your entire ESP-IDF project folder (not just files) into `project-root-folder/`, then set `PROJECT_NAME` in `.env` to match your folder name.

For complete documentation, see [README-DIST.md](README-DIST.md).

## License

AGPLv3 License (OSS edition).

Pro edition available under commercial license.

## Trademarks

ESP-IDF and ESP32 are trademarks of Espressif Systems. This project is not affiliated with or endorsed by Espressif.

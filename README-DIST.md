# ESP32 Starter Kit OSS

A production-ready, Dockerized ESP32 development environment powered by ESP-IDF. This starter kit eliminates the common pain points of ESP32 development by providing an isolated, versioned, and reproducible build environment.

## Why Use This Starter?

- **No Python Conflicts**: ESP-IDF runs in an isolated Docker container
- **Version Locked**: Pin specific ESP-IDF versions per project
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **USB Passthrough**: Full hardware debugging and flashing support
- **Production Ready**: Includes safe defaults and best practices

## Prerequisites

### Required Software

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **WSL2** (Windows only)
- **Git**

### Windows-Specific Requirements

- **usbipd-win**: For USB device passthrough to WSL2
  - Install via: `winget install --interactive --exact dorssel.usbipd-win`
  - Allows ESP32 programmer access from within Docker

### Hardware

- ESP32 development board (ESP32, ESP32-S2, ESP32-S3, ESP32-C3, etc.)
- USB programmer/debugger (often built into dev boards or ESPPROG)

## Quick Start

### 1. Clone and Configure

```bash
# Clone or extract this project
cd esp32-starter-oss

# Copy environment template
cp .env.example .env

# Edit .env if needed (optional - defaults work for most setups)
```

### 2. Start the Docker Environment

```bash
# Build and start the container
docker compose up -d

# Enter the container
docker compose exec esp-idf bash
```

### 3. Build Your Project

Inside the container:

```bash
# Configure target (ESP32-S3 by default)
idf.py set-target esp32s3

# Build the project
idf.py build

# Flash to device (after USB setup - see below)
idf.py flash

# Monitor serial output
idf.py monitor
```

Press `Ctrl+]` to exit the monitor.

## USB Device Setup

### Linux/macOS

USB devices should be automatically available inside the container at `/dev/ttyUSB0` (or similar).

### Windows (WSL2 Required)

Windows requires bridging USB devices from the host to WSL2, then to Docker:

#### Step 1: Find Your Device

```powershell
# List connected USB devices
usbipd list
```

Example output:

```
BUSID  VID:PID    DEVICE                              STATE
1-2    0403:6010  USB Serial Converter A              Not shared
```

Note the **BUSID** (e.g., `1-2`) of your ESP32 programmer.

#### Step 2: Share the Device (One-Time Setup)

```powershell
# Share device with WSL2
usbipd bind --busid 1-2
```

#### Step 3: Attach the Device

```powershell
# Attach to WSL2 (required each time you plug in the device)
usbipd attach --wsl --busid 1-2

# After attaching, restart the container to pick up the device
docker compose restart
```

**Helper Scripts Included:**

```powershell
# Windows PowerShell scripts in ./scripts/
.\scripts\usb-list.ps1      # List USB devices
.\scripts\usb-bind.ps1      # Bind device to WSL2
.\scripts\usb-attach.ps1    # Attach device to WSL2
.\scripts\usb-detach.ps1    # Detach device from WSL2
```

**Important Notes:**

- The USB device becomes **unavailable on Windows** when attached to WSL2 (exclusive access)
- You must **reattach after unplugging** and replugging the device
- You must **restart the Docker container** after attaching

## Project Structure

```
esp32-starter-oss/
├── main/                      # Your application code
│   ├── CMakeLists.txt.example # Build configuration example
│   └── main.c.example         # Main application example
├── CMakeLists.txt.example     # Project build configuration example
├── sdkconfig.defaults         # ESP-IDF default configuration
├── docker-compose.yml         # Docker orchestration
├── Dockerfile                 # ESP-IDF container definition
├── .env.example               # Environment variables template
└── scripts/                   # Helper scripts
    ├── usb-*.ps1             # Windows USB management
    ├── run.ps1               # Windows runner
    └── run.sh                # Linux/macOS runner
```

### Getting Started with Code

1. Copy example files to start your project:

   ```bash
   cp CMakeLists.txt.example CMakeLists.txt
   cp main/CMakeLists.txt.example main/CMakeLists.txt
   cp main/main.c.example main/main.c
   ```

2. Edit `main/main.c` to implement your application logic

3. Build and flash as shown in Quick Start

## Common Commands

### Container Management

```bash
# Start container
docker compose up -d

# Stop container
docker compose down

# Restart container (needed after USB attach)
docker compose restart

# Enter container
docker compose exec esp-idf bash

# View container logs
docker compose logs -f
```

### Inside the Container

```bash
# Set target chip
idf.py set-target esp32s3

# Configure project (menuconfig TUI)
idf.py menuconfig

# Build project
idf.py build

# Flash to device
idf.py flash

# Monitor serial output
idf.py monitor

# Flash and monitor in one command
idf.py flash monitor

# Clean build
idf.py fullclean

# Check ESP-IDF version
idf.py --version
```

### Run Commands from Outside Container

```bash
# One-off commands (non-interactive)
docker compose exec esp-idf bash -i -c "idf.py build"
docker compose exec esp-idf bash -i -c "idf.py --version"
```

## Configuration

### Environment Variables (.env)

The `.env` file controls build and runtime configuration:

```ini
# ESP-IDF version (matches Docker image tag)
ESPIDF_IMAGE_VERSION=v5.5.1

# Target chip
IDF_TARGET=esp32s3

# Serial port configuration
ESPPORT=/dev/ttyUSB0
ESPBAUD=115200
MONITORBAUD=115200

# Build optimization
IDF_CCACHE_ENABLE=1
CMAKE_BUILD_TYPE=Release
```

### Switching ESP-IDF Versions

Edit `.env` and change `ESPIDF_IMAGE_VERSION`:

```ini
ESPIDF_IMAGE_VERSION=v5.0.1  # or v5.1.2, v5.5.1, etc.
```

Then rebuild the container:

```bash
docker compose down
docker compose up -d --build
```

## Troubleshooting

### USB Device Not Found

**Windows:**

- Run `usbipd list` to verify device is attached
- Restart container: `docker compose restart`
- Check WSL2 has device: `wsl ls -l /dev/ttyUSB*`

**Linux/macOS:**

- Check permissions: `ls -l /dev/ttyUSB0`
- Add user to dialout group: `sudo usermod -a -G dialout $USER`

### Build Errors

```bash
# Clean and rebuild
docker compose exec esp-idf bash -i -c "idf.py fullclean && idf.py build"

# Check ESP-IDF version matches your target
docker compose exec esp-idf bash -i -c "idf.py --version"
```

### Port Access Denied

```bash
# Ensure no other program is using the port
# On Windows, detach and reattach USB device
.\scripts\usb-detach.ps1
.\scripts\usb-attach.ps1
```

### Container Won't Start

```bash
# Check Docker is running
docker ps

# View error logs
docker compose logs

# Rebuild container
docker compose down
docker compose up -d --build --force-recreate
```

## Advanced Usage

### Multiple Serial Ports

Edit `docker-compose.yml` to add more devices:

```yaml
devices:
  - /dev/ttyUSB0:/dev/ttyUSB0
  - /dev/ttyUSB1:/dev/ttyUSB1
  - /dev/ttyUSB2:/dev/ttyUSB2
```

### Custom Build Flags

Edit `sdkconfig.defaults` or use `idf.py menuconfig` for interactive configuration.

### Persistent Build Cache

Build cache is automatically stored in Docker volumes:

- `espidf-cargo-cache`: Rust/Cargo cache
- `espidf-ccache-cache`: Compiler cache

To clear cache:

```bash
docker volume rm esp32-starter-oss_espidf-cargo-cache
docker volume rm esp32-starter-oss_espidf-ccache-cache
```

## Support and Resources

- **ESP-IDF Documentation**: https://docs.espressif.com/projects/esp-idf/
- **ESP-IDF GitHub**: https://github.com/espressif/esp-idf
- **usbipd-win**: https://github.com/dorssel/usbipd-win

## License

MIT License - See LICENSE file for details.

# Lysos Workspace for ESP-IDF

A clean, isolated ESP-IDF environment built for professional firmware teams. It removes setup pain, dependency conflicts, and version issues. Drop in your project, choose the IDF version, and everything just works.

## Why Use This Workspace?

- **No Python Conflicts**: ESP-IDF runs in an isolated Docker container
- **Version Locked**: Pin specific ESP-IDF versions per project
- **Cross-Platform**: Works on Windows and Linux (macOS NOT tested yet)
- **USB Passthrough**: Full hardware debugging and flashing support
- **Production Ready**: Includes safe defaults and best practices

## Prerequisites

### Hardware

- ESP32 development board (ESP32, ESP32-S2, ESP32-S3, ESP32-C3, etc.)
- USB programmer/debugger (often built into dev boards or ESPPROG)

This whole system was tested with the original ESPProg programmer and ESP32-S3-WROOM-1 microcontroller.

It SHOULD easily support any other programming tool on USB that is supported by ESP-IDF framework.

### Required Software

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **WSL2** (Windows only)
- **USBIPD** (Windows only)
- **docker compose (v2)** (Linux)
- **Git**

#### Linux

On Linux, you need to install Docker and docker-compose (version 2!).

That docker-compose MUST be version 2, not the legacy version 1.

To test if you have installed the right docker compose version,
try running:

```bash
docker compose
```

(notice there's NO "-" dash between the words!)

"docker compose" = v2
"docker-compose" = v1

You need the command without the dash installed, that's the docker compose v2.

#### Windows

On Windows, you'll need a few more things...

Install Docker Desktop - this will also install the latest docker compose (v2).

IMPORTANT!

Windows ALSO requires bridging USB devices from the host (your machine) to Docker.

By default, when you start a Docker container on Windows,
the container does NOT see your USB devices connected to your host computer.

If you plug your ESPPROG to your PC, it won't suddenly appear INSIDE our Docker container
and it cannot be used just like that to communicate with your programmer.

To make it appear inside, so that idf.py and other tools can use your programmer, we must do
a few steps...

##### Install USBIPD Tool

To be able to connect your USB device from Windows to the Docker container,
we need a special tool for Windows - USBIPD.

Install the USBIPD via Windows' package manager:

```powershell
winget install --interactive --exact dorssel.usbipd-win
```

This MIGHT require admin privileges.

In case the setup hangs or fails, try to rebooting your computer and running again.

With this tool installed, you are ready to rock 'n roll on Windows!


## Quick Start

### 1. Extract and Set Up

```bash
# Extract the package
unzip lysos-workspace-v*.zip

# Navigate to the extracted directory
cd lysos-workspace-v*

# Copy environment template
cp .env.example .env

# IMPORTANT!
# Edit .env - some parameters inside MUST BE set before continuing!
```

#### Linux

On Linux, your USB programmer device will be immediately available as `/dev/ttyUSB0`, `/dev/ttyUSB1` or similar (2, 3, etc...)

You can see your USB devices available by going to /dev on your Linux host machine and
checking which ones are available like this:

```bash
cd /dev
ll
```

Open your .env file and set the ESPPROG variable to `/dev/ttyUSB0` or similar.

If you are setting USB port number HIGHER THAN 1 - like 2, 3, etc... see the "Multiple Serial Ports" section down below as well - MANDATORY!

Some programmers like ESPProg have TWO ports...

Pick USB1 for start and if it won't work, we switch to USB0...


#### Windows

On Windows, once you have the container running,
we must bridge the USB device to the Docker container.

We use that USBIPD tools we installed previously for that.

Go to "scripts" directory:

```bash
cd scripts
```

Now.

Each device (your USB programmer) in a SPECIFIC USB port must be BOUND to the Docker container only ONCE.

It's a one-time setup. After that, you don't need to bind anymore.

So you plug in your USB programmer to ANY usb port.

Then we list the USB devices available.

##### Step 1: Find Your Device

```powershell
# List connected USB devices
cd scripts
.\usb-list.ps1
```

Example output:

```
BUSID  VID:PID    DEVICE                              STATE
1-2    0403:6010  USB Serial Converter A              Not shared
```

"Not shared" means it has NOT been bound to the Docker yet.

Note the **BUSID** (e.g., `1-2`) of your ESP32 programmer.

##### Step 2: Share the Device (One-Time Setup)

```powershell
# Share device with Docker
.\usb-bind.ps1 --busid 1-2
```

This will configure the device so that it can be bridged into the Docker.

This is a one time setup step per device per USB port.

If you switch your programmer to ANOTHER USB port and run list again,
it will show as a DIFFERENT "device" with a DIFFERENT "BUSID".

You will have to bind that one as well.

If you're working on a laptop with say 2 USB ports,
I recommend plugging the device into one after another and
doing this bind FOR BOTH - so that you can use any port you want later.

After completing these "BIND" operations, YOU MUST restart your Docker
container to pick up the new USB ports.

If you DON'T, you won't see them inside Docker.

```powershell
cd ..
docker compose restart
```


##### Step 3: Attach the Device

This will make the USB device available inside Docker
AND - UNAVAILABLE in Windows!

The access is EXCLUSIVE, so it's either inside Windows, or inside Docker,
never in both.

This "ATTACH" command is required EVERY TIME you plug the device in.

If you unplug your programmer and the re-plug,
you MUST run it again, so that it once again becomes
available in Docker.

```powershell
# Attach to Docker (required each time you plug in the device)
.\usb-attach.ps1 --busid 1-2

# After attaching, restart the container to pick up the device
# (might work right away without restart - so just to be sure)
docker compose restart
```

NOW - and this is IMPORTANT!

You go back and open your .env file...

And set the USB_BUSID to your value like

USB_BUSID=1-2

or...

USB_BUSID=3-1

After this - we need to refresh the container again to pick up the
changes in .env.

```powershell
docker compose up -d
```

And... That's it!

These are the only rules...

Every time you plug-in - run ATTACH.

Running DETACH is optional - the device is detached when you remove it from
your USB port OR - if you need the device back in Windows, DETACH so that is it removed from Docker and made available in Windows.

Running BIND - only once for each new device in a new USB port.

**Scripts Included:**

```powershell
# Windows PowerShell scripts in ./scripts/
.\scripts\usb-list.ps1      # List USB devices
.\scripts\usb-bind.ps1      # Bind device to Docker (needed only once per device x usb port)
.\scripts\usb-attach.ps1    # Attach device to Docker (needed after each plug in)
.\scripts\usb-detach.ps1    # Detach device from Docker
```



### 2. Set Up Your Project

```bash
# Copy your entire ESP-IDF project folder into project-root-folder
cp -r /path/to/your/my-esp32-project ./project-root-folder/

# Result structure:
# project-root-folder/
# └── my-esp32-project/  ← your project
#     ├── main/
#     ├── CMakeLists.txt
#     └── ...

# Edit .env to set your project folder name
nano .env  # or use your favorite editor
```

### 3. Start the Docker Environment

```bash
# Build and start the container
docker compose up -d
```

### 4. Build and Flash Your Project

Go to the *scripts* folder to use a shortcut script **run.ps1** or **run.sh** that
will make running tools super easy:

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

Press `Ctrl+]` to exit the monitor.



## Project Structure

```
lysos-workspace-v*/
├── docker-compose.yml         # Docker orchestration
├── Dockerfile                 # ESP-IDF container definition
├── .env.example               # Environment variables template
├── README.md                  # This file
├── scripts/                   # Helper scripts
│   ├── usb-*.ps1             # Windows USB management
│   ├── run.ps1               # Windows runner
│   └── run.sh                # Linux/macOS runner
└── project-root-folder/       # COPY YOUR PROJECT FOLDER HERE
    └── (your-project-name)/   # Your ESP-IDF project folder
        ├── main/
        ├── CMakeLists.txt
        └── ...
```

### About project-root-folder

The `project-root-folder` is where you copy your entire ESP-IDF project folder (not just the files, but the whole folder). This keeps Docker configuration separate from your code and allows proper container naming.

**Structure Example:**

If your project is called `remote-node-zero`:

```
project-root-folder/
└── remote-node-zero/          ← your project folder
    ├── main/
    │   └── main.c
    ├── CMakeLists.txt
    └── ...
```

**Setup:**

1. Copy your project: `cp -r /path/to/remote-node-zero ./project-root-folder/`
2. Edit `.env` and set `PROJECT_NAME=remote-node-zero`
3. Docker will mount `./project-root-folder/remote-node-zero` as `/workspace`

## Common Commands

### Container Management

```bash
# Start container
docker compose up -d

# Stop container
docker compose down

# Restart container (needed after USB attach)
docker compose restart

# Enter container (not really needed)
docker compose exec esp-idf bash

# View container logs
docker compose logs -f
```

### Run Commands Easily

```bash
cd scripts
# One-off commands (non-interactive)
./run.sh idf.py build
./run.sh idf.py --version
```

The run.sh (for Linux) or run.ps1 (for Windows) is a shortcut script to run tools that are inside the container.

### Inside the Container (NOT recommended)

I recommend using the shortcut above ^^^ with the run.sh/ps1 script.

You first need to enter the container and then you can run ESP-IDF commands:


```bash
docker compose exec esp-idf bash

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



## Configuration

### Environment Variables (.env)

The `.env` file controls build and runtime configuration.

Every time you make ANY change in the .env file, you MUST run:


```bash
docker compose down
docker compose up -d --build
```

## Troubleshooting

### USB Device Not Found

**Windows:**

- Run `usbipd list` to verify device is attached (scripts/usb-list.ps1)
- Restart container: `docker compose restart`
- Check WSL2 has device: `wsl ls -l /dev/ttyUSB*`

**Linux**

- Check permissions: `ls -l /dev/ttyUSB0`


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

### Using Your Own ESP-IDF Project

Copy your entire project folder into `project-root-folder/`:

```bash
# Copy your project folder (not just its contents!)
cp -r /path/to/my-esp32-project ./project-root-folder/

# Update .env with your project folder name
echo "PROJECT_NAME=my-esp32-project" >> .env
```

**Alternative: Use a symlink**

```bash
# Create a symlink to your project
ln -s /path/to/my-esp32-project ./project-root-folder/my-esp32-project

# Update .env
echo "PROJECT_NAME=my-esp32-project" >> .env
```

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
docker volume rm lysos-workspace_espidf-cargo-cache
docker volume rm lysos-workspace_espidf-ccache-cache
```

## Support and Resources

- **ESP-IDF Documentation**: https://docs.espressif.com/projects/esp-idf/
- **ESP-IDF GitHub**: https://github.com/espressif/esp-idf
- **usbipd-win**: https://github.com/dorssel/usbipd-win

## License

AGPLv3 License (OSS edition).

Pro edition available under commercial license.

## Trademarks

ESP-IDF and ESP32 are trademarks of Espressif Systems. This project is not affiliated with or endorsed by Espressif.

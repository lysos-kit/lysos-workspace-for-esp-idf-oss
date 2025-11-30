ESP32 Starter Kit OSS

This project creates a dockerized environment for ESP32 development by installing ESP IDF framework inside isolated docker containers and mounting the local project files.

Thanks to this approach, the embedded developers can easily start up any version of ESP IDF and avoid python version conflicts that often happen when installed directly on the host machine.

Because the ESP IDF framework uses an external hardware programmer/debugger for flashing microcontrollers, we need to have access to the serial port inside the container.

Most ESP32 programmers runs on USB interface, so in order to have USB serial port access inside the container we must share the interface from Windows to the WSL2 subsystem that the Docker is running on.

The utility for this is called "usbipd".

## How To Connect ESP32 Programmer To The Container

- first, you must plug in the programmer to the computer via USB
- then, you must list the USB device and get its "BUSID" - run command `usbipd list` on the Windows host
- you get an output like this:

```
C:\Windows\System32>usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-2    0403:6010  USB Serial Converter A, USB Serial Converter B                Not shared
2-2    8087:0032  Intel(R) Wireless Bluetooth(R)                                Not shared
2-3    13d3:5463  USB2.0 HD UVC WebCam, Camera DFU Device                       Not shared

Persisted:
GUID                                  DEVICE

```

- the BUSID is in format like "1-2" or "2-3" - in this example, the ESPPROG has busid "1-2"
- we then need to SHARE the USB device with the WSL2 (Docker) by running command `usbipd bind --busid 1-2`
- we then run `usbipd list` and you can see the device has been shared:

```
C:\Windows\System32>usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-2    0403:6010  USB Serial Converter A, USB Serial Converter B                Shared
2-2    8087:0032  Intel(R) Wireless Bluetooth(R)                                Not shared
2-3    13d3:5463  USB2.0 HD UVC WebCam, Camera DFU Device                       Not shared

Persisted:
GUID                                  DEVICE

```

- we now attach it to the WSL by running `usbipd attach --wsl --busid 1-2`, see the example output:

```
C:\Windows\System32>usbipd attach --wsl --busid 1-2
usbipd: info: Using WSL distribution 'Ubuntu-24.04' to attach; the device will be available in all WSL 2 distributions.
usbipd: info: Loading vhci_hcd module.
usbipd: info: Detected networking mode 'nat'.
usbipd: info: Using IP address 172.28.208.1 to reach the host.
```

- after successful attachment, the device is now available inside the docker container under /dev/ttyUSBX, where X is a number from 0 upwards.
- the device will become UNAVAILABLE on Windows because the access is EXCLUSIVE
- you MUST also RESTART the docker container after attachment, so it can pick up the newly attached USB devices!

## Running ESPIDF Commands Inside The Container

- to run ANY command inside the container, you must PREFIX that command with `docker compose exec esp-idf`
- to run bash inside, run `docker compose exec esp-idf bash`

## idf.py Commands

- Enter the container: `docker compose exec esp-idf bash`
- Then run commands normally:
  - monitor - `idf.py monitor` - exit by sending CTRL+]
  - flash - `idf.py flash`
  - build - `idf.py build`
  - menuconfig - `idf.py menuconfig`

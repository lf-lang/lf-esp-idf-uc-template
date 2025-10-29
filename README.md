# Reactor-uc ESP-IDF Template

- **Git:** <https://github.com/espressif/esp-idf>
- **Supported Boards:** ESP32, ESP32-C3, ESP32-C6, ESP32-S2, ESP32-S3, and more
- **Documentation:** <https://docs.espressif.com/projects/esp-idf/en/latest/>
- **Additional Resources:**
    - [Reactor-uc](https://github.com/lf-lang/reactor-uc)
    - [Lingua Franca](https://github.com/lf-lang/lingua-franca)

______

This is a project template for developing applications targeting ESP32-based microcontrollers using the micro-C target of Lingua Franca with the ESP-IDF framework.

## 1. Prerequisites

### 1.1. Basic

You must use one of the following operating systems:

- `Linux` — Officially supported are Debian & Ubuntu
- `macOS`
- `Windows` — via WSL2

Your system must have the following software packages:

- `git` — [a distributed version control system](https://git-scm.com/)
- `java` — [Java 17](https://openjdk.org/projects/jdk/17)
- `python3` — Python 3.8 or newer
- `cmake` — Version 3.20 or newer
- `ninja` — Build system

### 1.2. Micro C Target for Lingua Franca

This template uses [reactor-uc](https://github.com/lf-lang/reactor-uc), the "micro C" target for Lingua Franca. Clone this repo with one of the following commands:

#### Clone via HTTPS

```bash
git clone https://github.com/lf-lang/reactor-uc.git --recurse-submodules
```

#### Or Clone via SSH

```bash
git clone git@github.com:lf-lang/reactor-uc.git --recurse-submodules
```

And make sure that the `REACTOR_UC_PATH` environment variable is pointing to it:

```bash
export REACTOR_UC_PATH=/path/to/reactor-uc
```

## 2. Setup

Create a new repository based on this template, clone it recursively to your local machine and enter
the directory from your favourite shell.

Make sure the `esp-idf` submodule is initialized:

```bash
git submodule update --init --recursive
```

### 2.1. Configure the Development Environment

#### 2.1.1. Option A: Using Nix (Recommended)

If you have Nix with flakes enabled, you can use the provided Nix configuration for a reproducible development environment:

```bash
# Enter development shell with default board (ESP32)
nix develop

# Or specify a different board
nix develop .#esp32c3
nix develop .#esp32
nix develop .#all
```

The Nix shell will automatically:
- Install all required dependencies
- Install ESP-IDF tools for your target board
- Set up the environment variables

#### 2.2.2. Option B: Manual Setup

Install the required packages for your system as per the ESP-IDF documentation: <https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html#manual-installation>

After installing the ESP-IDF prerequisites, set up the ESP-IDF environment by running:

```bash
cd esp-idf
./install.sh esp32c6  # Replace with your board: esp32, esp32c3, esp32c6, all, etc.
source ./export.sh    # Configure the development environment
cd ..
```

You'll need to source `export.sh` every time you open a new terminal. 

## 3. Building

In this template we have integrated the Lingua Franca compiler `lfc` into `CMake`. To build an application,
first set the target board as an environment variable:

```bash
export ESP_BOARD=esp32c6  # or esp32, esp32c3, etc.
```

Then configure the project:

```bash
cmake -Bbuild -DESP_IDF_BOARD=$ESP_BOARD -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake -GNinja
```

This step will invoke `lfc` on the main LF application and configure the ESP-IDF build system.

Build the application:

```bash
cmake --build build -j $(nproc)
```

To rebuild the application after making changes, simply repeat the last command:

```bash
cmake --build build -j $(nproc)
```

If CMake detects any changes to any files found in `src/*.lf`, the configure step will be rerun automatically.

## 4. Flashing

To flash the compiled binary to your ESP32 board:

```bash
cd build
ninja flash
```

Or specify the serial port explicitly if auto-detection fails:

```bash
ninja flash -p /dev/ttyUSB0  # Linux/macOS
ninja flash -p COM3          # Windows
```

To flash and immediately monitor the serial output:

```bash
ninja flash && ninja monitor
```

Press `Ctrl+]` to exit the monitor.

## 5. Changing Build Parameters

To change build parameters, such as which LF application to build or the log level, we
recommend that you modify the corresponding variable at the top of the
[CMakeLists.txt](./CMakeLists.txt). Alternatively, you can override the variables from
the command line:

```bash
cmake -Bbuild -DLF_MAIN=HelloEsp -DLOG_LEVEL=LF_LOG_LEVEL_DEBUG -DESP_BOARD=$ESP_BOARD -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$.cmake -GNinja
```

Available parameters:
- `LF_MAIN` — Name of the main LF file to compile (default: `HelloEsp`)
- `LOG_LEVEL` — Logging level (default: `LF_LOG_LEVEL_WARN`)
  - Options: `LF_LOG_LEVEL_ERROR`, `LF_LOG_LEVEL_WARN`, `LF_LOG_LEVEL_INFO`, `LF_LOG_LEVEL_DEBUG`
- `ESP_IDF_BOARD` — Target board 
  - Options: `esp32`, `esp32c3`, `esp32c6`, `esp32s2`, `esp32s3`, `esp32h2`, etc.

## 7. Cleaning Build Artifacts

To delete all build artifacts from both CMake and LFC:

```bash
rm -rf src-gen build
```

## 8. Project Structure

```
lf-esp-idf-uc-template/
├── CMakeLists.txt          # Main build configuration
├── esp-idf/                # ESP-IDF framework (submodule)
├── src/                    # LF source files
│   ├── Blink.lf           # LED blink example
│   ├── HelloEsp.lf        # Hello world example
│   ├── Timer.lf           # Timer example
│   └── lib/               # Reusable LF reactors
│       └── Led.lf         # LED reactor library
├── sdkconfig              # ESP-IDF configuration
├── flake.nix              # Nix flake configuration
└── shell.nix              # Nix shell environment
```

## Example Applications

This template includes several example applications:

### HelloEsp (Default)
A hello world application that prints to the serial console.

```bash
cmake -Bbuild -DLF_MAIN=HelloEsp -DESP_BOARD=$ESP_BOARD -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake -GNinja
cmake --build build -j $(nproc)
```

### Timer
Demonstrates timer usage with periodic events.

```bash
cmake -Bbuild -DLF_MAIN=Timer -DESP_BOARD=$ESP_BOARD -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake -GNinja
cmake --build build -j $(nproc)
```

### Blink
A simple LED blink application that toggles the onboard LED.

```bash
cmake -Bbuild -DLF_MAIN=Blink -DESP_BOARD=$ESP_BOARD -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake -GNinja
cmake --build build -j $(nproc)
```

## 10. WSL Support

When using the Windows Subsystem for Linux on a Windows machine for development, there are a few extra steps to attach the ESP32 device to your WSL instance.
The official [instructions](https://learn.microsoft.com/en-us/windows/wsl/connect-usb) are reflected here. Install the required software and execute the following.

Open a PowerShell prompt as an administrator:

```powershell
usbipd wsl list
```

Note the `busid` of the ESP32 device. ESP32 boards typically show as **USB Serial Device** or **USB JTAG/Serial Debug Unit**.

Attach the device using the following command:

```powershell
usbipd wsl attach --busid <bus_id>
```

This will mount the device to the WSL instance. In a WSL shell, check the device has been attached:

```bash
ls /dev/ttyUSB* # or /dev/ttyACM*
```
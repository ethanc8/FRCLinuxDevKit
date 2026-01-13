# FRC Linux/macOS Development Kit

This script will install all the necessary software to connect to the roboRIO from Linux or macOS. Currently, this includes:

* WPILib
* WPILib VSCode extension installation in existing IDE (optional)
* OpenDS (open-source driver station)

Additionally, it also installs these useful FRC tools:

* PathPlanner

## Usage

Make sure `curl` is installed on your system. This is true on macOS, at least.

To run the script, you must have a display (X11 or Wayland) and a network connection. The installation will require you to interact with the WPILib installer.

```bash
curl -o- -L https://raw.githubusercontent.com/ethanc8/FRCLinuxDevKit/macos/install-online.sh | bash
```

If you also want to install the WPILib extension into your main VSCode or VSCodium installation, please set the environment variable FLDK_INSTALL_EXT_DESTINATION to the name of the command that launches VSCode (which is `code` for Microsoft binaries, `code-oss` if you compiled it yourself, and `codium` for VSCodium). For example:

```bash
curl -o- -L https://raw.githubusercontent.com/ethanc8/FRCLinuxDevKit/macos/install-online.sh | FLDK_INSTALL_EXT_DESTINATION=code bash
```

### Parameters

* `FLDK_INSTALL_WPILIB`: Whether or not to install WPILib (default true)
* `FLDK_INSTALL_EXT_DESTINATION`: command that launches VSCode or VSCode derivative to install WPILib extension into (default: don't install the WPILib extension)
* `FLDK_INSTALL_OPENDS`: Whether or not to install OpenDS (default true)
* `FLDK_INSTALL_PATHPLANNER`: Whether or not to install PathPlanner (default true)

## Wiring to the roboRIO

1. Connect power to the roboRIO
2. Power the radio
3. Plug an Ethernet cable into the radio's RIO port and the other end into the Rio
4. Plug an Ethernet cable into the radio's right port and the other end into your computer (you may need a USB-to-Ethernet adapter if you're doing this from a laptop)

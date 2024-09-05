#!/bin/bash

sudo apt install wget curl

mkdir -p ~/Downloads/FRCLinuxDevKit && cd ~/Downloads/FRCLinuxDevKit || echo "Warning: Could not create and move to ~/Downloads/FRCLinuxDevKit"

arch=$(uname -m)
wpilib_version=2024.3.2

case $arch in
    x86_64)
        wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/Linux/WPILib_Linux-${wpilib_version}.tar.gz
        wpilib_filename=WPILib_Linux-${wpilib_version}.tar.gz
        ;;
    aarch64)
        wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/LinuxArm64/WPILib_LinuxArm64-${wpilib_version}.tar.gz
        wpilib_filename=WPILib_LinuxArm64-${wpilib_version}.tar.gz
        ;;
    default)
        echo "Your architecture, \"$arch\", was not known. Downloading the x86 version..."
        wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/Linux/WPILib_Linux-${wpilib_version}.tar.gz
        wpilib_filename=WPILib_Linux-${wpilib_version}.tar.gz
        ;;
esac

cat <<EOF >~/.profile
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF

echo "Downloading WPILib..."
wget "$wpilib_download" || exit 1
tar xzf "$wpilib_filename" || exit 1

echo "Please install WPILib. It's your choice whether to install the WPILib VS Code, but we recommend that you do not."

./WPILibInstaller

if [[ -n "$FLDK_INSTALL_EXT_DESTINATION" ]]; then
    echo "Installing wpilib-${wpilib_version} extension into your $FLDK_INSTALL_EXT_DESTINATION installation..."
    "$FLDK_INSTALL_EXT_DESTINATION" --install-extension "$HOME/wpilib/2024/vsCodeExtensions/vscode-wpilib-${wpilib_version}.vsix"
fi

echo "WPILib ${wpilib_version} has been successfully installed!"

mkdir -p ~/Applications && cd ~/Applications || echo "Warning: Could not create and move to ~/Applications"
applications_dir="$(pwd)"

echo "Downloading OpenDS..."
open_ds_version=0.2.4
open_ds_download=https://github.com/Boomaa23/open-ds/releases/download/v${open_ds_version}/open-ds-v${open_ds_version}.jar
open_ds_icon=https://raw.githubusercontent.com/Boomaa23/open-ds/master/src/main/resources/icon.png

wget $open_ds_download || exit 1
wget --output-document ~/.local/share/icons/hicolor/128x128/apps/open-ds.png $open_ds_icon
mkdir -p ~/.local/bin

cat <<EOF >~/.local/bin/open-ds || (echo "Error: Could not write to ~/.local/bin/open-ds"; exit 1)
#!/bin/bash
~/wpilib/2024/jdk/bin/java -jar $applications_dir/open-ds-v${open_ds_version}.jar
EOF

chmod +x ~/.local/bin/open-ds

cat <<EOF >~/.local/share/applications/open-ds.desktop
[Desktop Entry]
Comment=2024 FRC Driver Station (unofficial)
Exec=open-ds
GenericName=2024 FRC Driver Station (unofficial)
Icon=open-ds
Name=OpenDS
NoDisplay=false
Path=
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF

echo "OpenDS ${open_ds_version} has been successfully installed and can be used with the command \`open-ds\`!"

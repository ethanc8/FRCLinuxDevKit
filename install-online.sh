#!/bin/bash

# Try installing wget and curl
(apt --help > /dev/null && sudo apt install wget curl) || true

mkdir -p ~/Downloads/FRCLinuxDevKit && cd ~/Downloads/FRCLinuxDevKit || echo "Warning: Could not create and move to ~/Downloads/FRCLinuxDevKit"

# uname -m is the architecture of the OS, uname -p is the architecture of the CPU.
arch=$(uname -m)
wpilib_version=2024.3.2

if [[ "$FLDK_INSTALL_WPILIB" != 0 ]]; then
case "$OSTYPE" in
    darwin*)
        case $arch in
            x86_64)
                wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/macOS/WPILib_macOS-Intel-${wpilib_version}.dmg
                wpilib_filename=WPILib_Linux-${wpilib_version}.dmg
                ;;
            arm64)
                wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/macOSArm/WPILib_macOS-Arm64-${wpilib_version}.dmg
                wpilib_filename=WPILib_macOS-Arm64-${wpilib_version}.dmg
                ;;
        esac
    ;;
    linux*)   
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
    ;;
esac

echo "Downloading WPILib..."
curl -OL "$wpilib_download" || exit 1
case "$OSTYPE" in
    darwin*)
        hdiutil attach "$wpilib_filename" || exit 1
    ;;
    linux*)
        tar xzf "$wpilib_filename" || exit 1
    ;;
esac
echo "Please install WPILib."

case "$OSTYPE" in
    darwin*)
        open /Volumes/WPILibInstaller/WPILibInstaller.app
    ;;
    linux*)
        ./WPILibInstaller
    ;;
esac

if [[ -n "$FLDK_INSTALL_EXT_DESTINATION" ]]; then
    echo "Installing wpilib-${wpilib_version} extension into your $FLDK_INSTALL_EXT_DESTINATION installation..."
    "$FLDK_INSTALL_EXT_DESTINATION" --install-extension "$HOME/wpilib/2024/vsCodeExtensions/vscode-wpilib-${wpilib_version}.vsix"
fi

echo "WPILib ${wpilib_version} has been successfully installed!"

else
echo "WPILib was not installed."
fi # FLDK_INSTALL_WPILIB

case "$OSTYPE" in
    darwin*)

# The bundle was made by Platypus.
rm OpenDS.zip
rm -r ~/Applications/OpenDS.app
curl https://github.com/ethanc8/FRCLinuxDevKit/raw/macos/OpenDS.zip -OL
unzip OpenDS.zip
mv OpenDS.app ~/Applications

cat << EOF >> ~/.bash_profile
# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:\$PATH"
EOF

cat << EOF >> ~/.zprofile
# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:\$PATH"
EOF

cat <<EOF >~/.local/bin/frccode2024
#!/bin/bash
APP_PATH="\$HOME/wpilib/2024/vscode/Visual Studio Code.app"
CONTENTS="\$APP_PATH/Contents"
ELECTRON="\$CONTENTS/MacOS/Electron"
CLI="\$CONTENTS/Resources/app/out/cli.js"
ELECTRON_RUN_AS_NODE=1 "\$ELECTRON" "\$CLI" --ms-enable-electron-run-as-node "\$@"
exit \$?
EOF

chmod +x ~/.local/bin/frccode2024

cat <<EOF >~/.local/bin/open-ds || (echo "Error: Could not write to ~/.local/bin/open-ds"; exit 1)
#!/bin/bash
open ~/Applications/OpenDS.app
EOF

chmod +x ~/.local/bin/open-ds

    ;;
    linux*)

cat <<EOF >~/.profile
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF

mkdir -p ~/Applications && cd ~/Applications || echo "Warning: Could not create and move to ~/Applications"
applications_dir="$(pwd)"

echo "Downloading OpenDS..."
open_ds_version=0.2.4
open_ds_download=https://github.com/Boomaa23/open-ds/releases/download/v${open_ds_version}/open-ds-v${open_ds_version}.jar
open_ds_icon=https://raw.githubusercontent.com/Boomaa23/open-ds/master/src/main/resources/icon.png

curl -OL $open_ds_download || exit 1
curl -L $open_ds_icon --output ~/.local/share/icons/hicolor/128x128/apps/open-ds.png
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
    ;;
esac
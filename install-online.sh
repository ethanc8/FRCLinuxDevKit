#!/bin/bash

# Try installing wget and curl
(apt --help 2>&1 > /dev/null && sudo apt install wget curl) || true

mkdir -p ~/Downloads/FRCLinuxDevKit && cd ~/Downloads/FRCLinuxDevKit || echo "Warning: Could not create and move to ~/Downloads/FRCLinuxDevKit"

# uname -m is the architecture of the OS, uname -p is the architecture of the CPU.
arch=$(uname -m)
wpilib_version=2025.3.1

###############################
##### WPILib installation #####
###############################

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
                wpilib_filename=WPILib_Linux-${wpilib_version}
                ;;
            aarch64)
                wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/LinuxArm64/WPILib_LinuxArm64-${wpilib_version}.tar.gz
                wpilib_filename=WPILib_LinuxArm64-${wpilib_version}
                ;;
            default)
                echo "Your architecture, \"$arch\", was not known. Downloading the x86 version..."
                wpilib_download=https://packages.wpilib.workers.dev/installer/v${wpilib_version}/Linux/WPILib_Linux-${wpilib_version}.tar.gz
                wpilib_filename=WPILib_Linux-${wpilib_version}
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
        tar xzf "$wpilib_filename.tar.gz" || exit 1
        rm "$wpilib_filename.tar.gz"
    ;;
esac
echo "Please install WPILib."

case "$OSTYPE" in
    darwin*)
        open /Volumes/WPILibInstaller/WPILibInstaller.app
    ;;
    linux*)
        "$wpilib_filename/WPILibInstaller"
    ;;
esac

case "$OSTYPE" in
    darwin*)
        cat <<EOF >~/.local/bin/frccode2025
#!/bin/bash
APP_PATH="\$HOME/wpilib/2025/vscode/Visual Studio Code.app"
CONTENTS="\$APP_PATH/Contents"
ELECTRON="\$CONTENTS/MacOS/Electron"
CLI="\$CONTENTS/Resources/app/out/cli.js"
ELECTRON_RUN_AS_NODE=1 "\$ELECTRON" "\$CLI" --ms-enable-electron-run-as-node "\$@"
exit \$?
EOF
        chmod +x ~/.local/bin/frccode2025
    ;;
esac

echo "WPILib ${wpilib_version} has been successfully installed!"

else
echo "WPILib was not installed."
fi # FLDK_INSTALL_WPILIB

########################
##### ~/.local/bin #####
########################

case "$OSTYPE" in
    darwin*)
cat << EOF >> ~/.bash_profile
# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:\$PATH"
EOF

cat << EOF >> ~/.zprofile
# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:\$PATH"
EOF
    ;;
    linux*) # TODO: Is it necessary to special-case here?
cat << EOF >> ~/.profile
# Add ~/.local/bin to the PATH
export PATH="$HOME/.local/bin:\$PATH"
EOF
    ;;
esac

################################################
##### WPILib VSCode extension installation #####
################################################

if [[ -n "$FLDK_INSTALL_EXT_DESTINATION" ]]; then
    echo "Installing wpilib-${wpilib_version} extension into your $FLDK_INSTALL_EXT_DESTINATION installation..."
    "$FLDK_INSTALL_EXT_DESTINATION" --install-extension "$HOME/wpilib/2025/vsCodeExtensions/vscode-wpilib-${wpilib_version}.vsix"
fi

###############################
##### OpenDS installation #####
###############################

if [[ "$FLDK_INSTALL_OPENDS" != 0 ]]; then
case "$OSTYPE" in
    darwin*)

# The bundle was made by Platypus.
rm OpenDS.zip
rm -r ~/Applications/OpenDS.app
curl https://github.com/ethanc8/FRCLinuxDevKit/raw/macos/OpenDS.zip -OL
unzip OpenDS.zip
mv OpenDS.app ~/Applications


chmod +x ~/.local/bin/frccode2025

cat <<EOF >~/.local/bin/open-ds || (echo "Error: Could not write to ~/.local/bin/open-ds"; exit 1)
#!/bin/bash
open ~/Applications/OpenDS.app
EOF

chmod +x ~/.local/bin/open-ds

    ;;
    linux*)
mkdir -p ~/Applications && cd ~/Applications || echo "Warning: Could not create and move to ~/Applications"
applications_dir="$(pwd)"

echo "Downloading OpenDS..."
open_ds_version=0.2.4
open_ds_download=https://github.com/Boomaa23/open-ds/releases/download/v${open_ds_version}/open-ds-v${open_ds_version}.jar
open_ds_icon=https://raw.githubusercontent.com/Boomaa23/open-ds/master/src/main/resources/icon.png

curl -OL $open_ds_download || exit 1
mkdir -p ~/.local/share/icons/hicolor/128x128/apps
curl -L $open_ds_icon --output ~/.local/share/icons/hicolor/128x128/apps/open-ds.png
mkdir -p ~/.local/bin

cat <<EOF >~/.local/bin/open-ds || (echo "Error: Could not write to ~/.local/bin/open-ds"; exit 1)
#!/bin/bash
~/wpilib/2025/jdk/bin/java -jar $applications_dir/open-ds-v${open_ds_version}.jar
EOF

chmod +x ~/.local/bin/open-ds

cat <<EOF >~/.local/share/applications/open-ds.desktop
[Desktop Entry]
Comment=2025 FRC Driver Station (unofficial)
Exec=open-ds
GenericName=2025 FRC Driver Station (unofficial)
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

else
echo "OpenDS was not installed."
fi # FLDK_INSTALL_OPENDS

####################################
##### PathPlanner installation #####
####################################

pathplanner_version=2025.2.2

if [[ "$FLDK_INSTALL_PATHPLANNER" != 0 ]]; then
case "$OSTYPE" in
    darwin*)

echo "Downloading PathPlanner..."
rm PathPlanner-macOS.zip
rm "PathPlanner-macOS-v${pathplanner_version}.zip"
rm -r ~/Applications/PathPlanner.app
curl -OL "https://github.com/mjansen4857/pathplanner/releases/download/v${pathplanner_version}/PathPlanner-macOS-v${pathplanner_version}.zip" || exit 1

echo "Installing PathPlanner..."
unzip "PathPlanner-macOS-v${pathplanner_version}.zip"
unzip PathPlanner-macOS.zip
mv PathPlanner.app ~/Applications

cat <<EOF >~/.local/bin/pathplanner || (echo "Error: Could not write to ~/.local/bin/pathplanner"; exit 1)
#!/bin/bash
open ~/Applications/PathPlanner.app
EOF

echo "PathPlanner ${pathplanner_version} has been successfully installed and can be used with the command \`pathplanner\`!"

    ;;
    linux*)
mkdir -p ~/Applications && cd ~/Applications || echo "Warning: Could not create and move to ~/Applications"
applications_dir="$(pwd)"

rm -r ~/Applications/PathPlanner
mkdir PathPlanner && cd PathPlanner || echo "Warning: Could not create and move to ~/Applications/PathPlanner"

echo "Downloading PathPlanner..."
rm "PathPlanner-Linux-v${pathplanner_version}.zip"
curl "https://github.com/mjansen4857/pathplanner/releases/download/v${pathplanner_version}/PathPlanner-Linux-v${pathplanner_version}.zip" -OL

echo "Installing PathPlanner..."
unzip "PathPlanner-Linux-v${pathplanner_version}.zip"

ln -s ~/Applications/PathPlanner/pathplanner ~/.local/bin/pathplanner
chmod +x ~/.local/bin/pathplanner

mkdir -p ~/.local/share/icons/hicolor/512x512/apps
cp ~/Applications/PathPlanner/data/flutter_assets/images/icon.png ~/.local/share/icons/hicolor/512x512/apps/pathplanner.png

cat <<EOF >~/.local/share/applications/pathplanner.desktop
[Desktop Entry]
Comment=2025 FRC autonomous path generator
Exec=pathplanner
GenericName=PathPlanner
Icon=pathplanner
Name=PathPlanner
NoDisplay=false
Path=
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF

echo "PathPlanner ${pathplanner_version} has been successfully installed and can be used with the command \`pathplanner\`!"
    ;;
esac

else
echo "PathPlanner was not installed."
fi # FLDK_INSTALL_PATHPLANNER

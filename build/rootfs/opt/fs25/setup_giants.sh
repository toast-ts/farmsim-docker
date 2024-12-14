#!/bin/bash

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/.fs_server
export WINEARCH=win64
export USER=nobody

# Variable to make things easier
FARMSIM_DOCS_PARENT="$WINEPREFIX/drive_c/users/$USER/Documents/My Games"
FARMSIM_DOCS="$FARMSIM_DOCS_PARENT/FarmingSimulator2025"
FARMSIM_INSTALL="$WINEPREFIX/drive_c/Program Files (x86)/Farming Simulator 2025"
FARMSIM_EXECUTABLE="$FARMSIM_INSTALL/FarmingSimulator2025.exe"

# Paths on filesystem
DOCS_PATH="/opt/fs25/docs"
DLC_PATH="/opt/fs25/dlc"
INSTALLER_PATH="/opt/fs25/install/FarmingSimulator2025.exe"
DESKTOP_ICONS="~/Desktop/*.{lnk}"

# Debug info/warning/error color
NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create a clean 64bit Wineprefix
if [ -d ~/.fs_server ]; then
  wine wineboot
fi

# it's important to check if the config directory exists on the host mount path. If it doesn't exist, create it.
if [ -d $DOCS_PATH ]; then
  echo -e "${GREEN}INFO: The host config directory exists, no need to create it!${NOCOLOR}"
else
  mkdir -p $DOCS_PATH
fi

# Symlink the host config path inside the wine prefix to preserver the config files on image deletion or update.
if [ -d "$FARMSIM_DOCS" ]; then
  echo -e "${GREEN}INFO: The symlink is already in place, no need to create one!${NOCOLOR}"
else
  mkdir -p "$FARMSIM_DOCS_PARENT" && ln -s "$DOCS_PATH" "$FARMSIM_DOCS"
fi

if [ -d "$FARMSIM_DOCS/dedicated_server/logs" ]; then
  echo -e "${GREEN}INFO: The log directories are in place!${NOCOLOR}"
else
  mkdir -p $FARMSIM_DOCS/dedicated_server/logs
fi

if [ -f "$FARMSIM_EXECUTABLE" ]; then
  echo -e "${GREEN}INFO: Game already installed, we can skip the installer!${NOCOLOR}"
else
  wine "$INSTALLER_PATH"
fi

# Cleanup Desktop
if [ -f ~/Desktop/ ]; then
  rm -r "$DESKTOP_ICONS"
else
  echo -e "${GREEN}INFO: Nothing on desktop to cleanup!${NOCOLOR}"
fi

# Do we have a license file installed?
count=$(ls -1 "$FARMSIM_DOCS"/*.dat 2>/dev/null | wc -l)
if [ "$count" -eq 0 ]; then
  echo -e "${GREEN}INFO: Generating the game license files as needed!${NOCOLOR}"
  wine "$FARMSIM_EXECUTABLE"
else
  echo -e "${GREEN}INFO: The license files are in place!${NOCOLOR}"
fi

count=$(ls -1 "$FARMSIM_DOCS"/*.dat 2>/dev/null | wc -l)
if [ "$count" -eq 0 ]; then
  echo -e "${RED}ERROR: No license files detected, they are generated after you enter the product key during setup... most likely the setup is failing to start!${NOCOLOR}" \
  && exit 1
fi

# Check config if not exist then exit
if [ -f "$FARMSIM_DOCS/dedicated_server/dedicatedServerConfig.xml" ]; then
  echo -e "${GREEN}INFO: We can run the server now by clicking on 'Start Server' on the desktop!${NOCOLOR}"
else
  echo -e "${RED}ERROR: We are missing files?${NOCOLOR}" && exit
fi

echo -e "${YELLOW}INFO: Checking for updates, if you get warning about 'Shader Model 6.0', ignore it${NOCOLOR}"
wine "$FARMSIM_EXECUTABLE"

#!/bin/bash

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/.fs_server
export WINEARCH=win64
export USER=nobody

# Variable to make things easier
FARMSIM_DOCS_PARENT="$WINEPREFIX/drive_c/users/$USER/Documents/My Games"
FARMSIM_DOCS="$FARMSIM_DOCS_PARENT/FarmingSimulator2025"
FARMSIM_DLCS="$FARMSIM_DOCS/pdlc/${dlc_name}.dlc"

# Paths on filesystem
DLC_PATH="/opt/fs25/dlc"

# Debug info/warning/error color
NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create a clean 64bit Wineprefix
if [ -d ~/.fs_server ]; then
  wine wineboot
fi

# Check if DLC installers exists in host directory
check_dlc_installer() {
  local dlc_name=$1
  local installer_pattern=$2

  if ls $DLC_PATH/${installer_pattern} 1> /dev/null 2>&1; then
    echo -e "${GREEN}INFO: ${dlc_name} setup found!${NOCOLOR}"
  else
    echo -e "${YELLOW}WARNING: ${dlc_name} setup not found, does it exist in the dlc mount path?${NOCOLOR}"
    echo -e "${YELLOW}WARNING: If you do not own it, ignore this!${NOCOLOR}"
  fi
}

# Map of DLC names and their installers
declare -A dlc_installer_patterns=(
  ["macDonPack"]="FarmingSimulator25_macDonPack_*.exe"
)

# Map of DLCs and their installers
declare -A dlcs=(
  ["MacDon Pack"]="macDonPack"
)

# Install DLC
install_dlc() {
  local dlc_name=$1
  local exe_pattern=$2

  if [ -f "$FARMSIM_DLCS" ]; then
    echo -e "${GREEN}INFO: ${dlc_name} already exists!${NOCOLOR}"
  else
    if ls $DLC_PATH/${exe_pattern} 1> /dev/null 2>&1; then
      echo -e "${GREEN}INFO: Installing ${dlc_name}!${NOCOLOR}"
      for i in $DLC_PATH/${exe_pattern}; do wine "$i"; done
      if [ -f "$FARMSIM_DLCS" ]; then
        echo -e "${GREEN}INFO: ${dlc_name} is now installed!${NOCOLOR}"
      fi
    fi
  fi
}

# Recursively install the DLCs
for dlc in "${!dlcs[@]}"; do
  check_dlc_installer "$dlc" "${dlc_installer_patterns[${dlcs[$dlc]}]}"
done

for dlc in "${!dlcs[@]}"; do
  install_dlc "$dlc" "${dlc_installer_patterns[${dlcs[$dlc]}]}"
done

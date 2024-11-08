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
GAME_PATH="/opt/fs25/game"
INSTALLER_PATH="/opt/fs25/install/FarmingSimulator2025.exe"
DESKTOP_ICONS="~/Desktop/Farming\ Simulator\ 25\ .*"

# Debug info/warning/error color

NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create a clean 64bit Wineprefix

if [ -d ~/.fs_server ]; then
  rm -r ~/.fs_server && wine wineboot
else
  wine wineboot
fi

# # Check if DLC installers exists in host directory
# check_dlc_installer() {
#   local dlc_name=$1
#   local installer_pattern=$2

#   if ls $DLC_PATH/${installer_pattern} 1> /dev/null 2>&1; then
#     echo -e "${GREEN}INFO: ${dlc_name} setup found!${NOCOLOR}"
#   else
#     echo -e "${YELLOW}WARNING: ${dlc_name} setup not found, does it exist in the dlc mount path?${NOCOLOR}"
#     echo -e "${YELLOW}WARNING: If you do not own it, ignore this!${NOCOLOR}"
#   fi
# }

# # Map of DLC names and their installers
# declare -A dlc_installer_patterns=(
#   ["antonioCarraroPack"]="FarmingSimulator22_antonioCarraroPack_*.exe"
#   ["agiPack"]="FarmingSimulator22_agiPack_*.exe"
#   ["claasSaddleTracPack"]="FarmingSimulator22_claasSaddleTracPack_*.exe"
#   ["eroPack"]="FarmingSimulator22_eroPack_*.exe"
#   ["extraContentVolvoLM845"]="FarmingSimulator22_extraContentVolvoLM845_*.exe"
#   ["forestryPack"]="FarmingSimulator22_forestryPack_*.exe"
#   ["goeweilPack"]="FarmingSimulator22_goeweilPack_*.exe"
#   ["hayAndForagePack"]="FarmingSimulator22_hayAndForagePack_*.exe"
#   ["kubotaPack"]="FarmingSimulator22_kubotaPack_*.exe"
#   ["vermeerPack"]="FarmingSimulator22_vermeerPack_*.exe"
#   ["pumpsAndHosesPack"]="FarmingSimulator22_pumpsAndHosesPack_*.exe"
#   ["horschAgrovation"]="FarmingSimulator22_horschAgrovation_*.exe"
#   ["oxboPack"]="FarmingSimulator22_oxboPack_*.exe"
#   ["premiumExpansion"]="FarmingSimulator22_premiumExpansion_*.exe"
#   ["farmProductionPack"]="FarmingSimulator22_farmProductionPack_*.exe"
# )

# # Map of DLCs and their installers
# declare -A dlcs=(
#   ["Antonio Carraro"]="antonioCarraroPack"
#   ["AGI Pack"]="agiPack"
#   ["CLAAS XERION SADDLE TRAC"]="claasSaddleTracPack"
#   ["Ero Pack"]="eroPack"
#   ["Volvo LM845"]="extraContentVolvoLM845"
#   ["Forestry Pack"]="forestryPack"
#   ["Goeweil Pack"]="goeweilPack"
#   ["Hay And Forage Pack"]="hayAndForagePack"
#   ["Kubota Pack"]="kubotaPack"
#   ["Vermeer Pack"]="vermeerPack"
#   ["Pumps And Hoses Pack"]="pumpsAndHosesPack"
#   ["Horsch AgroVation"]="horschAgrovation"
#   ["OXBO Pack"]="oxboPack"
#   ["Premium Expansion"]="premiumExpansion"
#   ["Farm Production Pack"]="farmProductionPack"
# )

# for dlc in "${!dlcs[@]}"; do
#   check_dlc_installer "$dlc" "${dlc_installer_patterns[${dlcs[$dlc]}]}"
# done

# it's important to check if the config directory exists on the host mount path. If it doesn't exist, create it.

if [ -d $DOCS_PATH ]; then
  echo -e "${GREEN}INFO: The host config directory exists, no need to create it!${NOCOLOR}"
else
  mkdir -p $DOCS_PATH
fi

# Symlink the host game path inside the wine prefix to preserve the installation on image deletion or update.

if [ -d "$GAME_PATH" ]; then
  ln -s "$GAME_PATH" "$FARMSIM_INSTALL"
else
  mkdir -p "$GAME_PATH" && ln -s "$GAME_PATH" "$FARMSIM_INSTALL"
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

if [ -f ~/Desktop/ ]
then
  rm -r "$DESKTOP_ICONS"
else
  echo -e "${GREEN}INFO: Nothing to cleanup!${NOCOLOR}"
fi

# Do we have a license file installed?

count=`ls -1 "$FARMSIM_DOCS/*.dat" 2>/dev/null | wc -l`
if [ $count != 0 ]
then
  echo -e "${GREEN}INFO: Generating the game license files as needed!${NOCOLOR}"
else
  wine "$FARMSIM_EXECUTABLE"
fi

count=`ls -1 "$FARMSIM_DOCS/*.dat" 2>/dev/null | wc -l`
if [ $count != 0 ]
then
  echo -e "${GREEN}INFO: The license files are in place!${NOCOLOR}"
else
  echo -e "${RED}ERROR: No license files detected, they are generated after you enter the product key during setup... most likely the setup is failing to start!${NOCOLOR}" && exit
fi

# Install DLC

# install_dlc() {
#   local dlc_name=$1
#   local exe_pattern=$2
#   local dlc_path="$FARMSIM_DOCS/pdlc/${dlc_name}.dlc"

#   if [ -f $dlc_path ]
#   then
#     echo -e "${GREEN}INFO: ${dlc_name} already exists!${NOCOLOR}"
#   else
#     if ls $DLC_PATH/${exe_pattern} 1> /dev/null 2>&1; then
#       echo -e "${GREEN}INFO: Installing ${dlc_name}!${NOCOLOR}"
#       for i in $DLC_PATH/${exe_pattern}; do wine "$i"; done
#       echo -e "${GREEN}INFO: ${dlc_name} is now installed!${NOCOLOR}"
#     fi
#   fi
# }

# # Recursively install the DLCs
# for dlc in ${!dlcs[@]}; do
#   check_dlc_installer "$dlc" "${dlc_installer_patterns[${dlcs[$dlc]}]}"
# done

# Check config if not exist then exit

if [ -f "$FARMSIM_DOCS/dedicated_server/dedicatedServerConfig.xml" ]
then
  echo -e "${GREEN}INFO: We can run the server now by clicking on 'Start Server' on the desktop!${NOCOLOR}"
else
  echo -e "${RED}ERROR: We are missing files?${NOCOLOR}" && exit
fi

echo -e "${YELLOW}INFO: Checking for updates, if you get warning about GPU drivers make sure to click no!${NOCOLOR}"
wine $FARMSIM_EXECUTABLE

echo -e "${YELLOW}INFO: All done, closing this window in 15 seconds...${NOCOLOR}"

exec sleep 15

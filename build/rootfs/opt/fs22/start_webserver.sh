#!/bin/bash

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/.fs_server
export WINEARCH=win64
export USER=nobody

# Debug error/reset color
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0;0m'

# Start the server

# Boot the wine prefix
wine wineboot

# Define the game installation directories on both the host and wine side
FARMSIM_INSTALL_HOST="/opt/fs22/game/Farming Simulator 2022"
FARMSIM_INSTALL_WINE="$WINEPREFIX/drive_c/Program Files (x86)/Farming Simulator 2022"
FARMSIM_DOCS_HOST="/opt/fs22/config/FarmingSimulator2022"
FARMSIM_DOCS_WINE="$WINEPREFIX/drive_c/users/$USER/Documents/My Games/FarmingSimulator2022"
FARMSIM_DEDI_SOFTWARE="$FARMSIM_INSTALL_WINE/dedicatedServer.exe"

# Check if the game install directory exists on the host side
if [ -d "$FARMSIM_INSTALL_HOST" ]; then
  ln -s "$FARMSIM_INSTALL_HOST" "$FARMSIM_INSTALL_WINE"
else
  echo -e "${RED}Error: Game installation directory does not exist on the host side, unable to create the symlink!${NOCOLOR}"
  exit 1
fi

# Symlink the game profile directory
if [ -d "$FARMSIM_DOCS_WINE" ]; then
  echo -e "${GREEN}INFO: The symlink is already in place, no need to create one!${NOCOLOR}"
else
  mkdir -p "$WINEPREFIX/drive_c/users/$USER/Documents/My Games" && ln -s "$FARMSIM_DOCS_HOST" "$FARMSIM_DOCS_WINE"
fi

# Copy webserver config..
if [ ! -f "$FARMSIM_INSTALL_WINE/dedicatedServer.xml" ]; then
  echo -e "${GREEN}INFO: Copying the webserver config!${NOCOLOR}"
  cp "/opt/fs22/xml/default_dedicatedServer.xml" "$FARMSIM_INSTALL_WINE/dedicatedServer.xml"
else
  echo -e "${GREEN}INFO: Webserver config already exists! Skipping..${NOCOLOR}"
fi

# Copy server config
if [ ! -f "$FARMSIM_DOCS_WINE/dedicated_server/dedicatedServerConfig.xml" ]; then
  echo -e "${GREEN}INFO: Copying the server config!${NOCOLOR}"
  cp "/opt/fs22/xml/default_dedicatedServerConfig.xml" "$FARMSIM_DOCS_WINE/dedicated_server/dedicatedServerConfig.xml"
else
  echo -e "${GREEN}INFO: Server config already exists! Skipping..${NOCOLOR}"
fi

# Check if the server software exists on the wine side
if [ -f "$FARMSIM_DEDI_SOFTWARE" ]; then
  wine "$FARMSIM_DEDI_SOFTWARE"
else
  echo -e "${RED}Error: Dediserver software does not exist on the wine side, unable to start the server!${NOCOLOR}"
  exit 1
fi

exit 0

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

# Boot the wine prefix
wine wineboot

# Define the game installation directories on both the host and wine side
FARMSIM_INSTALL_HOST="/opt/fs22/game"
FARMSIM_INSTALL_WINE="$WINEPREFIX/drive_c/Program Files (x86)/Farming Simulator 2022"
FARMSIM_DOCS_HOST="/opt/fs22/docs/FarmingSimulator2022"
FARMSIM_DOCS_WINE_PARENT="$WINEPREFIX/drive_c/users/$USER/Documents/My Games"
FARMSIM_DOCS_WINE="$FARMSIM_DOCS_WINE_PARENT/FarmingSimulator2022"
FARMSIM_DEDI_SOFTWARE="$FARMSIM_INSTALL_WINE/dedicatedServer.exe"
FARMSIM_DEDI_XML_HOST="/opt/fs22/xml"
HOST_LOGFOLDER="/opt/fs22/logs"

# Clear Tinyproxy log prior to starting the webinterface
echo -e "${GREEN}INFO: Clearing Tinyproxy log..${NOCOLOR}"
echo "" > $HOST_LOGFOLDER/tinyproxy.log

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
  mkdir -p "$FARMSIM_DOCS_WINE_PARENT" && ln -s "$FARMSIM_DOCS_HOST" "$FARMSIM_DOCS_WINE"
fi

# Copy webserver config..
if [ ! -f "$FARMSIM_INSTALL_WINE/dedicatedServer.xml" ]; then
  echo -e "${GREEN}INFO: Copying the webserver config!${NOCOLOR}"
  cp "$FARMSIM_DEDI_XML_HOST/default_dedicatedServer.xml" "$FARMSIM_INSTALL_WINE/dedicatedServer.xml"
else
  echo -e "${GREEN}INFO: Webserver config already exists! Skipping..${NOCOLOR}"
fi

# Copy server config
if [ ! -f "$FARMSIM_DOCS_WINE/dedicated_server/dedicatedServerConfig.xml" ]; then
  echo -e "${GREEN}INFO: Copying the server config!${NOCOLOR}"
  cp "$FARMSIM_DEDI_XML_HOST/default_dedicatedServerConfig.xml" "$FARMSIM_DOCS_WINE/dedicated_server/dedicatedServerConfig.xml"
else
  echo -e "${GREEN}INFO: Server config already exists! Skipping..${NOCOLOR}"
fi

# Check if the server software exists on the WINE side
if [ -f "$FARMSIM_DEDI_SOFTWARE" ]; then
  wine "$FARMSIM_DEDI_SOFTWARE"
else
  echo -e "${RED}Error: Dediserver software does not exist on the WINE side, unable to start the server!${NOCOLOR}"
  exit 1
fi

exit 0

# FarmSim Docker

### Usage/Deployment

You are free to choose any location to access your game directories from.  
We will be using `/opt/fs25` as the default path.

1. Obtain a copy of the game ([GIANTS eShop][giants-eshop])
   - Download the ZIP archive, not the `.iso` version.
2. Prepare directories on the host
   - 1. `$ sudo mkdir -p /opt/fs25/{docs,game,install,dlc,logs}`
   - 2. `$ sudo chown -R user:group /opt/fs25`
3. Obtain the UID and GID from `id` command (default is `1000`)
   - This is a requirement as you will be passing that to the [docker-compose.yml]
4. Move the downloaded contents (game, dlcs)
   - 1. Game installer contents can be moved to `/opt/fs25/install`
   - 2. DLC executables can be moved to `/opt/fs25/dlc`
5. Start the container after configuring your [docker-compose.yml] file
   - `$ docker compose up -d`
   - You may need to append `sudo` in front if the user is not part of the Docker group.
6. Connect to the container via port `5900` in your VNC client

>[!IMPORTANT]
You may need to delete the `dedicatedServer.xml` file that it generated on first launch and restart the panel.

>[!WARNING]
If you already had an existing installation, delete the symlinked folder (`game`) from inside your install folder (`/opt/fs25/game`) before updating the game!  
I also updated the [docker-compose.yml] file to directly mount host directory into the directory where game expects it to be, to hopefully prevent future issues.

# Reason for the fork

I wanted to clean up the mess in bash scripts and to make it easier to maintain, as well as strip any stuff that I find useless.

And to have an ability to launch the webinterface without running the setup script after container restart.

[docker-compose.yml]: ./docker-compose.yml
[giants-eshop]: https://www.farming-simulator.com/buy-now.php?platform=pcdigital

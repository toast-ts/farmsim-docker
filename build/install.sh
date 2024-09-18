#!/bin/bash

set -e

# needed packages

echo "[info] Installing packages currently not installed..."
pacman -Syu --noconfirm && pacman -S nginx-mainline --noconfirm

# Double check if it's installed, because sometimes
# it doesn't even install properly the first time
echo "[info] Checking if nginx is installed..."
if ! pacman -Qi nginx-mainline &>/dev/null; then
  echo "[info] Nginx is not even installed, trying again..."
  pacman -S nginx-mainline --noconfirm
else
  echo "[info] Nginx is already installed, skipping..."
fi

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh

# env vars
####

cat <<'EOF' > /tmp/envvars_heredoc

# Webserver

if [ -n "$WEB_USERNAME" ]; then
  sed -i "s/<username>admin<\/username>/<username>$WEB_USERNAME<\/username>/" /opt/fs22/xml/default_dedicatedServer.xml
fi

if [ -n "$WEB_PASSWORD" ]; then
  sed -i "s/<passphrase>password<\/passphrase>/<passphrase>$WEB_PASSWORD<\/passphrase>/" /opt/fs22/xml/default_dedicatedServer.xml
fi

EOF

# replace env vars placeholder string with contents of file (here doc)

sed -i '/# ENVVARS_PLACEHOLDER/{
    s/# ENVVARS_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /usr/local/bin/init.sh
rm /tmp/envvars_heredoc

# Symlinks

ln -s /opt/fs22/setup_giants.sh /home/nobody/setup_giants.sh
ln -s /opt/fs22/start_webserver.sh /home/nobody/start_webserver.sh

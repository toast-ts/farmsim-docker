#!/bin/bash

# exit script if return code != 0
set -e

# set arch for base image
OS_ARCH="x86-64"

# set locale

echo "[info] set locale..."
echo en_US.UTF-8 UTF-8 > '/etc/locale.gen'
locale-gen
echo LANG="en_US.UTF-8" > '/etc/locale.conf'

echo "[info] content of arch mirrorlist file"
cat '/etc/pacman.d/mirrorlist'

# Add multilib repository to run 32-bit applications on 64-bit installs

echo -e " \n\
[multilib] \n\
Include = /etc/pacman.d/mirrorlist \n\
" >> /etc/pacman.conf

echo "[info] Fixing filesystem permissions..."
chmod 755 /etc /usr

# initialise key for pacman

pacman-key --init

DEPENDENCIES=(
  # X11 and VNC
  xorg-server-xvfb
  x11vnc

  # Window Manager
  icewm
  pcmanfm

  # Essentials
  supervisor
  moreutils
  ttf-dejavu
  wine-staging
)
PACKAGE_LIST="${DEPENDENCIES[*]}"

echo "[info] Installing packages currently not installed..."
pacman -Syu --noconfirm && \
pacman -S ${PACKAGE_LIST} --noconfirm && \
pacman -Rns $(pacman -Qdtq) --noconfirm && \
pacman -Scc --noconfirm

# add user "nobody" to primary group "users" (will remove any other group membership)
usermod -g users nobody && \

# add user "nobody" to secondary group "nobody" (will retain primary membership)
usermod -aG nobody nobody && \

# setup env for user nobody
mkdir -p /home/nobody/Templates && \
chown -R nobody:users /home/nobody && \
chmod -R 775 /home/nobody && \

# set user "nobody" home directory (needs defining for pycharm, and possibly other apps)
usermod -d /home/nobody nobody && \

# set shell for user nobody
chsh -s /bin/bash nobody

# link .icewm to /usr/share/icewm
if [ -f /usr/share/icewm/preferences ] || [ -d /home/nobody/.icewm/preferences ]; then
  rm -rf /usr/share/icewm/preferences && \
  ln -sf /home/nobody/.icewm/preferences /usr/share/icewm/preferences
fi

# remove existing themes except default
for theme in $(ls /usr/share/icewm/themes | grep -v win95); do
  rm -rf /usr/share/icewm/themes/$theme
done

# container perms
####

# define comma separated list of paths
install_paths="/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/permissions_heredoc
# get previous puid/pgid (if first run then will be empty string)
previous_puid=\$(cat "/root/puid" 2>/dev/null || true)
previous_pgid=\$(cat "/root/pgid" 2>/dev/null || true)
# if first run (no puid or pgid files in /tmp) or the PUID or PGID env vars are different
# from the previous run then re-apply chown with current PUID and PGID values.
if [[ ! -f "/root/puid" || ! -f "/root/pgid" || "\${previous_puid}" != "\${PUID}" || "\${previous_pgid}" != "\${PGID}" ]]; then
	# set permissions inside container - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
	chown -R "\${PUID}":"\${PGID}" ${install_paths}
fi
# write out current PUID and PGID to files in /root (used to compare on next run)
echo "\${PUID}" > /root/puid
echo "\${PGID}" > /root/pgid
EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/local/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

cat <<'EOF' > /tmp/envvars_heredoc

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    export VNC_PASSWORD=
 else
    echo -n "winevnc" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    export VNC_PASSWORD=
fi

EOF

# replace env vars placeholder string with contents of file (here doc)
sed -i '/# ENVVARS_COMMON_PLACEHOLDER/{
    s/# ENVVARS_COMMON_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /usr/local/bin/init.sh
rm /tmp/envvars_heredoc

# clean up unnecessary files to cut Docker image size down (3447 MB before adding this)
rm -rf /var/cache/pacman/{pkg,sync}/* && \
rm -rf /tmp/* && \
rm -rf /var/tmp/* && \
rm -rf /usr/share/{man,doc}/* && \
rm -rf /root/.cache && \
rm -rf /home/nobody/.cache && \
find /usr/lib -type f -name '*.a' -delete && \
find /usr/lib -type f -name '*.la' -delete && \
find /usr/share/applications -type f -delete

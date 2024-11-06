FROM toetje585/arch-wine-vnc:latest
LABEL org.opencontainers.image.source="https://github.com/toast-ts/farmsim-docker"

COPY build/rootfs /
RUN chown -R nobody:nobody /home/*
COPY build/install.sh /root/install.sh

# Install script
RUN chmod +x /root/install.sh && /bin/bash /root/install.sh

# Expose port for webinterface
EXPOSE 8080/tcp
# Expose ports for the game
EXPOSE 10823/udp
EXPOSE 10823/tcp

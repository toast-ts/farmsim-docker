FROM toetje585/arch-wine-vnc:latest
LABEL org.opencontainers.image.authors = "Toetje585"
LABEL org.opencontainers.image.source = "https://github.com/wine-gameservers/arch-wine-vnc"

COPY build/rootfs /
RUN chown -R nobody:nobody /home/*
ADD build/install.sh /root/install.sh

# install script
##################
RUN chmod +x /root/install.sh && /bin/bash /root/install.sh

# Expose port for panel interface
EXPOSE 8080/tcp
# Expose port for the game
EXPOSE 10823/udp

FROM registry.access.redhat.com/ubi8/ubi:8.10

ENV NOVNC_DIR=/opt/novnc \
    NOVNC_PORT=8080 \
    VNC_DISPLAY=:1 \
    VNC_GEOMETRY=1280x800 \
    VNC_DEPTH=24 \
    VNC_PASSWORD=password \
    VNC_USER=vncuser

# Install TigerVNC server, basic X11 tools, and deps for noVNC
RUN microdnf install -y \
      tigervnc-server \
      xorg-x11-xauth \
      xorg-x11-fonts-Type1 \
      xterm \
      git \
      python3 \
      procps \
    && microdnf clean all

# Create a non-root user for running VNC
RUN useradd -m -s /bin/bash ${VNC_USER}

# Install noVNC + websockify
RUN git clone https://github.com/novnc/noVNC.git "${NOVNC_DIR}" \
    && git clone https://github.com/novnc/websockify.git "${NOVNC_DIR}/utils/websockify" \
    && ln -s vnc.html "${NOVNC_DIR}/index.html"

# VNC config: simple X startup script
USER ${VNC_USER}
RUN mkdir -p /home/${VNC_USER}/.vnc && \
    echo '#!/bin/sh\n' \
         'xterm &' \
         > /home/${VNC_USER}/.vnc/xstartup && \
    chmod +x /home/${VNC_USER}/.vnc/xstartup

USER root

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown ${VNC_USER}:${VNC_USER} /entrypoint.sh

EXPOSE 8080

# Run everything as the VNC user
USER ${VNC_USER}
WORKDIR /home/${VNC_USER}

ENTRYPOINT ["/entrypoint.sh"]

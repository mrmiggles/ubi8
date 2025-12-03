#!/usr/bin/env bash
set -e

NOVNC_DIR=${NOVNC_DIR:-/opt/novnc}
NOVNC_PORT=${NOVNC_PORT:-8080}
VNC_DISPLAY=${VNC_DISPLAY:-:1}
VNC_GEOMETRY=${VNC_GEOMETRY:-1280x800}
VNC_DEPTH=${VNC_DEPTH:-24}
VNC_PASSWORD=${VNC_PASSWORD:-password}

VNC_PORT_NUM=$(echo "${VNC_DISPLAY}" | sed 's/^://')
VNC_TCP_PORT=$((5900 + VNC_PORT_NUM))

echo "Configuring VNC password"
mkdir -p "${HOME}/.vnc"
# Create VNC password file
echo "${VNC_PASSWORD}" | vncpasswd -f > "${HOME}/.vnc/passwd"
chmod 600 "${HOME}/.vnc/passwd"

echo "Starting TigerVNC server on display ${VNC_DISPLAY} (${VNC_GEOMETRY}, depth ${VNC_DEPTH})"
vncserver "${VNC_DISPLAY}" -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}"

echo "Starting noVNC on 0.0.0.0:${NOVNC_PORT} -> VNC localhost:${VNC_TCP_PORT}"
cd "${NOVNC_DIR}"
exec ./utils/novnc_proxy \
  --listen "0.0.0.0:${NOVNC_PORT}" \
  --vnc "localhost:${VNC_TCP_PORT}"

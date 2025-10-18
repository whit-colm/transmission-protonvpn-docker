# Transmission + ProtonVPN Docker Setup

Runs Transmission behind ProtonVPN using Gluetun for VPN connectivity. All torrent traffic is routed through the VPN; web interfaces are only accessible from your LAN.

## Prerequisites

- Docker and docker-compose
- ProtonVPN account with port forwarding support (paid tier required for P2P)

## Setup

### 1. Generate WireGuard Credentials

[Generate a WireGuard configuration](https://account.proton.me/u/1/vpn/WireGuard) from your ProtonVPN account. Copy the `PrivateKey` value. See [Gluetun's ProtonVPN docs](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md) for details.

### 2. Configure Environment

Copy `.env.example` to `.env` and set the following:

```bash
WIREGUARD_PRIVATE_KEY="your_private_key_here"
SERVER_COUNTRIES="Mexico,Brazil,Switzerland"  # Comma-separated
SERVER_CITIES=""  # Optional, leave blank for any city
PUID=1000  # Your user ID (run `id -u`)
PGID=1000  # Your group ID (run `id -g`)
TZ=America/New_York
TMSN_TORRENTS_DIR=/path/to/downloads
TRANSMISSION_USER=admin
TRANSMISSION_PASS=your_password
LOCAL_NETWORK="192.168.1.0/24"  # Your LAN subnet
```

Note: `LOCAL_NETWORK` should match your actual LAN subnet. Check with `ip addr show`.

### 3. Start Services

```sh
docker-compose up -d
```

## Configuration

### Download Directory

All downloads go to a single directory specified by `TMSN_TORRENTS_DIR` in `.env`. The setup automatically disables Transmission's incomplete directory feature via the `transmission-settings.sh` script, which runs on container startup.

If you need to customize Transmission settings further, modify `transmission-settings.sh` or edit `/config/settings.json` manually (stop the container first).

### Network Sharing

To access downloads from other machines on your network, you can:
- Use NFS or SMB to share the `TMSN_TORRENTS_DIR` directory
- Access files directly on the host at the path specified in `.env`

## Accessing Downloads from Other Devices

The setup includes a WebDAV server for easy network file access. WebDAV provides a lightweight, browsable file share that works with most operating systems.

### Connecting from Linux (KDE Dolphin, GNOME Files, etc.)

1. Open your file manager
2. Connect to server:
   - **URL**: `webdav://your-server-ip:8080`
   - **Username**: From `TMSN_USER` in `.env`
   - **Password**: From `TMSN_PASS` in `.env`

**KDE Dolphin**: Location bar → `webdav://192.168.1.100:8080`

**GNOME Files**: Other Locations → Connect to Server → Enter WebDAV URL

### Connecting from Android

Use a file manager with WebDAV support:
- **Solid Explorer** (recommended)
- **Material Files**
- **FX File Explorer**

Configuration:
- **Protocol**: WebDAV
- **Host**: `192.168.1.100` (your server IP)
- **Port**: `8080`
- **Path**: `/`
- **Username/Password**: From your `.env` file

### Connecting from macOS

1. **Finder** → Go → Connect to Server (⌘K)
2. Enter: `http://your-server-ip:8080`
3. Authenticate with your credentials

### Why WebDAV?

- **Lightweight**: Minimal CPU/RAM on Raspberry Pi
- **No kernel modules**: Runs entirely in Docker
- **Universal**: Native support in most file managers
- **GUI-friendly**: Full browsing experience for non-technical users
- **Read-only**: Prevents accidental deletion/modification of downloads

Files are served read-only to prevent accidental changes. To manage downloads, use the Transmission web UI.

## Access

- **Transmission Web UI**: http://localhost:9091
  - Login with credentials from `.env` (TMSN_USER/TMSN_PASS)
- **Gluetun Control API**: http://localhost:8000
  - Provides VPN status and port forwarding info
- **WebDAV File Access**: http://localhost:8080
  - Browse and download torrented files
  - Same credentials as Transmission (TMSN_USER/TMSN_PASS)
  - Read-only access to prevent accidental file modifications

Both Transmission and Gluetun web interfaces are firewalled to LAN access only. They are not accessible from the VPN's public IP.

WebDAV is exposed on your LAN for easy file access from other devices.

## Network Security

The setup uses `network_mode: service:gluetun` for Transmission, forcing all traffic through the VPN. Gluetun's firewall:
- Blocks all incoming connections from the VPN interface except the forwarded torrent port
- Allows incoming connections from Docker networks and your LAN subnet (`FIREWALL_OUTBOUND_SUBNETS`)
- Web interfaces (ports 8000, 9091) are only accessible via localhost or LAN

This means:
- Web UIs cannot be accessed from the internet via the VPN IP
- Only authenticated LAN devices can manage the services
- Torrent traffic uses the VPN's forwarded port

## Troubleshooting

### Verify VPN Connection

```sh
# Check logs
docker logs gluetun

# Verify public IP is VPN (not your real IP)
docker exec gluetun wget -qO- https://ipinfo.io/ip

# Check forwarded port
docker exec gluetun cat /tmp/gluetun/forwarded_port
```

### 403 Forbidden on Web UI

Do not set `WHITELIST` environment variable in docker-compose.yaml. It conflicts with `network_mode: service:gluetun`. Access control is handled via HTTP authentication.

### Port Forwarding

ProtonVPN assigns a random port. The `transmission-port-update` container automatically configures Transmission to use this port. Check Transmission's settings or the forwarded port file to verify.

### Permission Errors

Ensure `PUID` and `PGID` in `.env` match your user (`id -u` and `id -g`). The download directory must be writable by this user.
# Transmission VPN Stack

Transmission torrent client behind ProtonVPN using Gluetun for VPN connectivity, with WebDAV file sharing. Designed for Raspberry Pi, home servers, or desktop deployment.

## Prerequisites

- Docker and docker-compose (works with both rootful and rootless Docker)
- ProtonVPN account with port forwarding support (paid tier required for P2P)

### Rootless Docker Support

This stack has been updated to improve rootless Docker compatibility, but there are important limitations:

- **UID/GID mapping**: In rootless Docker, containers run as your host user automatically. The `PUID` and `PGID` settings still work for the linuxserver/transmission image.
- **File permissions**: Ensure your `TMSN_TORRENTS_DIR` is writable by your user.
- **ulimits**: The default ulimits (1024/4096) match standard system defaults. Adjust based on your `ulimit -n -S` and `ulimit -n -H` values if needed.
- **VPN capabilities**: ⚠️ **VPN functionality may not work reliably in rootless Docker** due to `NET_ADMIN` and `/dev/net/tun` requirements. Rootful Docker is recommended if you need VPN features.

## Setup

### 1. Generate WireGuard Credentials

[Generate a WireGuard configuration](https://account.proton.me/u/1/vpn/WireGuard) from your ProtonVPN account. Copy the `PrivateKey` value. See [Gluetun's ProtonVPN docs](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md) for details.

### 2. Configure Environment

Copy `.env.example` to `.env` and set the following:

```ini
WIREGUARD_PRIVATE_KEY="your_private_key_here"
SERVER_COUNTRIES="United States,Canada,Mexico"        # Comma-separated
SERVER_CITIES="Phoenix,San Jose,Vancouver,Queretaro"  # Optional, leave blank for any city
PUID=1000                                             # Your user ID (run `id -u`)
PGID=1000                                             # Your group ID (run `id -g`)
                                                      # Note: Rootless Docker runs as your user automatically
TZ=America/New_York                                   # Used for Logging
TMSN_TORRENTS_DIR=/path/to/downloads                  # Torrents dir; no split incomplete/complete dirs.
AUTH_USER=admin                                       # Login details for BOTH transmission Web UI and WebDAV.
AUTH_PASS=your_password                               # Should be secure, though this is only ever accessed via LAN.
LOCAL_NETWORK="192.168.1.0/24"                        # Your LAN subnet
```

Note: `LOCAL_NETWORK` should match your actual LAN subnet. Check with `ip addr show`.

### 3. Start Services

```sh
docker-compose up -d
```

## Configuration

All downloads go to a single directory specified by `TMSN_TORRENTS_DIR` in `.env`. The setup automatically disables Transmission's incomplete directory feature via the `transmission-settings.sh` script, which runs on container startup.

If you need to customize Transmission settings further, modify `transmission-settings.sh` or edit `/config/settings.json` manually (stop the container first).

## Accessing Downloads from Other Devices

> [!CAUTION]
>
> This assumes everyone on your network is chill. It is not very secure and assumes you have the wherewithal to configure your home network securely.

The setup includes a WebDAV server for easy network file access. WebDAV provides a lightweight, browseable file share that works with most operating systems.

### Connecting from Linux (KDE Dolphin, GNOME Files, etc.)

1. Open your file manager
2. Connect to server:
   - **URL**: `webdav://your-server-ip:8080`
   - **Username**: From `TMSN_USER` in `.env`
   - **Password**: From `TMSN_PASS` in `.env`

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

## Access

- **Transmission Web UI**: http://localhost:9091
  - Login with credentials from `.env` (`TMSN_USER`/`TMSN_PASS`)
- **Gluetun Control API**: http://localhost:8000
  - Provides VPN status and port forwarding info
- **WebDAV File Access**: http://localhost:8080
  - Browse and download torrented files
  - Same credentials as Transmission (`TMSN_USER`/`TMSN_PASS`)
  - Read-only access to prevent accidental file modifications

Both Transmission and Gluetun web interfaces are firewalled to LAN access only. They are not accessible from the VPN's public IP.

WebDAV is exposed on your LAN for easy file access from other devices. WebDAV files are served read-only. To manage downloads, use the Transmission web UI.

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

**Rootless Docker specific**: If WebDAV isn't working, verify:
1. Your user has read access to `TMSN_TORRENTS_DIR`
2. The directory exists and has proper permissions: `chmod 755 /path/to/downloads`

### Rootless Docker: ulimit Errors

If you see errors like "cannot set ulimit" when starting:

```sh
# Check your current limits
ulimit -n -S  # Soft limit (typically 1024)
ulimit -n -H  # Hard limit (varies by system, e.g., 4096 on RPi4, 524288 on desktop)

# If the values in docker-compose.yaml exceed your limits:
# 1. Lower the ulimits to match your system's limits, or
# 2. Comment out the ulimits section entirely (Docker will use defaults)
# 3. To increase your user's limits, edit /etc/security/limits.conf (requires root)
```

### Rootless Docker: VPN Not Working

**Important**: VPN containers like Gluetun require `NET_ADMIN` capability and access to `/dev/net/tun`, which have significant limitations in rootless Docker:

- Rootless Docker cannot grant `NET_ADMIN` capability without additional system configuration
- `/dev/net/tun` access requires the device to be available in the user namespace
- Most VPN containers are designed for rootful Docker

**Possible workarounds** (advanced setup required):
1. Configure your system to allow rootless containers to access `/dev/net/tun`
2. Use `--device-cgroup-rule` with proper permissions
3. Consider using rootful Docker for VPN containers (more straightforward)

If VPN still fails, check:
```sh
# Verify your rootless Docker setup
systemctl --user status docker

# Check if you can access /dev/net/tun
ls -l /dev/net/tun
```

**Note**: This stack may have fundamental compatibility issues with rootless Docker when VPN functionality is required. If you encounter persistent VPN issues, rootful Docker is recommended for this use case.
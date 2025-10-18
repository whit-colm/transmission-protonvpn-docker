# Fixes Applied to Transmission + ProtonVPN Docker Setup

## Issues Diagnosed and Fixed

### 1. **403 Forbidden Error - ROOT CAUSE**
**Problem**: The `WHITELIST` environment variable in Transmission was causing 403 errors when using `network_mode: service:gluetun`.

**Why it happened**: When Transmission shares the network stack with Gluetun (`network_mode: service:gluetun`), incoming requests from localhost appear to come from Docker's internal bridge network (172.20.0.0/16) rather than your local network (10.32.0.0/24). This confused the RPC whitelist mechanism.

**Solution**: 
- Removed the `WHITELIST` environment variable entirely
- Transmission now relies on username/password authentication instead of IP whitelisting
- This is actually more secure and works reliably with the shared network mode

### 2. **Environment Variable Conflict**
**Problem**: The `.env` file had `USER=admin` but the container was using `USER=colm` (your system username).

**Why it happened**: `USER` is a reserved Linux environment variable. Docker Compose was picking up your system's `$USER` instead of the one in `.env`.

**Solution**:
- Renamed environment variables from `USER`/`PASS` to `TRANSMISSION_USER`/`TRANSMISSION_PASS`
- Updated both `docker-compose.yaml` and `.env` files
- Updated the `transmission-port-update` container configuration

### 3. **Missing Directories**
**Problem**: Transmission complained about missing `/downloads/complete` and `/downloads/incomplete` directories.

**Solution**: Created the directories at `/home/colm/Downloads/torrents/complete` and `/home/colm/Downloads/torrents/incomplete`

### 4. **Missing Configuration Variable**
**Problem**: Docker Compose warned about missing `SERVER_CITIES` variable.

**Solution**: Added `SERVER_CITIES=""` to `.env` and `.env.example`

### 5. **Outdated Documentation**
**Problem**: README.md still referenced qBittorrent and had incorrect port/access information.

**Solution**: 
- Updated README with correct Transmission information
- Added troubleshooting section
- Documented both Transmission (port 9091) and Gluetun (port 8000) access

## Current Working Configuration

### Access Information
- **Transmission Web UI**: http://localhost:9091
  - Username: admin (from TRANSMISSION_USER in .env)
  - Password: antiqua (from TRANSMISSION_PASS in .env)
  
- **Gluetun Control Server**: http://localhost:8000
  - Provides VPN status and port forwarding info

### VPN Status
- Connected via WireGuard to ProtonVPN
- Port forwarding enabled (random port assigned by ProtonVPN)
- Automatically updates Transmission's listening port

### Files Modified
1. `docker-compose.yaml` - Fixed WHITELIST issue, updated env variable names
2. `.env` - Added SERVER_CITIES, renamed USER/PASS variables
3. `.env.example` - Updated with correct variable names and documentation
4. `README.md` - Complete rewrite with accurate information

## How to Use Going Forward

1. **Access Transmission**: Open http://localhost:9091 in your browser
2. **Login**: Use the credentials from your `.env` file
3. **Check VPN**: Run `docker logs gluetun` to verify VPN connection
4. **Check Port**: Run `docker exec gluetun cat /tmp/gluetun/forwarded_port` to see your forwarded port

## Important Notes

- Do NOT add the `WHITELIST` environment variable back - it breaks localhost access with `network_mode: service:gluetun`
- Keep your TRANSMISSION_USER and TRANSMISSION_PASS secure
- The port forwarding is automatic - ProtonVPN assigns a random port and the port-update container keeps Transmission in sync

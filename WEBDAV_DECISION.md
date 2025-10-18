# File Sharing Solution: WebDAV

## Decision: hacdias/webdav

**Chosen**: `hacdias/webdav:latest` - A modern, actively maintained WebDAV server written in Go

### Why WebDAV over alternatives?

**Requirements**:
- Lightweight (Raspberry Pi 4)
- LAN-only access
- Linux/Android/macOS native file manager support
- GUI-friendly for non-technical users
- No Windows requirement

**Alternatives Considered**:

1. **NFS** - Rejected
   - Poor Android support
   - Requires kernel modules on host
   - Overkill for casual browsing

2. **SMB/Samba** - Rejected
   - Heavy resource usage (~100MB RAM idle)
   - Windows-centric design
   - Unnecessary complexity

3. **SFTP** - Rejected
   - Requires SSH daemon
   - Less seamless GUI integration
   - Authentication complexity

4. **WebDAV** - ✓ Chosen
   - **Lightweight**: ~10MB RAM, single Go binary
   - **Native support**: Built into KDE Dolphin, GNOME Files, macOS Finder
   - **Android**: Supported by Solid Explorer, Material Files, FX
   - **No daemons**: Pure Docker, no host modifications
   - **HTTP-based**: Simple, debuggable protocol
   - **Read-only**: Prevents accidental file deletion

### Why hacdias/webdav specifically?

**Alternatives**:
- `bytemark/webdav` - 7 years old, unmaintained
- Custom lighttpd/nginx - Unnecessary complexity, more attack surface

**hacdias/webdav**:
- **Active**: Updated yesterday (v5.8.1 as of Oct 2025)
- **Lightweight**: 4.8MB compressed image, Go binary
- **Secure**: Config-file based, supports bcrypt passwords
- **Flexible**: YAML/JSON/TOML config, per-user permissions
- **Rootless-capable**: Runs as specified UID/GID
- **Well-documented**: Clear examples, 4.8k stars

## Configuration

The setup uses a minimal YAML config (`webdav-config.yml`):
- Port 8080
- Read-only permissions
- Credentials from environment variables
- Runs as PUID/PGID from `.env`

## Usage

From Linux file managers (Dolphin, Nautilus, etc.):
```
webdav://your-server-ip:8080
```

Username/password: Same as Transmission (TMSN_USER/TMSN_PASS)

Files are mounted read-only to prevent accidental modification. Use Transmission web UI to manage downloads.

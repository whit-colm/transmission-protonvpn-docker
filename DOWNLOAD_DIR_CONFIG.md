# Download Directory Configuration

## What Changed

Configured Transmission to use a single download directory instead of separate "complete" and "incomplete" directories.

## Implementation

### Files Added
- `transmission-settings.sh` - Custom init script that runs on container startup
  - Waits for Transmission to create its initial `settings.json`
  - Modifies settings to:
    - Set `download-dir` to `/downloads` (instead of `/downloads/complete`)
    - Set `incomplete-dir-enabled` to `false`

### docker-compose.yaml Changes
Added volume mount for the custom init script:
```yaml
volumes:
  - ./transmission-settings.sh:/custom-cont-init.d/transmission-settings.sh:ro
```

The LinuxServer Transmission image automatically executes scripts in `/custom-cont-init.d/` during container initialization, before Transmission daemon starts.

## Why This Approach?

1. **Declarative**: Configuration is in version control, not manual steps
2. **Automatic**: Applies on every container restart
3. **Portable**: Works on any deployment of this setup
4. **Extensible**: Easy to add more Transmission settings customizations

## Result

All downloads now go directly to the directory specified by `TMSN_TORRENTS_DIR` in `.env`. No subdirectories for incomplete/complete downloads.

This makes it simpler to share the download directory via NFS/SMB or access files from other services.

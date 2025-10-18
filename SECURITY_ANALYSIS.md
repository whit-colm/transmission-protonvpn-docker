# Network Security Analysis

## Question 1: Are web ports accessible only from LAN?

**Answer: YES**

### Evidence from iptables

The gluetun container's firewall (iptables) has these INPUT rules:

```
Chain INPUT (policy DROP)
 - ACCEPT from lo (localhost)
 - ACCEPT ESTABLISHED/RELATED connections
 - ACCEPT from eth0 source 172.20.0.0/16 (Docker bridge)
 - ACCEPT from tun0 only for port 61943 (forwarded torrent port)
```

**Key findings:**
- Default policy: DROP (deny all unless explicitly allowed)
- Ports 8000 and 9091 have NO rules allowing INPUT from `tun0` (VPN interface)
- Only the forwarded torrent port (61943 in this case) accepts connections from tun0
- Web services are accessible only via:
  - Docker bridge network (172.20.0.0/16)
  - Your LAN via Docker's port mapping (which appears to come from the bridge)

### What FIREWALL_OUTBOUND_SUBNETS Does

`FIREWALL_OUTBOUND_SUBNETS=10.32.0.0/24` controls OUTBOUND routing and firewall:
- Allows containers to send traffic TO your LAN subnet
- Adds OUTPUT firewall rules and routing entries
- Does NOT directly control incoming connections to services

The INPUT firewall protection is implicit - Gluetun only allows INPUT from:
1. Docker's internal network
2. Your LAN (via the Docker host's port mapping)

### Verification

Services listen on `0.0.0.0` (all interfaces):
```
tcp  0.0.0.0:9091  (Transmission)
tcp  :::8000        (Gluetun control)
```

But the firewall prevents external access via the VPN IP.

## Question 2: Does password strength matter on a trusted LAN?

### Technical Answer

If your LAN is genuinely trusted (no malicious actors), then network-level access control is sufficient. A weak password would technically work.

### Practical Considerations

Even on "trusted" LANs, consider:

1. **Guest WiFi** - Do you have guests who connect to your network?
2. **IoT Devices** - Compromised smart home devices could probe your network
3. **Physical Access** - Anyone with physical access to your network can connect
4. **Lateral Movement** - If one device is compromised, attackers pivot to others
5. **Defense in Depth** - Security layers are redundant by design
6. **Credential Reuse** - Weak passwords might be reused elsewhere

### Recommendation

Use a strong password anyway. It's zero cost and provides defense in depth. The authentication protects against:
- Compromised devices on your LAN
- Mistakes in firewall configuration
- Future network topology changes
- Accidental exposure (e.g., if you later add external access)

## Summary

1. **Web ports ARE isolated from VPN access** - Gluetun's firewall blocks them
2. **LAN-only access IS enforced** - Via Docker networking and iptables
3. **Strong passwords are still recommended** - Defense in depth, even on trusted LANs

The network isolation is solid, but don't rely on it exclusively.

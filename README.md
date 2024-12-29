# Smarthome

## Design

### Networking

```mermaid
flowchart TD

  W[Wifi] --> RX[Router X]
  W --> N100
  W --> NAS
  W --> NUC[Intel NUC]
  RX --> HUE[Philip HUE]
  RX --> PC
```

### Compute

- N100 running Proxmox
  - HAOS with addons (containers)
- Intel NUC running docker containers

### Services

### DNS

- DHCP at Wifi serves 2 custom DNS
  - provided by Adguard Home
  - lives at N100 (primary) / Intel NUC (secondary)
  - synchronized using [Adguard Home Sync](https://github.com/bakito/adguardhome-sync)
- DNS MIM
  - DNS must override budabuda.duckdns.org A records with local IP, but allow forwarding of TXT records to upstream (for ACME DNS challenge)
- upstream 

```mermaid
flowchart TD

  DNS1[DNS @N100]
  DNS2[DNS @NUC]

  RESPECT{Client respects DHCP provided DNS}

  DNSD[Override destination DNS at Wifi using DNS Director]

  START@{ shape: sm-circ, label: "Small start" }
  DNS12{Is primary DNS available?}
  
  START --> RESPECT
  RESPECT -- yes --> DNS12
  RESPECT -- no --> DNSD
  DNSD --> DNS12
  DNS12 -- yes --> DNS1
  DNS12 -- no --> DNS2
  CDNS{is Custom FQDN like hass.svc.local}
  DNS1 --> CDNS
  DNS2 --> CDNS
  
  LRESOLVE[Resolve localy]
  WRESOLVE[Resolve at Wifi from DHCP information]
  UDNS[Resolve at Upstream DNS]

  DHCPDNS{is hostname from DHCP / IP address}
  CDNS -- yes --> LRESOLVE
  CDNS -- no --> DHCPDNS

  DHCPDNS -- yes --> WRESOLVE
  DHCPDNS -- no --> UDNS

```

### HTTP Load Balancing

### Monitoring

### Backup

## Setup

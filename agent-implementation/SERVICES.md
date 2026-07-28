# Services — Current to K8s Migration

## Current Services

| Service | Current | K8s Target | Scale-to-Zero | Notes |
|---------|---------|------------|---------------|-------|
| Netbird | systemd/Docker | K8s DaemonSet or extension | No | Always-on connectivity |
| Blocky | Docker | K8s Deployment (2 replicas) | No | DNS must always be up |
| Uptime Kuma | Docker | K8s Deployment | No | Monitoring, always-on |
| Duplicati | Docker | REMOVED | — | Replaced by Longhorn native |
| Mosquitto | Docker | K8s Deployment | No | MQTT broker, always-on |
| Music Assistant | Docker | K8s Deployment | Yes (KEDA) | USB DAC passthrough to K8s node|
| Squeezelite | systemd | K8s or systemd fallback | Yes (KEDA - same group as Music Assistant) | Depends on DAC path |
| *arr suite | Docker | K8s Deployment | No | sonarr, radarr, etc. |
| Authelia | Docker | K8s Deployment | No | SSO, always-on |
| Caddy | Docker | REMOVED | — | Replaced by Cilium Gateway API |
| Watchtower | Docker | REMOVED | — | ArgoCD handles updates |
| Sablier | Docker | REMOVED | — | KEDA handles scale-to-zero |
| Dockmon | Docker | REMOVED or DaemonSet | — | See analysis below |
| Glances | Docker | K8s DaemonSet | No | Read by Home Assistant |
| Heimdall | Docker | K8s Deployment | No | Dashboard, always-on |
| Immich | Docker | K8s Deployment | No | Photo management, heavy |
| Internet checker | Docker | K8s CronJob or Deployment | — | Pings 1.1.1.1, sends MQTT |
| Jellyfin | Docker | K8s Deployment | No | Media server, Intel GPU |
| Ombi | Docker | K8s Deployment | Yes (KEDA) | Media requests |
| MeTube | Docker | K8s Deployment | Yes (KEDA) | YouTube downloader |
| netbird ping | Docker | K8s Deployment | No | Connectivity monitoring |
| Node-RED | Docker | K8s Deployment | No | Flow automation, always-on |
| SFTPGo | Docker | K8s Deployment | No | SFTP server, always-on |
| SSHwifty | Docker | K8s Deployment | Yes (KEDA) | Web SSH client |

## Service Analysis

### Dockmon — NOT RECOMMENDED for K8s

Dockmon monitors Docker containers on standalone Docker hosts. It requires
Docker socket access and is designed for Docker Compose environments.
In a K8s cluster, pods are managed by the kubelet, not Docker daemon.
Dockmon cannot monitor K8s pods.

**Options:**
- **Remove entirely** — K8s self-healing + ArgoCD replaces the need
- **Keep on Proxmox host** — only if monitoring Docker containers on
  the Proxmox host itself (outside K8s)
- **Replace with K8s-native tool** — ArgoCD + pod health checks cover this

**Recommendation**: Remove. K8s + ArgoCD handles container lifecycle.

### Glances — DaemonSet with host access

Glances provides system metrics (CPU, memory, disk, network, temperature)
to Home Assistant via its REST API. In K8s it needs host-level access.

**K8s requirements:**
- `hostPID: true` — to read process info
- `hostNetwork: true` — to read network stats
- `hostPath` mounts for `/proc`, `/sys`, `/etc/os-release`
- Runs as DaemonSet (one per node)
- Home Assistant connects via `http://<node-ip>:61208`

**Alternative**: Use `prometheus-node-exporter` + Home Assistant's
Prometheus integration (more standard, but adds Prometheus dependency).

### Immich — Official Helm chart, heavy

Immich is a self-hosted photo/video backup (Google Photos alternative).

**K8s requirements:**
- Official Helm chart: `oci://ghcr.io/immich-app/immich-charts/immich`
- PostgreSQL with vectorchord extension (use cloudnative-pg)
- Redis (can be enabled in chart values)
- PersistentVolume for photo library (Longhorn)
- Resource-heavy: 2-4 GB RAM recommended
- GPU optional (for ML face recognition, not required)

**Storage**: Needs significant Longhorn storage for photo library.
Consider dedicating a Longhorn volume or using NFS mount for media.

### Jellyfin — Intel GPU transcoding

Jellyfin is a media server (Plex alternative). N100 has Intel UHD GPU
which supports hardware transcoding via QSV/VA-API.

**K8s requirements:**
- Helm chart: `djjudas21/jellyfin`
- Intel GPU device plugin: `intel/intel-device-plugins-gpu`
- `/dev/dri/renderD128` device access
- PersistentVolume for config + media library
- `strategy: Recreate` (SQLite, single replica only)
- Resource requests: 1 CPU, 1 GB RAM minimum; 4 CPU, 4 GB with transcoding

**GPU on Talos**: The `siderolabs/qemu-guest-agent` extension is included.
Intel GPU passthrough from Proxmox to Talos VM requires:
1. Proxmox: pass through `/dev/dri` to Talos VM
2. Talos: Intel GPU device plugin installed in K8s
3. Jellyfin: request `gpu.intel.com/i915: "1"`

**Note**: GPU passthrough through Proxmox → Talos VM → K8s pod is
complex. May need to test feasibility. Fallback: CPU-only transcoding.

### Internet Checker — lightweight CronJob or Deployment

Custom script that pings 1.1.1.1 and publishes result via MQTT.

**K8s options:**
- **CronJob**: Run every 5 minutes, ping, publish to Mosquitto
- **Deployment**: Always running, periodic ping + MQTT publish
- Needs `netAdmin` capability for ICMP (or use `curl`/HTTP health check)

**Simpler alternative**: Use Uptime Kuma to monitor internet connectivity
(via external ping or HTTP check to 1.1.1.1). Eliminates custom script.

### MeTube — simple Deployment

YouTube downloader web UI. Lightweight, stateful (downloaded files).

**K8s requirements:**
- Deployment with PVC for downloads directory
- Ingress via Cilium Gateway API
- Scale-to-zero OK via KEDA (no active downloads = safe to stop)

### Node-RED — always-on automation

Flow-based automation tool. Always-on if controlling smart home.

**K8s requirements:**
- Deployment with PVC for flows storage
- Ingress via Cilium Gateway API
- May need MQTT integration (connect to Mosquitto)
- Resource-light: 256 MB RAM, 0.25 CPU

### Ombi — media request management

Web UI for users to request movies/TV shows. Integrates with *arr suite.

**K8s requirements:**
- Deployment with PVC for config
- Ingress via Cilium Gateway API
- Scale-to-zero OK via KEDA (requests queue when inactive)
- Resource-light: 512 MB RAM

### SFTPGo — SFTP server

Web-based SFTP server with user management.

**K8s requirements:**
- Deployment with PVC for served files
- LoadBalancer service (SFTP port 22) or NodePort
- Ingress for web UI via Cilium Gateway API
- Always-on if used for file transfers
- Resource-light: 256 MB RAM

### SSHwifty — web SSH client

Browser-based SSH client. No server-side state.

**K8s requirements:**
- Deployment (no PVC needed)
- Ingress via Cilium Gateway API
- Scale-to-zero OK via KEDA (no active sessions = safe to stop)
- Resource-light: 128 MB RAM

### netbird ping — connectivity monitoring

Monitors Netbird VPN connectivity. Lightweight.

**K8s requirements:**
- Deployment or DaemonSet
- Needs network access to Netbird peers
- Publishes metrics or logs connectivity status
- Resource-light: 128 MB RAM

## K8s Namespace Layout

```
kube-system        Cilium, kube-vip, CoreDNS
longhorn-system    Longhorn storage
cert-manager       TLS certificate management
argocd             ArgoCD + SOPS-age operator
ingress            Cilium Gateway API
dns                Blocky
monitoring         Uptime Kuma, Glances
home               Music Assistant, Mosquitto, Node-RED
media              Jellyfin, Immich, arr suite, Ombi, MeTube
apps               Paperless, SSHwifty, SFTPGo
auth               Authelia
vpn                Netbird, netbird-ping
keda               KEDA operator
```

## Monitoring

Minimal monitoring via Uptime Kuma + Glances:
- **Uptime Kuma**: HTTP/HTTPS/TCP endpoint checks, notifications
- **Glances**: System metrics (CPU, memory, disk, network) read by Home Assistant

No kube-prometheus-stack (too resource-heavy for 2-node homelab).

## USB DAC Passthrough

The USB DAC is physically connected to the N100 and passed through
directly to the Talos CP VM (not HAOS). Music Assistant runs in K8s
with nodeSelector targeting the CP node and device access via
hostPath or USB device plugin.

## Migration Priority

1. **Phase 1**: Core infra (Cilium, Longhorn, ArgoCD)
2. **Phase 2**: Always-on services (Blocky, Authelia, Mosquitto, Netbird, Node-RED, SFTPGo)
3. **Phase 3**: Monitoring (Uptime Kuma, Glances)
4. **Phase 4**: Media stack (Jellyfin, Immich, arr suite, Ombi, MeTube)
5. **Phase 5**: Utility apps (SSHwifty, Internet checker, netbird-ping)
6. **Phase 6**: Scale-to-zero apps (Music Assistant, Paperless, KEDA tuning)

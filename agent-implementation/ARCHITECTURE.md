# Architecture Decisions

## Decision Log

### D01: Hypervisor — Proxmox on both nodes

- **Choice**: Proxmox VE on N100 and NUC
- **Rejected**: Bare-metal Talos (loses HAOS flexibility)
- **Rationale**: HAOS needs Proxmox VM, IaC via bpg/proxmox provider

### D02: Kubernetes OS — Talos Linux

- **Choice**: Talos as Proxmox VMs
- **Rejected**: k3s (less immutable), vanilla Ubuntu (too much config drift)
- **Rationale**: Immutable, API-driven, purpose-built for K8s

### D03: Cluster size — 2 nodes (1 CP + 1 Worker)

- **Choice**: Single control plane + single worker
- **Accepted risk**: etcd single-point-of-failure
- **Rationale**: Hardware constraints, homelab tolerates this

### D04: CNI — Cilium

- **Choice**: Cilium with kube-proxy replacement
- **Rejected**: Calico, Flannel
- **Rationale**: eBPF performance, built-in L2 announcements, Hubble observability

### D05: Load balancing — Cilium L2 (NOT MetalLB)

- **Choice**: CiliumLoadBalancerIPPool + CiliumL2AnnouncementPolicy
- **Rejected**: MetalLB (redundant with Cilium)
- **Rationale**: One less component, same functionality, integrated with CNI

### D06: API VIP — kube-vip

- **Choice**: kube-vip DaemonSet for API server VIP (192.168.1.200)
- **Rejected**: Direct CP node IP (no failover path)
- **Rationale**: Works before Cilium installs, future-proofs for 2nd CP

### D07: Ingress — Cilium Gateway API with ExternalAuth (NOT Traefik)

- **Choice**: Cilium's built-in Gateway API + ExternalAuth filter (GEP-1494)
- **Rejected**: Traefik (extra component), nginx-ingress (legacy Ingress)
- **Rationale**: Cilium 1.20+ supports ExternalAuth on HTTPRoutes, mapping directly
  to Envoy's ext_authz protocol. Authelia has a dedicated `/api/authz/ext-authz`
  endpoint for this. No separate ingress controller needed. One less DaemonSet.
  **Note**: Cilium 1.20.0-rc.0 had a bug (ExternalAuth fails open). Fixed in rc.1+.

### D07a: Forward Auth — Authelia via ExternalAuth filter

- **Choice**: Authelia integrated via HTTPRoute ExternalAuth filter
- **Rejected**: Traefik ForwardAuth middleware (requires Traefik), custom sidecar
- **Rationale**: Each HTTPRoute can reference Authelia's ext-authz endpoint.
  Unauthenticated users get redirected to Authelia login. Authenticated requests
  pass through with `Remote-User`, `Remote-Groups`, `Remote-Email` headers.
  Works at the Gateway API level, no ingress controller dependency.

### D08: Storage — Longhorn

- **Choice**: Longhorn with 1 replica + backup to Synology NFS
- **Rejected**: Rook-Ceph (too heavy for 2 nodes), NFS as primary
- **Rationale**: K8s-native, incremental backups, Rancher-backed

### D09: Secrets — SOPS + age

- **Choice**: SOPS encryption with age keys, Git-committed encrypted files
- **Rejected**: Sealed Secrets (complex), Vault (overkill for homelab)
- **Rationale**: Simple, no additional infrastructure, widely supported

### D10: GitOps — ArgoCD

- **Choice**: ArgoCD with App of Apps pattern
- **Rejected**: FluxCD (less UI), manual kubectl
- **Rationale**: Visual dashboard, self-healing, well-documented

### D11: Scale-to-zero — KEDA

- **Choice**: KEDA ScaledObjects for intermittent workloads
- **Rejected**: Knative (too complex), HPA scale-to-zero (alpha in 1.36, limited)
- **Rationale**: HTTP triggers, cron support, simpler than HPA+Prometheus adapter

### D12: Infrastructure provisioning — OpenTofu + silvemerson module

- **Choice**: silvemerson/talos-linux-cluster/proxmox module
- **Rejected**: Manual VM creation, haferbeck module (too opinionated)
- **Rationale**: Handles ISO download, machineconfig, VM creation, bootstrap

### D13: Backup — Longhorn native (NOT Duplicati)

- **Choice**: Longhorn RecurringJobs to NFS to Synology
- **Rejected**: Duplicati (K8s-native preferred), Velero (overkill)
- **Rationale**: Built-in incremental backups, retention policies, no extra tool

### D14: Monitoring — Uptime Kuma + Glances (NOT kube-prometheus-stack)

- **Choice**: Uptime Kuma for endpoint checks + Glances for system metrics
- **Rejected**: kube-prometheus-stack (too resource-heavy for 2-node homelab)
- **Rationale**: Lightweight, sufficient for homelab. Glances provides CPU/memory/disk
  metrics to Home Assistant. Uptime Kuma handles endpoint monitoring + alerts.

### D15: USB DAC — passthrough to K8s (NOT HAOS)

- **Choice**: USB DAC passed through to Talos CP VM, Music Assistant in K8s
- **Rejected**: HAOS VM passthrough (user preference), systemd fallback
- **Rationale**: Centralize workloads in K8s, Talos has usb-audio-drivers extension

### D16: Talos interface naming — LinkAliasConfig

- **Choice**: LinkAliasConfig to alias NIC to `net0`
- **Rejected**: MAC-based naming (unstable for Cilium L2), `net.ifnames=0`
- **Rationale**: Talos uses MAC-based interface names by default, which breaks
  Cilium L2 announcements. LinkAliasConfig provides a stable name.

### D17: Dockmon — REMOVED

- **Choice**: Remove Dockmon entirely
- **Rejected**: Running Dockmon in K8s (defeats purpose — monitors Docker, not K8s)
- **Rationale**: Dockmon monitors Docker containers on standalone Docker hosts.
  In K8s, ArgoCD + pod health checks + kubelet handle container lifecycle.
  No Docker daemon to monitor in a Talos cluster.

### D18: Glances — DaemonSet with host access

- **Choice**: Glances as DaemonSet, read by Home Assistant
- **Rejected**: Prometheus node-exporter (adds Prometheus dependency)
- **Rationale**: Glances provides system metrics to Home Assistant via REST API.
  Needs hostPID, hostNetwork, hostPath mounts for /proc, /sys.
  Runs on each node, HA reads from node IP.

### D19: Jellyfin — Intel GPU transcoding

- **Choice**: Jellyfin with Intel GPU device plugin for QSV transcoding
- **Rejected**: CPU-only transcoding (wastes CPU on N100)
- **Rationale**: N100 has Intel UHD GPU supporting QSV/VA-API. GPU passthrough
  from Proxmox → Talos VM → K8s pod via intel-device-plugins-gpu.
  Single replica (SQLite), strategy: Recreate.

### D20: Immich — official Helm chart

- **Choice**: Immich via official Helm chart with cloudnative-pg
- **Rejected**: Manual deployment (complex dependencies)
- **Rationale**: Official chart handles PostgreSQL (with vectorchord), Redis,
  server, microservices. Needs significant Longhorn storage for photo library.

## Component Dependency Graph

```
Proxmox (IaC)
  └── Talos VMs (OpenTofu)
       └── kube-vip (API VIP, before CNI)
            └── Cilium (CNI + kube-proxy + L2 LB + Gateway API)
                 └── Longhorn (storage)
                 └── cert-manager (TLS)
                 └── ArgoCD (GitOps)
                      └── All applications
```

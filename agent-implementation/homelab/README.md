# budabuda-k8s — Near-Zero-Toil Kubernetes Homelab

Two-node Kubernetes cluster on Proxmox VMs with Talos Linux, Cilium, Longhorn, and ArgoCD GitOps.

## Hardware

| Node | CPU | RAM | Disk | Role | OS |
|------|-----|-----|------|------|----|
| N100 | 4C N100 | 16GB | 1TB SSD | Control Plane + HAOS VM | Proxmox → Talos VM |
| NUC | 4C i5 | 16GB | 100GB SSD | Worker | Proxmox → Talos VM |
| Synology | — | — | spinning | NFS backup | DSM |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Cilium Gateway API                       │
│                  *.budabuda-k8s.duckdns.org                   │
├─────────────────────────────────────────────────────────────┤
│  ExternalAuth (GEP-1494) → Authelia forward auth             │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│ Jellyfin │ Heimdall │ Paperless│ SFTPGo   │ ... (24 apps)  │
├──────────┴──────────┴──────────┴──────────┴────────────────┤
│              Cilium (CNI + L2 LB + Gateway API)              │
├─────────────────────────────────────────────────────────────┤
│              Longhorn (1 replica + NFS backup)               │
├──────────────────────┬──────────────────────────────────────┤
│   Talos CP (N100)    │    Talos Worker (NUC)                │
│   kube-vip (.200)    │                                      │
│   USB DAC passthrough│                                      │
├──────────────────────┴──────────────────────────────────────┤
│                    Proxmox (both nodes)                      │
└─────────────────────────────────────────────────────────────┘
```

## IP Allocation

```
192.168.1.0/24

.10     Synology NAS (NFS)
.200    API VIP (kube-vip, ARP)
.201    Blocky DNS (LoadBalancer)
.202    Cilium Gateway (HTTPS)
.203-209  Future services
.210    Talos CP (N100)
.211    Talos Worker (NUC)
```

## Prerequisites

Install these on your workstation:

```bash
# OpenTofu (Terraform-compatible IaC)
brew install opentofu
# or: https://opentofu.org/docs/intro/install/

# Talosctl
brew install siderolabs/tap/talosctl

# kubectl
brew install kubectl

# SOPS + age (secrets encryption)
brew install sops age

# Flux (optional, for FluxCD-style bootstrapping)
brew install fluxcd/tap/flux
```

## Quick Start

### 1. Generate SOPS age key

```bash
make generate-age-key
# Copy the public key output, update .sops.yaml
```

### 2. Generate Talos schematic

```bash
# Go to https://factory.talos.dev/schematics
# Or use the API:
curl -X POST https://factory.talos.dev/schematics \
  -H "Content-Type: application/json" \
  -d @tofu/talos/schematic.json
# Save the returned schematic ID
```

### 3. Create Proxmox credentials

```bash
cp tofu/providers/terraform.tfvars.example tofu/providers/terraform.tfvars
# Edit with your Proxmox endpoint, username, password
```

### 4. Bootstrap everything

```bash
make bootstrap
```

This runs the full sequence:
1. `tofu init` — initialize OpenTofu providers
2. `tofu apply` — create Talos CP VM + HAOS VM on N100
3. `talos apply` — apply Talos machine configs
4. `talos bootstrap` — bootstrap etcd
5. `talos kubeconfig` — get kubeconfig
6. `kubectl apply -f cluster/` — deploy Cilium, Longhorn, cert-manager, ArgoCD

### 5. Access ArgoCD

```bash
# ArgoCD UI
open https://argocd.budabuda-k8s.duckdns.org

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 6. Add DNS entries

Point these to your cluster IPs:

```
*.budabuda-k8s.duckdns.org → 192.168.1.202 (Cilium Gateway)
budabuda-k8s.duckdns.org    → 192.168.1.200 (API VIP)
argocd.budabuda-k8s.duckdns.org → 192.168.1.203 (ArgoCD)
```

## Directory Structure

```
homelab/
├── tofu/                          # OpenTofu (Infrastructure as Code)
│   ├── providers/                 # Provider configs, variables, outputs
│   │   ├── versions.tf            # Provider version pins
│   │   ├── main.tf                # Provider block (proxmox, talos, k8s)
│   │   ├── variables.tf           # Input variables
│   │   └── outputs.tf             # Outputs (talosconfig, kubeconfig)
│   ├── modules/talos/             # Talos VM module (SMBIOS, NIC, etc.)
│   │   ├── main.tf                # VM + machine config + bootstrap
│   │   ├── variables.tf           # Node definitions, IPs, extensions
│   │   └── outputs.tf
│   ├── haos/                      # Home Assistant OS VM
│   │   ├── main.tf                # Download qcow2 + create VM
│   │   ├── variables.tf           # HAOS version, IP, resources
│   │   └── outputs.tf
│   └── talos/                     # Talos factory schematic
│       ├── schematic.yaml         # Human-readable extension list
│       └── schematic.json         # API payload for factory.talos.dev
├── cluster/                       # Kubernetes manifests (GitOps)
│   ├── base/                      # Core infrastructure
│   │   ├── cilium/                # CNI + L2 LB + Gateway API
│   │   │   ├── helmrelease.yaml   # Cilium Helm + LB pool + L2 policy
│   │   │   ├── gateway.yaml       # HTTPS Gateway + HTTP→HTTPS redirect
│   │   │   └── blocky-dns.yaml    # Blocky DNS LoadBalancer Service
│   │   ├── longhorn/              # Storage + NFS backup
│   │   │   └── helmrelease.yaml   # Longhorn Helm + RecurringJobs
│   │   ├── cert-manager/          # TLS certificates
│   │   │   └── helmrelease.yaml   # cert-manager + DuckDNS webhook
│   │   └── keda/                  # Scale-to-zero
│   │       └── helmrelease.yaml   # KEDA operator
│   ├── apps/                      # Application manifests
│   │   ├── networking/            # Authelia, Netbird, Mosquitto
│   │   ├── monitoring/            # Uptime Kuma, Glances
│   │   ├── media/                 # Jellyfin
│   │   └── utilities/             # Heimdall
│   └── bootstrap/                 # ArgoCD bootstrap
│       ├── argocd.yaml            # ArgoCD Helm + RBAC
│       ├── app-of-apps.yaml       # Root Application
│       └── appsets.yaml           # ApplicationSets (core-infra, apps)
├── secrets/                       # Encrypted secrets (SOPS)
├── .sops.yaml                     # SOPS encryption rules
└── Makefile                       # Bootstrap + day-2 commands
```

## Services (24 total)

| Service | Scale-to-Zero | ExternalAuth | Notes |
|---------|:------------:|:------------:|-------|
| Netbird | No | No | Zero-trust, DaemonSet |
| Blocky | No | No | DNS, LoadBalancer Service |
| Uptime Kuma | No | Yes | Monitoring dashboard |
| Mosquitto | No | No | MQTT broker |
| Music Assistant | Yes (KEDA) | No | HA integration, USB DAC |
| Jellyfin | No | Yes | Media server, Intel QSV |
| Heimdall | No | Yes | Dashboard |
| Authelia | No | — | Forward auth service |
| Glances | No | No | Host metrics, DaemonSet |
| Paperless | Yes (KEDA) | Yes | Document management |
| Ombi | Yes (KEDA) | Yes | Media requests |
| MeTube | Yes (KEDA) | Yes | YouTube downloader |
| Node-RED | No | Yes | Automation |
| SFTPGo | No | Yes | SFTP server |
| SSHwifty | Yes (KEDA) | Yes | Web SSH client |
| Immich | No | Yes | Photos (official Helm) |
| Arr suite | Yes (KEDA) | Yes | Sonarr/Radarr/Prowlarr |
| cert-manager | No | No | TLS certificates |
| KEDA | No | No | Scale-to-zero operator |
| ArgoCD | No | No | GitOps controller |

## Day 2 Operations

### Update Cilium version

```bash
# Edit cluster/base/cilium/helmrelease.yaml
# Change spec.chart.spec.version
# Commit and push — ArgoCD syncs automatically
```

### Add a new application

1. Create directory: `cluster/apps/<category>/<app-name>/`
2. Add `app.yaml` with Deployment, Service, PVC, HTTPRoute
3. Add HTTPRoute with ExternalAuth filter (copy from jellyfin.yaml as template)
4. Add to `cluster/bootstrap/appsets.yaml` in the applications generator
5. Commit and push

### Update secrets

```bash
# Encrypt a new secret
sops -e secrets/new-secret.yaml > secrets/new-secret.enc.yaml

# Edit an encrypted secret
sops secrets/existing-secret.enc.yaml
```

### Backup verification

```bash
# Check Longhorn volumes
kubectl -n longhorn-system get volumes

# Check backup status
kubectl -n longhorn-system get recurringjobs

# Restore a volume
kubectl -n longhorn-system get backups
```

### Scale-to-zero KEDA ScaledObject example

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ombi-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: ombi
  minReplicaCount: 0
  maxReplicaCount: 1
  triggers:
    - type: cron
      metadata:
        timezone: Europe/Bratislava
        start: 0 18 * * *
        end: 0 23 * * *
        desiredReplicas: "1"
```

### Access Talos control plane

```bash
talosctl --talosconfig=talosconfig --nodes=192.168.1.210 dashboard
talosctl --talosconfig=talosconfig --nodes=192.168.1.210 logs
```

## Teardown

```bash
# Destroy K8s workloads (keep Proxmox VMs)
kubectl delete -f cluster/apps/
kubectl delete -f cluster/base/

# Destroy infrastructure
make tofu-destroy
```

## Documentation

Architecture decisions and service details are in `agent-implementation/`:

- `ARCHITECTURE.md` — Design decisions (D01-D22)
- `HARDWARE.md` — Physical hardware constraints
- `SERVICES.md` — All 24 services with migration mapping
- `NETWORKING.md` — IP allocation, Cilium config, ExternalAuth
- `SECURITY.md` — SOPS + age, RBAC, secrets management
- `BACKUP.md` — Longhorn + Synology NFS strategy

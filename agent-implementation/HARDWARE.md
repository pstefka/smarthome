# Hardware

## N100 (Control Plane)

- **CPU**: Intel N100, 4 cores
- **RAM**: 16 GB
- **Storage**: 1 TB SSD
- **Role**: Proxmox host, Talos CP VM + HAOS VM
- **IP**: 192.168.1.x (Proxmox host)

### VM Allocation

| VM | vCPU | RAM | Disk | Purpose |
|----|------|-----|------|---------|
| Talos CP | 4 | 12 GB | 80 GB | Kubernetes control plane |
| HAOS | 2 | 3 GB | 32 GB | Home Assistant OS |
| Proxmox | — | 1 GB | — | Hypervisor overhead |
| **Total** | — | **16 GB** | **112 GB** | |

## NUC (Worker)

- **CPU**: Intel (4 cores)
- **RAM**: 16 GB
- **Storage**: 100 GB SSD
- **Role**: Proxmox host, Talos Worker VM
- **IP**: 192.168.1.x (Proxmox host)
- **USB DAC**: Connected here, passed through to Talos CP VM

### VM Allocation

| VM | vCPU | RAM | Disk | Purpose |
|----|------|-----|------|---------|
| Talos Worker | 4 | 14 GB | 90 GB | Kubernetes workloads |
| Proxmox | — | 1 GB | — | Hypervisor overhead |
| **Total** | — | **15 GB** | **91 GB** | |

## Synology NAS

- **Storage**: Spinning disks
- **Role**: NFS backup destination only
- **NFS export**: /volume2/backup_nuc
- **IP**: 192.168.1.10

## Constraints

- 100 GB on NUC is tight, Longhorn storage is limited
- Spinning disks on Synology, backup only not primary storage
- Single control plane means accepted etcd single-point-of-failure
- USB DAC on NUC passed through to Talos CP VM for Music Assistant

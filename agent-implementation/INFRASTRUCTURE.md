# Infrastructure — OpenTofu + Talos + HAOS

## Overview

Infrastructure is managed by OpenTofu using:
- **bpg/proxmox** provider — Proxmox VM management
- **siderolabs/talos** provider — Talos cluster bootstrap
- **silvemerson/talos-linux-cluster/proxmox** module — orchestration

## Talos Factory Schematic

Extensions included in the Talos image:

```yaml
customization:
  bootloader: grub
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools        # Longhorn iSCSI
      - siderolabs/nfs-utils           # NFS client (rpcbind, rpc.statd)
      - siderolabs/qemu-guest-agent    # Proxmox integration
      - siderolabs/usb-audio-drivers   # USB DAC passthrough to K8s
      - siderolabs/netbird             # Zero-trust networking
```

Generate schematic ID:

```bash
curl -X POST --data-binary @infrastructure/talos/schematic.yaml \
  https://factory.talos.dev/schematics
```

## Module Configuration

The silvemerson module handles:
1. Downloads Talos ISO from factory.talos.dev
2. Generates machine configs (controlplane + worker)
3. Creates Proxmox VMs with correct resources
4. Uploads machine configs as cloud-init snippets
5. Bootstraps the Kubernetes cluster
6. Outputs kubeconfig + talosconfig

### Key inputs

| Input | Value | Notes |
|-------|-------|-------|
| talos_version | "1.13.3" | Latest stable |
| kubernetes_version | "1.36.3" | Pinned, latest stable |
| talos_schematic_id | generated | From factory API |
| cluster_name | "homelab" | |
| controlplane_vip | "192.168.1.200" | kube-vip API endpoint |
| target_node | "pve" | Proxmox node name |

## Talos Link Alias

Talos names interfaces based on MAC address (e.g., `enx78e7d1ea46da`),
which breaks Cilium L2 announcements that need a stable interface name.
Solution: use `LinkAliasConfig` to alias the physical NIC to `net0`.

This is applied via Talos machine config (patched during bootstrap):

```yaml
apiVersion: v1alpha1
kind: LinkAliasConfig
name: net0
selector:
  match: true
```

Then reference `net0` in Cilium L2 announcement policy and in the
Talos network configuration for addressing/routes.

## HAOS VM

Managed separately via bpg/proxmox resources:
- Downloads HAOS qcow2 from GitHub releases
- Creates q35 VM with OVMF/UEFI
- Imports disk, configures VirtIO SCSI
- Enables QEMU guest agent

### HAOS VM Settings

| Setting | Value |
|---------|-------|
| machine | q35 |
| bios | ovmf |
| cpu type | host |
| scsihw | virtio-scsi-pci |
| balloon | 0 (disabled) |
| agent | enabled |

## Outputs

- `kubeconfig` — sensitive, used by kubectl
- `talosconfig` — sensitive, used by talosctl

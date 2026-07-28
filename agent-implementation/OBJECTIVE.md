# Objective

## Goal

Rework a 2-node homelab into a near-zero-toil Kubernetes platform using
infrastructure-as-code, GitOps, and modern cloud-native tooling.

## Design Principles

1. **Everything as Code** — OpenTofu for infra, GitOps for cluster components
2. **Git as single source of truth** — all configs version-controlled
3. **Zero manual intervention** — self-healing, auto-updates, auto-scaling
4. **Learn by doing** — each component understood before deployed
5. **Pragmatic trade-offs** — 2 nodes, single CP etcd, accepted limitations

## Key Technologies

- **Proxmox VE** — hypervisor on both nodes
- **Talos Linux** — immutable Kubernetes OS (runs as Proxmox VMs)
- **OpenTofu** — infrastructure provisioning (VMs, HAOS)
- **Cilium** — CNI + kube-proxy replacement + L2 LB + Gateway API (ingress)
- **Longhorn** — distributed storage (1 replica + NFS backup)
- **ArgoCD** — GitOps continuous delivery
- **SOPS + age** — secrets encryption in Git
- **KEDA** — scale-to-zero for intermittent workloads
- **Uptime Kuma** — lightweight endpoint monitoring

## Scope

- 2-node cluster: 1 control plane + 1 worker
- All services inside Kubernetes (no systemd fallbacks)
- USB DAC passthrough directly to K8s node
- Flat LAN, no VLANs initially
- Backup to existing Synology NAS via NFS
- Minimal monitoring (Uptime Kuma only, no Prometheus stack)

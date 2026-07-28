# Open Questions

## All Resolved

1. ~~Keep Duplicati or use Longhorn native?~~ — Longhorn native
2. ~~MetalLB or Cilium L2?~~ — Cilium L2 (MetalLB removed)
3. ~~Where to store secrets?~~ — SOPS + age in Git
4. ~~HAOS included in OpenTofu?~~ — Yes, via bpg/proxmox provider
5. ~~Talos extensions?~~ — All 5 confirmed (iscsi, nfs, qemu-ga, usb-audio, netbird)
6. ~~Traefik or nginx?~~ — Cilium built-in Gateway API (no separate ingress controller)
7. ~~ArgoCD or FluxCD?~~ — ArgoCD
8. ~~HPA or KEDA for scale-to-zero?~~ — KEDA (HPA scale-to-zero is alpha in 1.36)
9. ~~Keep MetalLB alongside Cilium?~~ — No, Cilium L2 replaces it entirely
10. ~~Keep kube-vip alongside Cilium?~~ — Yes, kube-vip for API VIP only (before CNI), Cilium for service LB
11. ~~NFS export path?~~ — /volume2/backup_nuc on 192.168.1.10
12. ~~FQDN for external access?~~ — budabuda-k8s.duckdns.org
13. ~~Kubernetes version?~~ — 1.36.3 (pinned, latest stable)
14. ~~Monitoring scope?~~ — Uptime Kuma only (no kube-prometheus-stack)
15. ~~USB DAC passthrough?~~ — To K8s node (N100 Talos CP VM), not HAOS
16. ~~Talos interface naming for Cilium?~~ — LinkAliasConfig to alias NIC to net0
17. ~~Authelia forward auth with Cilium Gateway API?~~ — ExternalAuth filter (GEP-1494), available Cilium 1.20+. Authelia exposes `/api/authz/ext-authz` for Envoy ext_authz. No Traefik needed.

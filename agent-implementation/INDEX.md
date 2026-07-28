# Homelab Kubernetes Platform — Agent Implementation Guide

## Purpose

This documentation captures the full context for building a near-zero-toil
Kubernetes platform on a 2-node homelab. It serves as persistent memory
for AI coding assistants and human reference.

## Sections

| File | Topic |
|------|-------|
| [OBJECTIVE](OBJECTIVE.md) | What we're building and why |
| [HARDWARE](HARDWARE.md) | Physical hardware specs and constraints |
| [ARCHITECTURE](ARCHITECTURE.md) | All architecture decisions with rationale |
| [SERVICES](SERVICES.md) | Current services and K8s migration mapping |
| [INFRASTRUCTURE](INFRASTRUCTURE.md) | OpenTofu, Talos Linux, HAOS provisioning |
| [GITOPS](GITOPS.md) | ArgoCD, directory structure, sync waves |
| [SECURITY](SECURITY.md) | SOPS + age, secrets management flow |
| [BACKUP](BACKUP.md) | Longhorn backups, NFS, disaster recovery |
| [NETWORKING](NETWORKING.md) | IP allocation, Cilium, Gateway API |
| [WORK-STATE](WORK-STATE.md) | Completed, active, blocked, next steps |
| [OPEN-QUESTIONS](OPEN-QUESTIONS.md) | Pending decisions needing input |

## Quick Reference

- **Cluster endpoint**: 192.168.1.200 (kube-vip)
- **CP node**: 192.168.1.210 (N100)
- **Worker node**: 192.168.1.211 (NUC)
- **LB pool**: 192.168.1.201-209 (Cilium L2)
- **FQDN**: budabuda-k8s.duckdns.org
- **NFS backup**: 192.168.1.10:/volume2/backup_nuc
- **Last updated**: 2026-07-28

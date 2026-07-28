# Backup — Longhorn + NFS + Synology

## Strategy

All persistent volume backups handled by Longhorn's built-in
RecurringJob system, targeting Synology NFS export.

## Backup Target

```
NFS: nfs://192.168.1.10:/volume2/backup_nuc/longhorn
```

## Recurring Jobs

### Daily Backup

- Schedule: `0 2 * * *` (2:00 AM daily)
- Task: `backup`
- Retention: 30 backups
- Full backup interval: 7 (weekly full for corruption recovery)
- Concurrency: 2

### Hourly Snapshots

- Schedule: `0 * * * *` (every hour)
- Task: `snapshot`
- Retention: 24 snapshots

## Incremental Behavior

- Default: delta backups (only changed blocks uploaded)
- `fullBackupInterval: 7` forces full backup every 7th cycle
- Smart backup: only creates new backup when volume has new data

## Disaster Recovery Procedure

1. Rebuild Proxmox VMs via `tofu apply`
2. Run `make bootstrap` (reinstall ArgoCD, inject age key)
3. ArgoCD syncs all manifests from Git
4. Longhorn restores volumes from NFS backup target
5. Services come back up with persistent data intact

## What Is NOT Backed Up by Longhorn

- etcd data (single CP, accepted risk)
- Proxmox VM configs (recreatable via OpenTofu)
- Talos machine configs (in Git, SOPS-encrypted)
- Kubernetes manifests (in Git)

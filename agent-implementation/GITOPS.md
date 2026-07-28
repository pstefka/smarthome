# GitOps — ArgoCD

## Pattern: App of Apps

ArgoCD manages itself and all components via two root Applications:

1. **cluster-components** — watches `cluster/` directory
2. **applications** — watches `apps/` directory

Any change pushed to Git triggers automatic sync.

## Sync Waves (deployment order)

```
Wave 0: SOPS-age operator (decryption for all secrets)
Wave 1: Cilium (CNI + kube-proxy + L2 LB + Gateway API)
Wave 2: Longhorn (storage — needs Cilium for service discovery)
Wave 3: cert-manager + external-dns (TLS + duckdns.org)
Wave 4: KEDA (scale-to-zero)
Wave 5: ArgoCD ApplicationSets (self-manage)
Wave 6: Applications (Blocky via LB Service, all others via HTTPRoute)
```

## Directory Structure

```
cluster/base/       HelmReleases + CRDs for cluster components
cluster/overlays/   Kustomize overlays per environment
apps/               Application workloads (one dir per app)
bootstrap/          ArgoCD Application + App of Apps manifests
```

## Sync Policy

- `automated.prune: true` — deleted manifests remove resources
- `automated.selfHeal: true` — drift is corrected automatically
- `syncOptions.CreateNamespace: true` — namespaces created as needed

## ArgoCD Self-Management

After bootstrap, ArgoCD watches its own manifests in Git.
Upgrades happen by updating the HelmRelease version in Git.
No manual `helm upgrade` ever needed.

# Security — SOPS + age

## Secret Management Flow

```
1. Developer encrypts secret with SOPS + age public key
2. Encrypted file committed to Git (safe to store)
3. ArgoCD syncs the encrypted manifest
4. SOPS-age operator decrypts using age private key (stored in K8s secret)
5. Decrypted secret available to pods
```

## Age Key Management

- **Public key**: committed to Git (in `.sops.yaml`)
- **Private key**: stored in password manager, injected into K8s during bootstrap
- **Bootstrap injection**:

```bash
kubectl create secret generic sops-age \
  --namespace=argocd \
  --from-literal=age.key="<private-key>"
```

## SOPS Configuration

Global `.sops.yaml` defines encryption rules:

- `infrastructure/*.yaml` — encrypted with age key
- `cluster/**/*secret*.yaml` — encrypted
- `apps/**/*secret*.yaml` — encrypted

## What Gets Encrypted

- Talos machine secrets (PKI)
- Proxmox API tokens
- Service passwords and API keys
- Docker registry credentials
- Longhorn backup credentials

## What Does NOT Get Encrypted

- Helm chart values (non-secret config)
- Manifest structure and resource definitions
- IP addresses and hostnames

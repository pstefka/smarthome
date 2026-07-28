# Work State

## Completed

- [x] Architecture decisions documented
- [x] Hardware inventory and constraints identified
- [x] Service list with migration mapping
- [x] Longhorn backup capabilities verified (incremental + retention)
- [x] OpenTofu Talos module verified (silvemerson)
- [x] Talos extensions verified (all 5 available including netbird)
- [x] HAOS on Proxmox via Terraform approach confirmed
- [x] Cilium L2 replaces MetalLB (research-backed)
- [x] kube-vip vs Cilium L2 responsibilities clarified
- [x] HPA scale-to-zero evaluated (alpha in 1.36, KEDA chosen instead)
- [x] Agent implementation documentation written
- [x] Open questions resolved (NFS path, FQDN, K8s version, monitoring, USB DAC, link alias)

## Active

- [ ] (none currently)

## Pending (Next)

- [ ] Write OpenTofu configs (providers, modules, HAOS)
- [ ] Create terraform.tfvars with actual Proxmox credentials
- [ ] Generate Talos schematic ID via factory.talos.dev API
- [ ] Test OpenTofu init/plan/apply
- [ ] Write Cilium HelmRelease + CRDs
- [ ] Write Longhorn HelmReleases + RecurringJobs
- [ ] Write Traefik Gateway API manifests
- [ ] Write ArgoCD bootstrap manifests
- [ ] Configure SOPS age key (generate key, update .sops.yaml)
- [ ] Write SOPS configuration
- [ ] Write Makefile bootstrap targets
- [ ] Write application manifests (Blocky, Authelia, etc.)
- [ ] Write KEDA ScaledObjects for scale-to-zero services
- [ ] Initialize git repo, generate .gitignore, first commit

## Blocked

- (none currently)

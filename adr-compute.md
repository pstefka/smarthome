# Compute

- Intel NUC running docker containers
- N100 running Proxmox
  - HAOS with applications (containers)
  - one of:

|Name|HAOS Apps|Talos OS|K3s|Proxmox LXC|Containers|
|---|---|---|---|---|---|
|Description|- running inside HAOS VM|- immutable OS, with declarative config|- running on top of Ubuntu|- Proxmox native|- running on top of Ubuntu|
||- nested virtualization|- nested virtualization|- nested virtualization|- **native virtualization**|- nested virtualization|
||- extremly easy|- interesting approach, could learn something new|- similar to RKE2|- probably harder management, upgrades|- same old approach|
||- lifecycle dependent on HAOS|- slightly higher resource usage than k3s|- very lightweight|- ultra lightweight||
|||- K8s *|- K8s *|- LXC containers|- Docker containers|

\* many new options, like gitops, operators ..

## Decision

KISS

- NUC runs docker containers
- N100 runs HAOS with apps, plus Ubuntu

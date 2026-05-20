# Talos on PVE

<https://docs.siderolabs.com/talos/v1.13/platform-specific-installations/virtualized-platforms/proxmox>

## Setup config folder

- create .envrc

```bash
export VERSION=v1.13.2
export SCHEMATIC_ID=$(curl -X POST --data-binary "@${PWD}/schematic.yaml" https://factory.talos.dev/schematics 2>/dev/null | jq -r '.id')
export CLUSTER_NAME=talos-proxmox-cluster
export CONTROL_PLANE_IP=192.168.1.210 # from IP reservation
export TALOSCONFIG="${PWD}/_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
export KUBECONFIG=${PWD}/kubeconfig
```

## Generate ISO

- navigate to <https://factory.talos.dev/>
- select BIOS version
- select customizations, e.g. qemu-guest-agent, iscsi-tools, nfs-utils, netbird, usb-audio-drivers
- export customizations to `schematic.yaml`
- download ISO image

or when `schematic.yaml` already defined

- get schematic ID `curl -X POST --data-binary @schematic.yaml https://factory.talos.dev/schematics 2>/dev/null | jq -r '.id'`
- download ISO `wget https://factory.talos.dev/image/${SCHEMATIC_ID}/${VERSION}/no-cloud-amd64.iso`

## Create VM

> [!NOTE]  
> only working combination seems to be BIOS / DUAL boot ISO with SeaBIOS

Schematic ID: `8406107f4c54759f0e75965a989bbb54ae8b0d269741a473ab234a53d1b0c162` (BIOS v1.13.2)

- Image Factory - <https://factory.talos.dev/?arch=amd64&platform=nocloud&schematic-id=${SCHEMATIC_ID}&target=cloud&version=${VERSION}>
- Initial Installation - <factory.talos.dev/nocloud-installer/${SCHEMATIC_ID}:${VERSION}>
- Upgrades - <factory.talos.dev/nocloud-installer/${SCHEMATIC_ID}:${VERSION}>
- Local Test Cluster - `talosctl cluster create qemu --schematic-id=${SCHEMATIC_ID} --talos-version=${VERSION}`
- PXE booter `docker run --rm --network host ghcr.io/siderolabs/booter:v0.3.0 --talos-version=${VERSION} --schematic-id=${SCHEMATIC_ID}`

## Store Control Plane IP

- from Console / LAN get reservation IP 
- update `CONTROL_PLANE_IP` in .envrc with reservation IP

## Extensions

- get status `talosctl get extensions`
- verify set addon config `talosctl get extensionserviceconfigs`

### Netbird

<https://github.com/microdatacenter-community/talos-extensions/tree/main/network/netbird>

- save setup key in `extention-netbird.yaml` .environment.NB_SETUP_KEY

## Configure machines

### Generate configuration

- ~~configure machine config - `talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --output-dir _out`~~
- with QEMU agent support

```bash
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 \
         --output-dir _out \
         --install-image factory.talos.dev/installer/${SCHEMATIC_ID}:${VERSION} \
         --config-patch @patch-control-plane-scheduling.yaml \
         --config-patch @patch-flannel-netpol.yaml \
         --config-patch @extention-netbird.yaml
         #  --config-patch-control-plane cp.yaml \
         #  --config-patch-worker worker.yaml
```

### Apply the config

- create control plane node

```bash
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml
```

- ~~set endpoint - `talosctl --talosconfig=_out/talosconfig config endpoints $CONTROL_PLANE_IP`~~

- create worker node

```bash
talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml
```

## Using the cluster

- bootstrap etcd - `talosctl bootstrap`
- get kubeconfig - `talosctl kubeconfig .`

## Post install

### Ingress controller

- <https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-traefik>

### Storage

- Longhorn <https://docs.siderolabs.com/kubernetes-guides/csi/storage#longhorn> => <https://longhorn.io/docs/1.9.0/advanced-resources/os-distro-specific/talos-linux-support/> => <https://docs.siderolabs.com/kubernetes-guides/security/pod-security>
- Local storage <https://docs.siderolabs.com/kubernetes-guides/csi/local-storage>

### Other

- PSA - <https://docs.siderolabs.com/kubernetes-guides/security/pod-security>
- User Namespaces - <https://docs.siderolabs.com/kubernetes-guides/security/usernamespace>
- ArgoCD - <https://docs.siderolabs.com/kubernetes-guides/advanced-guides/deploy-argocd>
- Traefik with Authelia - <https://www.authelia.com/integration/kubernetes/traefik-ingress/>

## Upgrades

### Talos

- `talosctl upgrade --image ghcr.io/siderolabs/installer:v1.13.1` = see <https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/lifecycle-management/upgrading-talos#upgrading-talos-linux>

### K8s

- `talosctl upgrade-k8s --to ${k8s_release} --dry-run` see <https://docs.siderolabs.com/kubernetes-guides/advanced-guides/upgrading-kubernetes#upgrading-kubernetes>
- update configs !!! See <https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/system-configuration/reproducible-machine-configuration>

## Notes

### Patching

<https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/system-configuration/patching>

- generate config using all patches

```bash
talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --output-dir _out --install-image factory.talos.dev/installer/${SCHEMATIC_ID}:${VERSION} \
         --config-patch @patch.yaml
         --config-patch-control-plane @cp.yaml \
         --config-patch-worker @worker.yaml
# talosctl apply-config
```

- patch particular node config

```bash
talosctl machineconfig patch worker.yaml --patch patch.yaml -o worker.yaml
# talosctl apply-config
```

- live patch a node = always prefer node config change / generate config above!

```bash
talosctl patch mc --nodes 172.20.0.2 --patch patch.yaml
```

# K3S

## Dependencies

- Install Cilium CLI

```sh
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

- Install Helm

```sh
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

-- Install ArgoCD CLI

```sh
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

## K3s

### Server

- /etc/rancher/k3s/config.yaml

```yaml
write-kubeconfig-mode: "0640"
write-kubeconfig-group: peto
tls-san:
  - "k3s.budabuda.duckdns.org"
flannel-backend: none
disable-network-policy: true
node-taint:
  - node.cilium.io/agent-not-ready

#debug: true
```

- Install K3s as systemd service

```sh
curl -sfL https://get.k3s.io | sh -
```

### Agent

- /etc/rancher/k3s/config.yaml

```yaml
token: <token>
server: budabuda-k3s.duckdns.org

write-kubeconfig-mode: "0640"
write-kubeconfig-group: peto
tls-san:
  - "k3s.budabuda.duckdns.org"
flannel-backend: none
disable-network-policy: true
node-taint:
  - node.cilium.io/agent-not-ready

#debug: true
```

- Install K3s as systemd service

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=agent sh -
```

### SW

- Customize Traefik => /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    providers:
      kubernetesCRD:
        allowExternalNameServices: true
      kubernetesIngress:
        allowExternalNameServices: true
```

- Install Cilium

```yaml
# values.yaml - https://docs.cilium.io/en/v1.16/helm-reference/
operator:
  replicas: 1
```

```sh
helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium --version 1.16.5 --namespace kube-system --values values.yaml
```

- Install ArgoCD

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch cm -n argocd argocd-cmd-params-cm -p '{"data":{"server.insecure": "true"}}'
```

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`argocd.k3s.budabuda.duckdns.org`)
      priority: 10
      services:
        - name: argocd-server
          port: 80
    - kind: Rule
      match: Host(`argocd.k3s.budabuda.duckdns.org`) && Header(`Content-Type`, `application/grpc`)
      priority: 11
      services:
        - name: argocd-server
          port: 80
          scheme: h2c
  tls:
    certResolver: default
```

```sh
argocd admin initial-password -n argocd | head -1
argocd login argocd.k3s.budabuda.duckdns.org
```

- Create ArgoCD application

```sh
argocd app create smarthome --repo https://github.com/pstefka/smarthome.git --path manifests --dest-server https://kubernetes.default.svc --dest-namespace smarthome
```

## TODO

- use K3s Helm controller for installation <https://docs.k3s.io/helm>
- install ArgoCD using helm chart
- ArgoCD configuration using CRDs

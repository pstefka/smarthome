# Networking — IP Allocation + Cilium + Gateway API

## IP Allocation

```
192.168.1.0/24 — Flat LAN

Control Plane:
  .200    API VIP (kube-vip, ARP)
  .210    Talos CP node (N100)

Worker:
  .211    Talos Worker node (NUC)

Cilium LB Pool (L2 announcements):
  .201    Blocky DNS (LoadBalancer Service, port 53)
  .202    Cilium Gateway (HTTPS, all web services)
  .203-209  Future services

Existing Infrastructure:
  .100      N100 Proxmox host
  .6      NUC Proxmox host
  .7      HAOS (Proxmox VM)
  .10      Synology NAS
  .1      Router/gateway
```

## DNS

- **FQDN**: budabuda-k8s.duckdns.org
- **Provider**: duckdns.org (DNS-01 challenge via cert-manager)
- **External access**: Cilium Gateway API + Let's Encrypt TLS

## Cilium Configuration

- **Routing mode**: native (no overlay, direct routing on LAN)
- **kube-proxy replacement**: true (eBPF datapath)
- **L2 announcements**: enabled (replaces MetalLB)
- **LB-IPAM pool**: 192.168.1.201-209
- **Hubble**: enabled (observability)
- **WireGuard encryption**: optional (pod-to-pod)

### Talos Prerequisites

**Disable kube-proxy** in Talos machine config:

```yaml
cluster:
  proxy:
    disabled: true
  network:
    cni:
      name: none
```

**Link alias** for stable interface name (Talos uses MAC-based naming
which breaks Cilium L2 announcements). Add to machine config:

```yaml
apiVersion: v1alpha1
kind: LinkAliasConfig
name: net0
selector:
  match: true  # single NIC per VM, match the only physical link
```

Then reference `net0` in Cilium L2 announcement policy and in the
Talos network configuration for addressing/routes.

## Gateway API (Cilium built-in)

Cilium has a built-in Gateway API implementation. No separate ingress
controller (Traefik, nginx) needed. Enable in Cilium Helm values:

```yaml
gatewayAPI:
  enabled: true
```

### Resources

```
GatewayClass   cilium (auto-created by Cilium)
Gateway         HTTPS listener on budabuda-k8s.duckdns.org
HTTPRoute       per-service routing rules (cross-namespace)
```

### Blocky DNS — LoadBalancer Service (NOT Gateway API)

Cilium does NOT support TCPRoute. Blocky DNS (port 53, TCP+UDP)
is exposed via a LoadBalancer Service directly:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: blocky
  annotations:
    io.cilium/lb-ipam-ips: "192.168.1.201"
spec:
  type: LoadBalancer
  ports:
    - name: dns-tcp
      port: 53
      protocol: TCP
    - name: dns-udp
      port: 53
      protocol: UDP
  selector:
    app.kubernetes.io/name: blocky
```

### TLS

- cert-manager with `enableGatewayAPI: true`
- Let's Encrypt DNS-01 challenge via duckdns.org
- Annotate Gateway: `cert-manager.io/cluster-issuer: letsencrypt-prod`

### Authelia Forward Auth — ExternalAuth Filter (GEP-1494)

Cilium 1.20+ supports ExternalAuth on HTTPRoutes (maps to Envoy ext_authz).
Authelia has a dedicated `/api/authz/ext-authz` endpoint for this.

**Caveat**: Cilium 1.20.0-rc.0 had a bug (ExternalAuth fails open when auth
service is unavailable). Fixed in rc.1+. User must verify Cilium version.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: jellyfin
  namespace: default
spec:
  parentRefs:
    - name: gateway
      namespace: ingress
  hostnames:
    - jellyfin.budabuda-k8s.duckdns.org
  rules:
    - filters:
        - type: ExternalAuth
          externalAuth:
            protocol: HTTP
            backendRef:
              kind: Service
              name: authelia
              namespace: auth
              port: 80
            http:
              path: /api/authz/ext-authz
              allowedResponseHeaders:
                - Remote-User
                - Remote-Groups
                - Remote-Email
      backendRefs:
        - name: jellyfin
          port: 8096
```

**Services using ExternalAuth** (all HTTPRoutes except Blocky):
- Jellyfin, Heimdall, Paperless, SFTPGo, SSHwifty, MeTube, Node-RED,
  Uptime Kuma, Arr suite, Ombi, Glances

**Services NOT using ExternalAuth** (LB Service or internal):
- Blocky (DNS, port 53 — no HTTP)
- Netbird (network overlay, auth handled separately)
- Mosquitto (MQTT, port 1883)
- Music Assistant (internal HA integration)

### Services NOT behind Gateway API (LoadBalancer Service)

- Blocky DNS — LoadBalancer Service on 192.168.1.201

# K3S

## Proxmox

- run Proxmox installer

```sh
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/vm/ubuntu2404-vm.sh)"
```

- enable ssh access <https://github.com/tteck/Proxmox/discussions/2072>

```sh
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' -e 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
rm /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
systemctl restart sshd
```

- create user

```sh
groupadd peto
useradd -g peto -m -s /bin/bash peto
usermod -a -G sudo peto
```

- copy SSH key to user

## Ansible

- /etc/rancher/k3s/config.yaml

```txt
write-kubeconfig-mode: "0640"
write-kubeconfig-group: peto
tls-san:
  - "k3s.budabuda.duckdns.org"
flannel-backend: none
disable-network-policy: true

#debug: true
```

- Install K3s as systemd service

```sh
- curl -sfL https://get.k3s.io | sh -
```

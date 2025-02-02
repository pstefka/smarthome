# K3S

## Proxmox

### Create VM

- run Proxmox installer

```sh
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/vm/ubuntu2404-vm.sh)"
```

### Remote Access

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

### Networking

Add secondary network device:

```txt
Bridge: vmbr0
VLAN tag: 10
Firewall: false
```

## Configuration

### Networking

Setup static IP for secondary interface in /etc/netplan/50-cloud-init.yaml:

```yaml
network:
  version: 2
  ethernets:
<--snip-->
    ens19:
      match:
        macaddress: "bc:24:11:c1:94:c0"
      set-name: "ens19"
      dhcp4: false
      dhcp6: false
      addresses:
      - 192.168.2.230/24
      routes:
      - to: default
        via: 192.168.2.1
      nameservers:
       addresses: [192.168.2.7,192.168.1.6]
```

Apply netplan:

```sh
netplan generate & netplan apply
```

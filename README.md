# Flox environment

## Usage

1) [Install Flox](https://flox.dev/docs/install-flox/install)

   ```bash
   FLOX_DEB="flox-1.12.2.x86_64-linux.deb
   wget https://downloads.flox.dev/by-env/stable/deb/${FLOX_DEB}
   sudo dpkg -i ${FLOX_DEB}
   rm -f ${FLOX_DEB}

   cat >> ~/.bashrc <<EOF
   ( wsl.exe -d $WSL_DISTRO_NAME -u root service nix-daemon status 2>&1 >/dev/null ) || wsl.exe -d $WSL_DISTRO_NAME -u root service nix-daemon start
   EOF
   ```

2) Clone the repo

   ```bash
   git clone git@github.com:pstefka/smarthome.git ~/.config/environment-management
   git-crypt unlock </path/to/key>
   ```

> [!NOTE]  
> repo uses git-crypt to hide secrets! Check password manager for the unlock key

3) Activate the environment when launching bash

   ```bash
   cat <<EOF >> ~/.bashrc
   if [[ -n "${WT_PROFILE_ID}" ]]; then
     # launched from windows terminal
     if [ "$TERM" != "linux" ] && [ $(which dcmdump 2>/dev/null || echo FALSE) ]; then
       eval "$(flox activate -d ~/.config/environment-management)"
     fi
   fi
   EOF
   ```

## Cleanup

### Nix store

```bash
nix-store --gc
```

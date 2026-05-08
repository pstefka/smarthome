# Docker stack

## New

- create stack in _docker-compose-stacks/<name>/compose.yaml
  - use restart: unless-stoped so scale to 0 using Sablier works
  - specify container_name for nicer naming
    - in 1 stack = 1 service the container_name should be equal to the project & service name
  - ports 
    - do not forward ports outside of testing => everything should be exposed using reverse proxy, e.g. Caddy
      - inform about ports used by reverse proxy using expose stanza
  - volumes
    - use absolute paths to map volumes in the `/home/nuc/docker/<name>` directory for local paths
    - for external paths (NAS) use external volumes (created using _docker-volumes.sh script)
  - networks
    - use default network, if communication to outside world is required (proxy networks are internal!)
    - if service is authenticated use proxy network
    - if service authentication is disabled, use a dedicated network (created using _docker-networks.sh script) for separation
      - add network to _docker-networks.sh script, caddy compose, uptime-kuma compose
  - labels
    - use label `com.dockmon.update.policy=warn` if every update should be reviewed, i.e. sensible services
- add monitoring, e.g. Uptime Kuma
 
Example:

```yaml
name: bogus
services:
  bogus:
    restart: unless-stopped
    container_name: bogus
    expose:
      - "3001"
    volumes:
      - /home/nuc/docker/bogus:/app/data
      - nuc-photo-nfs:/nuc-photo-nfs
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    networks:
      - default
      - proxy-bogus

    labels:
      - "com.dockmon.update.policy=warn"
    image: bogus

volumes:
  nuc-photo-nfs:
    external: true
    name: nuc-photo-nfs
networks:
  proxy-bogus:
    name: proxy-bogus
    external: true

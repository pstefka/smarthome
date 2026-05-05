# Reverse proxy

|Name|Nginx Proxy Manager|Traefik|Caddy|
|---|---|---|---|
|Description|- manual config using GUI|- static declarative configuration|- manual declarative configuration only|
||- no Docker integration|- first class dynamic integration with Docker|- integration with Docker|
||- available as an HAOS addon|||

## Decision

Use Caddy because of IaC

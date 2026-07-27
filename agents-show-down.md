# Agents Show Down

So the practical path:
1. Have the exploratory discussion now (with me or any capable model) — use it to challenge assumptions, explore tradeoffs, find the right solution
2. Then install mattpocock/skills and run /grill-with-docs to formalize what you discovered into CONTEXT.md, ADRs, and a domain model
3. Then optionally run Spec Kit /specify to generate the formal spec with acceptance criteria from those artifacts
4. Then hand it to OMO or BMAD for execution

The frameworks are weakest at the "I don't know what I want yet" phase — they're strongest at "I know what I want, now make sure it's right."

## DevSecOps

Layer 1 — Spec & Architecture (before any code):
  BMAD Method + Infrastructure Module (Alex agent)
  OR mattpocock/skills (/grill-me + /to-spec for requirements)

Layer 2 — Code Generation & Review:
  mattpocock/skills (/tdd + /code-review + /implement)
  + BMAD Infrastructure Module (16-section validation checklist)

## Generic

Tier 1
Superpowers
mattpocock/skills
BMAD Method
Oh My OpenAgent

Tier 2
GSD
gstack
Ruflo

## Hybrid

- BMAD + Superpowers: Use BMAD’s persona-based planning for architecture, then Superpowers’ TDD enforcement for implementation. This works well for enterprise teams that want BMAD’s traceability with Superpowers’ code quality guarantees.
- BMAD + "Alex" DevOps agent (community module bmad-module-infrastructure-devops) with 16-section infrastructure validation checklist covering:
  - Security & Compliance, IaC, Resilience, DR, Monitoring, CI/CD, Networking, Container Platform (K8s), GitOps (ArgoCD/Flux), Service Mesh, Developer Experience
  - BMad Operations Suite
- SpecKit + GSD: Use SpecKit’s specification process to define requirements, then hand off to GSD’s execution engine for parallel implementation. This combination pairs the strongest specification layer with the strongest execution layer, but doubles the tooling complexity. I have done this. Mostly when migrating SDD projects to GSD.
- SpecKit + Superpowers?
- Ruflo - Best for: Genuinely massive parallel decomposition. Overkill for most projects.

## Harness

- Goose ?
- Opencode ? Can use Claude subscription?
- Hermes ? Can use Claude subscription?

## Links

<https://github.com/obra/superpowers>
<https://github.com/bmad-code-org/BMAD-METHOD>
<https://ai.plainenglish.io/the-great-framework-showdown-superpowers-vs-bmad-vs-speckit-vs-gsd-360983101c10>
<https://github.com/garrytan/gstack>
<https://github.com/mattpocock/skills>
<https://github.com/ruvnet/ruflo>
[Oh My OpenAgent](https://omo.dev) / <https://github.com/alvinunreal/oh-my-opencode-slim/>

## Info

<opencode -s ses_05a8f8600ffe8yaXRRPUlxEQFg>

The goal is to rework my home lab and learn some thing in between.

Current setup:

- flat /24 network
- 2 nodes
  - nuc 4CPU + 16GB RAM + 100GB storage
  - n100 4CPU + 16GB RAM + 1TB storage
    - runs Proxmox
      - HAOS appliance = to be kept!
- OLD Synology NAS
  - HDD backup
  - provides nfs / samba shares like pictures, music, videos

Many services run as docker compose on both nuc and n100, with local storage only, e.g.

- Netbird.io (connectivity)
- Blocky (DNS)
  - runs on nuc and n100 with a keepalived vip inbetween
- Uptime Kuma (monitoring)
- Duplicati (backup to Synology)
  - great incremental backup
  - great retention policies
- Mosquitto
- Music Assistant + squeezelight (with USB DAC)
- *arr suite
- Authelia (SSO)
- Caddy (reverse proxy)
  - Let's Encrypt certificates using duckdns.org
- Sablier (scale to zero)
- Paperless NG (documents)
- Watchtower (automatic upgrades * risks slightly mitigated using Kuma monitors)

Would like to create a near zero toil setup. Like to upgrade the setup to:

- be able balance workloads between hardware nodes (including storage)
- infrastructure as code (prefer OpenTofu)
  - including Talos, e.g. silvemerson/talos-linux-cluster/proxmox
- running all workloads (except Haos) in k8s (was thinking about using Talos)
- would like to use Cilium
- prefer GitOps (have experience with ArgoCD)
  - targeting github.com
  - secrets to be encrypted
- migrate docker compose to k8s
  - helm charts / kustomize seem a bit superfluous => 1 cluster only
- to a better working scale to zero solution
- automated creation / recovery < 30 minutes
- extend Proxmox to nuc = excelent backup capabilities, and can be easily provisioned using IaC

Was thinking:

- USB DAC (squeezelight) try k8s way, if doesn't work fallback to a systemd service
- using Longhorn with 1 replica for persistent storage + backup to NAS
  - prefer it's backup if feature set to Duplicati is same
- using Traefik as ingress controller, because Caddy IC is WIP
  - maybe use a Gateway API alternative?
- changing the DNS provider from duckdns.org = no custom domain, free tier
- all secrets should be stored encrypted in git => use SOPS + age?

While a homelab setup, should be load balanced, backed up, monitored, secure, disaster recoverable, documented day2 operations .. and should fit to the hardware on hand (no expansion planned)!


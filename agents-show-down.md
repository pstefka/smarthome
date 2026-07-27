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

# Changelog

All notable changes to **pgwd-selfhosted** (deployment manifests, docs, and tooling for this repository only) are documented here. For the **pgwd** application, see [pgwd CHANGELOG](https://github.com/hrodrig/pgwd/blob/main/CHANGELOG.md).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- **Helm chart `pgwd`:** default **`image.tag`** **`v0.5.10`** (GHCR tags match Git **`v*`** releases; **`0.5.10`** does not exist on ghcr). **`values.yaml`**, chart README, and **`_helpers.tpl`** note. Chart **`version`** **0.1.1**.
- **Ansible notification test:** fail the play when **`-force-notification`** produces **`connect_failure`** / “could not connect to Postgres” in mock captures (Loki + Slack), not only when payloads contain **`pgwd`**.
- **Compose image:** **`PGWD_IMAGE`** optional full reference in **`.env`**; **`minimal`** and **`Traefik`** use **`${PGWD_IMAGE:-ghcr.io/hrodrig/pgwd:${PGWD_VERSION:-v0.5.10}}`**. Ansible template and **`hosts.yml.example`** support **`pgwd_image`**; **`run/common/.env.example`** and compose index README updated.
- **Compose — pgwd validation:** **minimal** stack defaults **`PGWD_DRY_RUN=true`** when unset so empty Slack/Loki does not cause a container **restart loop**. **Traefik** stack defaults **`PGWD_DRY_RUN=false`** — set **`PGWD_DRY_RUN=true`** or configure notifiers in **`.env`**. **`run/common/.env.example`**, minimal README, and Ansible **`env.compose.j2`** updated accordingly.
- **Ansible notification test:** **`docker exec -e PGWD_DRY_RUN=false`** so **`-force-notification`** still hits the mock when the long-running container uses dry-run (inherited env would otherwise skip sends).
- **`run/scripts/compose-stack.sh`** (stack **minimal**): if **`.env`** has no **`PGWD_DRY_RUN`** line and the shell variable is unset, **`export PGWD_DRY_RUN=true`** before **`docker compose`** so interpolation always enables dry-run without notifiers (helps hosts on an older `docker-compose.yml` missing the default).
- Root **`Makefile`**: bare **`make`** prints **help** only; run **`make test-compose-platforms`** explicitly for Ansible (avoids accidental full-cycle runs).

### Added

- **`testing/platforms/`** — Ansible playbooks (setup → minimal **compose** up → **healthz** → **per-host notification mock** + **`docker exec … -force-notification`** → teardown) and **`make test-compose-platforms`** for validating **Compose** on many VPS in parallel, analogous to **pgwd** **`make test-platforms`** but for **`run/docker-compose/minimal`**. See **[`testing/platforms/README.md`](testing/platforms/README.md)**; **`inventory/hosts.yml`** is gitignored (copy **`hosts.yml.example`**).

### Documentation

- **`testing/platforms/README.md`** — **Troubleshooting:** (1) Docker daemon / **DOCKER** NAT chain and kernel vs **`/lib/modules`** mismatch on **Arch** (reboot, **`nf_tables`**, reinstall **`iptables`**). (2) **`docker compose`** network create: **`DOCKER-FORWARD`** / **`No chain/target/match by that name`** — **`br_netfilter`**, **`bridge-nf-call-iptables`**, **`docker` restart**, verify iptables backend. (3) **Arch rolling** — **nft vs legacy** warning, inspect **`br-`** rules **with Compose up**, **Postgres** checks are not Arch-specific.
- **Docker / Compose:** [`run/docker-compose/README.md`](run/docker-compose/README.md) index; [`run/docker/README.md`](run/docker/README.md) one-shot **`docker run --rm`** with **`PGWD_INTERVAL=0`**; cross-links minimal / Traefik / observability / standalone cron; root README and [`run/README.md`](run/README.md); [`run/common/.env.example`](run/common/.env.example) points at compose index.
- **`run/scripts/compose-stack.sh`** — wrapper for **`docker compose`** on **minimal**, **Traefik**, and **observability** (`--env-file`, **`-f`**, project **`pgwd-obs`**); **`--traefik`** for the Grafana overlay. **[`run/scripts/README.md`](run/scripts/README.md)**; links from **`run/README.md`**, root **README**, **`docker-compose/README.md`**, and per-stack READMEs.

## [0.1.2] - 2026-04-06

### Changed

- Bump repository **`VERSION`** to **0.1.2** (badge, `AGENTS.md`). **Helm `Chart.yaml` `version`** remains **0.1.0** until the first chart publish (target **0.1.3** after further work).

### Documentation

- **Standalone:** [`run/standalone/README.md`](run/standalone/README.md) index; Linux / macOS / Windows guides with **`PGWD_HOST_DATA`**, **`PGWD_SQLITE_PATH`**, optional **`-config`**, and config-file vs env note; root README and [`run/README.md`](run/README.md) cross-links.
- **Standalone — cron / one-shot:** [Cron / one-shot (no daemon, no HTTP)](run/standalone/README.md#cron--one-shot-no-daemon-no-http) — `PGWD_INTERVAL=0`, omit `PGWD_HTTP_LISTEN`; linked from *BSD index and [`run/README.md`](run/README.md).
- **Standalone — architectures:** [CPU architectures (release binaries)](run/standalone/README.md#cpu-architectures-release-binaries) — `amd64` / `arm64` / `riscv64` matrix from [pgwd `.goreleaser.yaml`](https://github.com/hrodrig/pgwd/blob/main/.goreleaser.yaml); no SPARC; Solaris amd64-only; RISC-V not on DragonFly/macOS/Windows/Solaris in releases.
- **Standalone *BSD / Solaris:** [`run/standalone/bsd/`](run/standalone/bsd/README.md) (per-OS dirs); FreeBSD **`sysutils/pgwd`** / **`pkg install`**; [`run/standalone/solaris/README.md`](run/standalone/solaris/README.md) (illumos / Solaris **amd64**, SMF hints).
- **Standalone macOS:** [`run/standalone/macos/README.md`](run/standalone/macos/README.md) — **Homebrew** (`brew install hrodrig/pgwd/pgwd`) plus tarball path; shared **`PGWD_HOST_DATA`** section.

## [0.1.1] - 2026-04-06

### Changed

- Bump repository **`VERSION`** to **0.1.1** (badge, docs). **Helm `Chart.yaml` `version`** remains **0.1.0** until the first chart publish (planned after compose/standalone work, target **0.1.3**).

### Documentation

- Helm chart README and root README: `my-values.yaml` flow, **kubeVersion** `>=1.28.0`, canonical chart in this repo (no OCI chart from pgwd).
- **`values.yaml`**: comment aligning in-container paths with Compose **`PGWD_HOST_DATA`** / `/var/lib/pgwd`.

## [0.1.0] - 2026-04-03

### Added

- Initial repository: layout and docs modeled on **gghstats-selfhosted**, adapted for **[pgwd](https://github.com/hrodrig/pgwd)** (Postgres Watch Dog).
- **Compose:** minimal stack, Traefik + Let’s Encrypt (**`pgwd_edge`**), optional Prometheus / Grafana / Loki (**`pgwd-obs`**) with scrape target **`/api/pgwd/v1/metrics`**.
- **Shared env:** **`PGWD_HOST_DATA`**, **`PGWD_DB_URL`**, **`PGWD_VERSION`**, optional Slack/Loki variables ([`run/common/.env.example`](run/common/.env.example)).
- **Helm chart** at [`run/kubernetes/helm/pgwd`](run/kubernetes/helm/pgwd) (chart **`pgwd`**, sourced from upstream **contrib/helm/pgwd**).
- **Community / agent** docs carried over with project names updated (**`CONTRIBUTING.md`**, **`AGENTS.md`**, **`.cursor/rules`**, etc.).

[Unreleased]: https://github.com/hrodrig/pgwd-selfhosted/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/hrodrig/pgwd-selfhosted/releases/tag/v0.1.2
[0.1.1]: https://github.com/hrodrig/pgwd-selfhosted/releases/tag/v0.1.1
[0.1.0]: https://github.com/hrodrig/pgwd-selfhosted/releases/tag/v0.1.0

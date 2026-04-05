# Changelog

All notable changes to **pgwd-selfhosted** (deployment manifests, docs, and tooling for this repository only) are documented here. For the **pgwd** application, see [pgwd CHANGELOG](https://github.com/hrodrig/pgwd/blob/main/CHANGELOG.md).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-04-03

### Added

- Initial repository: layout and docs modeled on **gghstats-selfhosted**, adapted for **[pgwd](https://github.com/hrodrig/pgwd)** (Postgres Watch Dog).
- **Compose:** minimal stack, Traefik + Let’s Encrypt (**`pgwd_edge`**), optional Prometheus / Grafana / Loki (**`pgwd-obs`**) with scrape target **`/api/pgwd/v1/metrics`**.
- **Shared env:** **`PGWD_HOST_DATA`**, **`PGWD_DB_URL`**, **`PGWD_VERSION`**, optional Slack/Loki variables ([`run/common/.env.example`](run/common/.env.example)).
- **Helm chart** at [`run/kubernetes/helm/pgwd`](run/kubernetes/helm/pgwd) (chart **`pgwd`**, sourced from upstream **contrib/helm/pgwd**; icon URL points at this repo’s **`assets/`**).
- **Community / agent** docs carried over with project names updated (**`CONTRIBUTING.md`**, **`AGENTS.md`**, **`.cursor/rules`**, etc.).

[Unreleased]: https://github.com/hrodrig/pgwd-selfhosted/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hrodrig/pgwd-selfhosted/releases/tag/v0.1.0

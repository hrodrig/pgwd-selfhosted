# pgwd-selfhosted

[![Version](https://img.shields.io/badge/version-0.1.5-blue)](https://github.com/hrodrig/pgwd-selfhosted/releases)
[![Release](https://img.shields.io/github/v/release/hrodrig/pgwd-selfhosted?label=release)](https://github.com/hrodrig/pgwd-selfhosted/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![App image on GHCR](https://img.shields.io/badge/image-ghcr.io%2Fhrodrig%2Fpgwd-2496ED?logo=github)](https://github.com/hrodrig/pgwd/pkgs/container/pgwd)
[![pgwd app](https://img.shields.io/badge/app-hrodrig%2Fpgwd-181717?logo=github)](https://github.com/hrodrig/pgwd)

Deployment manifests for **[pgwd](https://github.com/hrodrig/pgwd)** — Compose, Helm, and **`docker run`**. **This repository is the home for all deployment-related work** (Kubernetes, Compose, runbooks). **[hrodrig/pgwd](https://github.com/hrodrig/pgwd)** is the **application** source, binaries, and container image only — the Helm chart is **not** in that repo on **`main`**; use **pgwd-selfhosted** (`run/kubernetes/helm/pgwd/`) or the future Helm repo on GitHub Pages.

**Releases:** Root **`VERSION`** and Git tags **`v<semver>`** on **`main`** name repository snapshots. Work in progress lands on **`develop`** first — for reproducible paths, prefer **`main`** or a **tag**, not unreviewed **`develop`**.

**Policies:** [Community and policies](#community-and-policies), [community standards](#community-standards) — changelog, contributing, security, code of conduct, agent guidelines.

---

## Table of contents

- [Pick a path](#pick-a-path)
- [Standalone binary](#standalone-binary)
- [Docker single container](#docker-single-container)
- [Docker Compose minimal](#docker-compose-minimal)
- [Kubernetes Helm](#kubernetes-helm)
- [Persistent data and secrets](#persistent-data-and-secrets)
- [Repository layout](#repository-layout)
- [Versioning](#versioning)
- [Community and policies](#community-and-policies)
- [Community standards](#community-standards)
- [License](#license)

---

## Pick a path

| You want… | Section |
|-----------|---------|
| **Binary only** (no Docker) | [Standalone binary](#standalone-binary) |
| **Single container** (`docker run`) | [Docker single container](#docker-single-container) |
| **Compose, one service** (quick VPS) | [Docker Compose minimal](#docker-compose-minimal) |
| **Kubernetes** | [Kubernetes Helm](#kubernetes-helm) |

Shared env template for Compose: copy **[`run/common/.env.example`](run/common/.env.example)** to **`${PGWD_HOST_DATA}/.env`**, set **`PGWD_HOST_DATA`** inside that file, and pass **`--env-file "${PGWD_HOST_DATA}/.env"`** to Compose. **Which Compose file?** **[`run/docker-compose/README.md`](run/docker-compose/README.md)**. Optional: **[`run/scripts/compose-stack.sh`](run/scripts/compose-stack.sh)** (`--help`). Deeper walkthroughs: **[`run/README.md`](run/README.md)**.

**[↑ Contents](#table-of-contents)**

---

## Standalone binary

**Goal:** run the app without Docker.

1. Download a release asset for your OS/arch from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract the binary. Prefer **state outside the download folder** — same idea as Compose **`PGWD_HOST_DATA`** (e.g. **`/home/pgwd/pgwd-data`** or **`${HOME}/pgwd-data`**):

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_INTERVAL=60
./pgwd
```

Published **`v0.5.10`** in this guide uses **environment variables**, **Postgres**, optional **Slack/Loki**, and **process output** for checks. Anything else — **[pgwd README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

**Stop:** `Ctrl+C`. Configuration: **[`contrib/pgwd.conf.example`](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)** and **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

**More:** **[`run/standalone/README.md`](run/standalone/README.md)** · [Linux](run/standalone/linux/README.md) · [macOS](run/standalone/macos/README.md) · [Windows](run/standalone/windows/README.md) · [*BSD](run/standalone/bsd/README.md) · [Solaris / illumos](run/standalone/solaris/README.md)

**Cron, no long-lived daemon:** **[Cron / one-shot](run/standalone/README.md#cron--one-shot-no-daemon)** (`PGWD_INTERVAL=0`).

**[↑ Contents](#table-of-contents)**

---

## Docker single container

**Goal:** one container, no Compose file.

**`v0.5.10`** on GHCR in this guide is driven by **environment variables** (see **[`run/docker/README.md`](run/docker/README.md)**).

```bash
docker run -d \
  --name pgwd \
  -e PGWD_DB_URL='postgres://user:pass@host:5432/dbname?sslmode=disable' \
  -e PGWD_INTERVAL=60 \
  ghcr.io/hrodrig/pgwd:v0.5.10
```

Use an image tag that exists on GHCR ([releases](https://github.com/hrodrig/pgwd/releases)); match **`PGWD_VERSION`** in [`run/common/.env.example`](run/common/.env.example). See **[`run/docker/README.md`](run/docker/README.md)** for optional notifiers, **`PGWD_DRY_RUN`**, and **[one-shot / `--rm`](run/docker/README.md#one-shot-container-no-daemon)**. **[Compose index](run/docker-compose/README.md)** when you need the minimal Compose layout.

**Check:** `docker logs pgwd` — look for **`total=`** / **`active=`** when Postgres is reachable.

**Remove:**

```bash
docker stop pgwd && docker rm pgwd
```

**More:** [run/docker/README.md](run/docker/README.md) · [Compose layouts](run/docker-compose/README.md)

**[↑ Contents](#table-of-contents)**

---

## Docker Compose minimal

**Goal:** quick stack from this repo (single service, GHCR image).

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
cp run/common/.env.example "${PGWD_HOST_DATA}/.env"
# Edit "${PGWD_HOST_DATA}/.env": PGWD_DB_URL, PGWD_VERSION, PGWD_HOST_DATA (same path as above), optional notifiers

docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml up -d
```

**Check:** `docker logs pgwd` — look for **`total=`** / **`active=`** when Postgres is reachable.

**Remove:**

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml down
```

**More:** [run/docker-compose/minimal/README.md](run/docker-compose/minimal/README.md) · [Compose index](run/docker-compose/README.md)

**[↑ Contents](#table-of-contents)**

---

## Kubernetes Helm

**Naming:** This GitHub repository is **`pgwd-selfhosted`** (deployment manifests). The Helm chart lives under **`run/kubernetes/helm/pgwd/`** — **`pgwd`** is the **chart name** (see **`Chart.yaml`**). **Chart development** happens **only** here; **[pgwd](https://github.com/hrodrig/pgwd)** does **not** include **`contrib/helm/pgwd`** on **`main`**. After the **first chart release**, packaged charts (**`pgwd-<chart-version>.tgz`**) and [**`index.yaml`**](https://hrodrig.github.io/pgwd-selfhosted/index.yaml) on GitHub Pages / [Releases](https://github.com/hrodrig/pgwd-selfhosted/releases) will follow [**CONTRIBUTING.md**](CONTRIBUTING.md). **Git tags** for this repo use **`v<semver>`** per **`VERSION`**.

**Install today (clone — no Helm repo required):**

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted
helm show values ./run/kubernetes/helm/pgwd > my-values.yaml
# Edit my-values.yaml — do not commit secrets to git (Postgres URL, Slack/Loki, image.tag, etc.).
helm upgrade --install pgwd ./run/kubernetes/helm/pgwd -n pgwd --create-namespace -f my-values.yaml
```

Quick **dry-run** try (DB URL + no notifier secrets): [run/kubernetes/helm/pgwd/README.md](run/kubernetes/helm/pgwd/README.md) · kind: **`make test-kind-postgres`** (Postgres only) or **`make test-helm-kind`** (+ Helm pgwd) — [testing/kind/README.md](testing/kind/README.md).

**After the first chart release (Helm repo on GitHub Pages):** when **`helm search repo pgwd`** works, you can install from the published index instead of the chart path:

```bash
helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted
helm repo update
helm search repo pgwd -l
helm show values pgwd/pgwd --version 0.1.5 > my-values.yaml
# Edit my-values.yaml — do not commit secrets to git.
helm upgrade --install pgwd pgwd/pgwd --version 0.1.5 -n pgwd --create-namespace -f my-values.yaml
```

Use the **`version:`** from **`helm search`** once **`index.yaml`** is live (it may differ from **`0.1.5`**). If **`helm repo add`** or search fails, the repo may not be published yet — use the clone path above.

Full options: [run/kubernetes/helm/pgwd/README.md](run/kubernetes/helm/pgwd/README.md).

**Secrets (recommended):** do **not** put **`postgres://`** URLs or webhooks in shell history. Prefer **`secrets.existingSecret`** with keys **`url`**, **`slack-webhook`**, **`loki-url`** (see **`secrets`** in [`values.yaml`](run/kubernetes/helm/pgwd/values.yaml)):

```bash
kubectl create namespace pgwd
kubectl create secret generic pgwd-secrets \
  -n pgwd \
  --from-literal=url='postgres://user:pass@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable' \
  --from-literal=slack-webhook='https://hooks.slack.com/services/...' \
  --from-literal=loki-url='http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push'
```

Then in **`my-values.yaml`**: set **`secrets.create: false`**, **`secrets.existingSecret: pgwd-secrets`**, and keep **`env.PGWD_*`** for non-secret settings (interval, log level, etc.).

You may use **`config.enabled: true`** for a full config file (`db:` + notifications, etc.); see the chart **[README](run/kubernetes/helm/pgwd/README.md)**.

See [`values.yaml`](run/kubernetes/helm/pgwd/values.yaml) in-tree for defaults.

**Check:** `kubectl get pods -n pgwd -l app.kubernetes.io/name=pgwd` and **`kubectl logs`** for Postgres stats lines.

**Remove:**

```bash
helm uninstall pgwd -n pgwd
```

**More:** [run/kubernetes/helm/pgwd/README.md](run/kubernetes/helm/pgwd/README.md) · [run/kubernetes/manifests](run/kubernetes/manifests/README.md)

**[↑ Contents](#table-of-contents)**

---

## Persistent data and secrets

*Recommended on servers:* colocate env files (and any local state) outside the clone (see below).

Keep **`${PGWD_HOST_DATA}/.env`** in one host directory (e.g. `/home/pgwd/pgwd-data/`). Set **`PGWD_HOST_DATA`** inside that file to that absolute path. Run Compose from the clone root with **`--env-file "${PGWD_HOST_DATA}/.env"`**. See [`run/common/.env.example`](run/common/.env.example). Optional helper: **[`run/scripts/compose-stack.sh`](run/scripts/compose-stack.sh)** (`./run/scripts/compose-stack.sh --help`).

**[↑ Contents](#table-of-contents)**

---

## Repository layout

```text
run/
├── common/.env.example          # Shared vars for Compose + image tag
├── scripts/                     # compose-stack.sh (docker compose helper)
├── standalone/README.md         # Index; linux, macos, windows, solaris/, bsd/{freebsd,openbsd,netbsd,dragonfly}/
├── docker/                      # docker run
├── docker-compose/
│   ├── README.md            # minimal
│   └── minimal/
└── kubernetes/
    ├── helm/pgwd/           # Helm chart named "pgwd" (app); not the repo name
    └── manifests/
```

**[↑ Contents](#table-of-contents)**

---

## Versioning

- **[`VERSION`](VERSION)** — semver of **this repository** (Compose, docs, `run/`, etc.). When you change it, align the **Version** badge in this README and (if you keep a release entry) **CHANGELOG.md**; on **`main`**, tag with **`v<semver>`** (e.g. `v0.2.0`). This number is **not** tied to the Helm chart on every bump.
- **Helm chart (`run/kubernetes/helm/pgwd/Chart.yaml` → `version:`)** — semver of the **chart package** published to [GitHub Pages](https://hrodrig.github.io/pgwd-selfhosted/index.yaml) / [Releases](https://github.com/hrodrig/pgwd-selfhosted/releases). Bump **`version:`** when the chart itself changes (templates, `values`, etc.). It may **lag** behind **`VERSION`** (e.g. repo `0.2.0`, chart `0.1.5` until you edit the chart). [chart-releaser](https://github.com/helm/chart-releaser) may skip publishing if **`run/kubernetes/helm/`** did not change — expected for docs-only repo releases.
- **`Chart.yaml` → `appVersion`** — **pgwd** application / image line; align with [pgwd releases](https://github.com/hrodrig/pgwd/releases) when you bump the deployed image story.
- **`PGWD_VERSION`** in **`${PGWD_HOST_DATA}/.env`** (or the env file you pass to Compose) — **container image** tag on GHCR ([pgwd releases](https://github.com/hrodrig/pgwd/releases)), not the same as **`VERSION`**.

**[↑ Contents](#table-of-contents)**

---

## Community and policies

| Document | Purpose |
|----------|---------|
| **[CHANGELOG.md](CHANGELOG.md)** | Release history and notable changes to **this** repository (manifests, docs, layout). |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | How to open issues/PRs, branch policy (`develop` → `main`), and checks before submitting. |
| **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** | Community standards (Contributor Covenant). |
| **[SECURITY.md](SECURITY.md)** | How to report security vulnerabilities responsibly. |
| **[AGENTS.md](AGENTS.md)** | Guidelines for AI coding agents (Cursor, etc.) working in this repo. |

**Application** issues (bugs, features in the Go app or UI) belong in **[pgwd](https://github.com/hrodrig/pgwd)** — not here.

**[↑ Contents](#table-of-contents)**

---

## Community standards

- License: [`LICENSE`](LICENSE)
- Contributing: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Code of conduct: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
- Security policy: [`SECURITY.md`](SECURITY.md)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)
- Agent guidelines: [`AGENTS.md`](AGENTS.md)

Thanks for self-hosting **[pgwd](https://github.com/hrodrig/pgwd)** with these manifests. We would love to hear how **easy or difficult** it was to run **pgwd** self-hosted (Compose, Helm, `docker run`, or anything in [`run/`](run/)). Share feedback in **[GitHub Issues](https://github.com/hrodrig/pgwd-selfhosted/issues)** or, if enabled for this repository, **Discussions**.

**[↑ Contents](#table-of-contents)**

---

## License

MIT — see [LICENSE](LICENSE).

**[↑ Contents](#table-of-contents)**

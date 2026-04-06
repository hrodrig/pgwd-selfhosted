# pgwd-selfhosted

[![Version](https://img.shields.io/badge/version-0.1.1-blue)](https://github.com/hrodrig/pgwd-selfhosted/releases)
[![Release](https://img.shields.io/github/v/release/hrodrig/pgwd-selfhosted?label=release)](https://github.com/hrodrig/pgwd-selfhosted/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![App image on GHCR](https://img.shields.io/badge/image-ghcr.io%2Fhrodrig%2Fpgwd-2496ED?logo=github)](https://github.com/hrodrig/pgwd/pkgs/container/pgwd)
[![pgwd app](https://img.shields.io/badge/app-hrodrig%2Fpgwd-181717?logo=github)](https://github.com/hrodrig/pgwd)

Deployment manifests for **[pgwd](https://github.com/hrodrig/pgwd)** — Compose, Helm, `docker run`, optional observability. **App source and releases:** [github.com/hrodrig/pgwd](https://github.com/hrodrig/pgwd).

> **Work in progress — not stable yet.** This repo is under active development. Treat it as **experimental** until work is **merged into `main`** and you follow tagged releases or the project explicitly marks a stable cut. Do not assume production readiness from `develop` alone.

**Policies:** [Community and policies](#community-and-policies), [community standards](#community-standards) — changelog, contributing, security, code of conduct, agent guidelines.

---

## Table of contents

- [Pick a path](#pick-a-path)
- [Standalone binary](#standalone-binary)
- [Docker single container](#docker-single-container)
- [Docker Compose minimal](#docker-compose-minimal)
- [Docker Compose Traefik HTTPS](#docker-compose-traefik-https)
- [Observability optional](#observability-optional)
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
| **HTTPS + domain** (Traefik + Let’s Encrypt) | [Docker Compose Traefik HTTPS](#docker-compose-traefik-https) |
| **Prometheus / Grafana / Loki** (after Traefik) | [Observability optional](#observability-optional) |
| **Kubernetes** | [Kubernetes Helm](#kubernetes-helm) |

Shared env template for Compose: copy **[`run/common/.env.example`](run/common/.env.example)** to **`${PGWD_HOST_DATA}/.env`**, set **`PGWD_HOST_DATA`** inside that file, and pass **`--env-file "${PGWD_HOST_DATA}/.env"`** to Compose. Deeper walkthroughs: **[`run/README.md`](run/README.md)**.

**[↑ Contents](#table-of-contents)**

---

## Standalone binary

**Goal:** run the app without Docker.

1. Download a release asset for your OS/arch from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract the binary, then:

```bash
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_INTERVAL=60
export PGWD_HTTP_LISTEN=:8080   # optional: health + /api/pgwd/v1/metrics
./pgwd
```

**Check:** with HTTP enabled, **`curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/api/pgwd/v1/healthz`** (expect **`200`**).

**Stop:** `Ctrl+C`. Configuration: **[`contrib/pgwd.conf.example`](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)** and **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

**More:** [run/standalone/linux](run/standalone/linux/README.md) · [macos](run/standalone/macos/README.md) · [windows](run/standalone/windows/README.md)

**[↑ Contents](#table-of-contents)**

---

## Docker single container

**Goal:** one container, no Compose file.

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"

docker run -d \
  -e PGWD_DB_URL='postgres://user:pass@host:5432/dbname?sslmode=disable' \
  -e PGWD_HTTP_LISTEN=0.0.0.0:8080 \
  -e PGWD_SQLITE_PATH=/var/lib/pgwd/pgwd.db \
  -p 8080:8080 \
  -v "${PGWD_HOST_DATA}:/var/lib/pgwd" \
  --name pgwd \
  ghcr.io/hrodrig/pgwd:v0.5.10
```

Use an image tag that exists on GHCR ([releases](https://github.com/hrodrig/pgwd/releases)); match **`PGWD_VERSION`** in [`run/common/.env.example`](run/common/.env.example). See also **[`run/docker/README.md`](run/docker/README.md)** for a fuller **`docker run`** example.

**Check:** `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/api/pgwd/v1/healthz` (expect **`200`**).

**Remove:**

```bash
docker stop pgwd && docker rm pgwd
```

**More:** [run/docker/README.md](run/docker/README.md)

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

**Check:** `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:${PGWD_HOST_PORT:-8080}/api/pgwd/v1/healthz` (expect **`200`**).

**Remove:**

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml down
```

**More:** [run/docker-compose/minimal/README.md](run/docker-compose/minimal/README.md)

**[↑ Contents](#table-of-contents)**

---

## Docker Compose Traefik HTTPS

**Goal:** production-style TLS on your domain (ports **80** / **443**).

**Prerequisites:** DNS **A/AAAA** for `PGWD_HOSTNAME` → this host; **80** and **443** reachable.

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
cp run/common/.env.example "${PGWD_HOST_DATA}/.env"
# Edit "${PGWD_HOST_DATA}/.env": PGWD_DB_URL, PGWD_HOSTNAME, ACME_EMAIL, PGWD_UID, PGWD_GID,
# PGWD_VERSION, and PGWD_HOST_DATA (same absolute path as above — SQLite lives next to this file)

docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/traefik/docker-compose.yml up -d
```

**Check:** `curl -sS -o /dev/null -w '%{http_code}\n' https://your-hostname/` after DNS and TLS succeed.

**Remove:**

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/traefik/docker-compose.yml down
```

**More:** [run/docker-compose/traefik/README.md](run/docker-compose/traefik/README.md)

**[↑ Contents](#table-of-contents)**

---

## Observability optional

**Goal:** Prometheus, Grafana, Loki, etc. **Requires** the Traefik stack above so network **`pgwd_edge`** exists. Use the **same** **`PGWD_HOST_DATA`** as your main **`${PGWD_HOST_DATA}/.env`** (SQLite and secrets in one host directory).

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
cp run/docker-compose/observability/observability.env.example "${PGWD_HOST_DATA}/.env.observability"
# Edit "${PGWD_HOST_DATA}/.env.observability" — set GRAFANA_ADMIN_PASSWORD at minimum (must match PGWD_HOST_DATA used for Traefik / main .env)
```

**Expose Grafana on HTTPS via Traefik (public hostname)** — use this if you want Grafana on the internet with the **same** Traefik / Let’s Encrypt as pgwd (recommended once DNS is ready):

1. In **`"${PGWD_HOST_DATA}/.env.observability"`**, set a dedicated FQDN and matching root URL (must match what users open in the browser):

   ```bash
   GRAFANA_HOSTNAME=pgwd-obs.example.com
   GRAFANA_ROOT_URL=https://pgwd-obs.example.com
   ```

2. **DNS:** point **`GRAFANA_HOSTNAME`** to this host (A/AAAA or CNAME), same idea as **`PGWD_HOSTNAME`** for the main app.

3. Start the stack with **both** Compose files (the second file adds Traefik **labels** only; it does not add another Traefik container). Use **both** `-f` lines on every `up` / `pull` / `down` that recreates Grafana, or HTTPS routing breaks until you fix it.

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env.observability" -p pgwd-obs \
  -f run/docker-compose/observability/docker-compose.observability.yml \
  -f run/docker-compose/observability/docker-compose.observability.traefik.yml \
  up -d
```

**Local / LAN only (no Traefik route for Grafana)** — Grafana on **`http://localhost:${GRAFANA_PORT:-3000}`**; omit **`docker-compose.observability.traefik.yml`**:

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env.observability" -p pgwd-obs \
  -f run/docker-compose/observability/docker-compose.observability.yml up -d
```

**Check / troubleshoot / SSH tunnel:** **[run/docker-compose/observability/README.md](run/docker-compose/observability/README.md)** (curl checks, `down -v`).

**Remove (containers + stack volumes):** use the **same** `-f` list you used for `up`. Examples:

```bash
# If you started with Traefik overlay (two files), remove with two files:
docker compose --env-file "${PGWD_HOST_DATA}/.env.observability" -p pgwd-obs \
  -f run/docker-compose/observability/docker-compose.observability.yml \
  -f run/docker-compose/observability/docker-compose.observability.traefik.yml \
  down -v

# If you started with only the base file:
docker compose --env-file "${PGWD_HOST_DATA}/.env.observability" -p pgwd-obs \
  -f run/docker-compose/observability/docker-compose.observability.yml down -v
```

**[↑ Contents](#table-of-contents)**

---

## Kubernetes Helm

**Install** from the **Helm repository** on **GitHub Pages** ([**`index.yaml`**](https://hrodrig.github.io/pgwd-selfhosted/index.yaml); chart packages are attached to [GitHub Releases](https://github.com/hrodrig/pgwd-selfhosted/releases) as **`pgwd-<version>.tgz`**). The chart is maintained and published **here**, not from the [pgwd](https://github.com/hrodrig/pgwd) application repository.

**GitHub Pages:** The [Pages URL](https://hrodrig.github.io/pgwd-selfhosted/) serves **`index.yaml`** for Helm and includes a short **HTML landing** for humans. **`helm repo add`** only needs the HTTPS base URL — you do not have to open the site in a browser.

**Naming (this repo vs the chart):** This GitHub repository is **`pgwd-selfhosted`** (deployment manifests only). The Helm chart lives under **`run/kubernetes/helm/pgwd/`** — **`pgwd`** is the **chart name** (see `name:` in **`Chart.yaml`**). Published chart packages use **`pgwd-<chart-version>.tgz`**; **Git tags** for this repo use **`v<semver>`** (e.g. **`v0.1.1`**) per **`VERSION`**.

Generate **`my-values.yaml`** from the published chart (defaults), **edit** it for your cluster (Postgres URL, Slack/Loki, **`image.tag`** to match a [pgwd release](https://github.com/hrodrig/pgwd/releases), resources, etc.), then install:

```bash
helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted
helm repo update
helm search repo pgwd -l
helm show values pgwd/pgwd --version 0.1.0 > my-values.yaml
# Edit my-values.yaml — do not commit secrets to git.
helm install pgwd pgwd/pgwd --version 0.1.0 -n pgwd --create-namespace -f my-values.yaml
```

Use the **`version:`** shown in **`helm search`** if it differs from **`0.1.0`**. Full options: [run/kubernetes/helm/pgwd/README.md](run/kubernetes/helm/pgwd/README.md).

**Secrets (recommended):** do **not** put **`postgres://`** URLs or webhooks in shell history. Prefer **`secrets.existingSecret`** with keys **`url`**, **`slack-webhook`**, **`loki-url`** (see **`secrets`** in [`values.yaml`](run/kubernetes/helm/pgwd/values.yaml)):

```bash
kubectl create namespace pgwd
kubectl create secret generic pgwd-secrets \
  -n pgwd \
  --from-literal=url='postgres://user:pass@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable' \
  --from-literal=slack-webhook='https://hooks.slack.com/services/...' \
  --from-literal=loki-url='http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push'
```

Then in **`my-values.yaml`**: set **`secrets.create: false`**, **`secrets.existingSecret: pgwd-secrets`**, and keep **`env.PGWD_*`** for non-secret settings (interval, log level, HTTP listen, etc.).

You may use **`config.enabled: true`** for multiple databases (see chart **[README](run/kubernetes/helm/pgwd/README.md)**).

If **`helm repo add`** fails (network, Pages outage, or first minutes after a new release), try again later or install **from this repository** below.

**From this repository (sources, templates, contributing):** the chart under **`run/kubernetes/helm/pgwd/`** is the same chart; clone it to inspect YAML, open issues, or install without the published repo:

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted
helm show values ./run/kubernetes/helm/pgwd > my-values.yaml
# Edit my-values.yaml — do not commit secrets to git.
helm install pgwd ./run/kubernetes/helm/pgwd -n pgwd --create-namespace -f my-values.yaml
```

See **[`values.yaml`](run/kubernetes/helm/pgwd/values.yaml)** in-tree for defaults.

**Check:** `kubectl get pods -n pgwd -l app.kubernetes.io/name=pgwd` and the Service (e.g. **`kubectl get svc -n pgwd`**) if you expose HTTP/metrics.

**Remove:**

```bash
helm uninstall pgwd -n pgwd
```

**More:** [run/kubernetes/helm/pgwd/README.md](run/kubernetes/helm/pgwd/README.md) · [run/kubernetes/manifests](run/kubernetes/manifests/README.md)

**[↑ Contents](#table-of-contents)**

---

## Persistent data and secrets

*Recommended on servers:* colocate SQLite and env files outside the clone (see below).

Keep **SQLite**, **`${PGWD_HOST_DATA}/.env`**, and **`${PGWD_HOST_DATA}/.env.observability`** in one host directory (e.g. `/home/pgwd/pgwd-data/`). Set **`PGWD_HOST_DATA`** inside the main **`.env`** to that absolute path. Run Compose from the clone root with **`--env-file "${PGWD_HOST_DATA}/.env"`** for the app stacks and **`--env-file "${PGWD_HOST_DATA}/.env.observability"`** for observability (`-p pgwd-obs`). See [`run/common/.env.example`](run/common/.env.example) and [`run/docker-compose/observability/observability.env.example`](run/docker-compose/observability/observability.env.example).

**[↑ Contents](#table-of-contents)**

---

## Repository layout

```text
run/
├── common/.env.example          # Shared vars for Compose + image tag
├── standalone/{linux,macos,windows}/
├── docker/                      # docker run
├── docker-compose/
│   ├── minimal/
│   ├── traefik/
│   └── observability/
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

Thanks for self-hosting **[pgwd](https://github.com/hrodrig/pgwd)** with these manifests. We would love to hear how **easy or difficult** it was to run **pgwd** self-hosted (Compose, Helm, `docker run`, observability, or anything in [`run/`](run/)). Share feedback in **[GitHub Issues](https://github.com/hrodrig/pgwd-selfhosted/issues)** or, if enabled for this repository, **Discussions**.

**[↑ Contents](#table-of-contents)**

---

## License

MIT — see [LICENSE](LICENSE).

**[↑ Contents](#table-of-contents)**

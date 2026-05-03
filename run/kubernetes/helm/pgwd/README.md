# Helm chart: pgwd

← [Back to run/README](../../../README.md).

This chart installs **[pgwd](https://github.com/hrodrig/pgwd)** (Postgres Watch Dog) from the published container image — monitor PostgreSQL connections and notify via Slack/Loki. **pgwd 0.6+** can use **SQLite** for check history (hysteresis, resolution alerts), expose **`/healthz`** and Prometheus **`/metrics`** over HTTP, and use **`databases:`** for multiple direct URLs — configure via **`config.extra`** or **`env`** (see upstream [README](https://github.com/hrodrig/pgwd/blob/main/README.md)).

By default the chart creates a **ClusterIP Service** (`service.enabled`, `http.enabled`) on port **8080** and **HTTP probes** on **`/api/pgwd/v1/healthz`**. Set **`service.annotations`** for Prometheus scrape hints (or use a **ServiceMonitor** from your stack). Optional **`persistence.enabled`** provisions a **PVC** (ReadWriteOnce) for SQLite at **`persistence.mountPath`** — keep **`replicaCount: 1`**. With **`config.enabled: true`**, define matching **`http:`** and **`sqlite.path`** in **`config.extra`** (the chart does not inject **`PGWD_HTTP_*`** / **`PGWD_SQLITE_PATH`** in that mode).

**Path vs repository name:** In a clone of **[pgwd-selfhosted](https://github.com/hrodrig/pgwd-selfhosted)**, this chart lives under **`run/kubernetes/helm/pgwd/`**. The segment **`pgwd`** is the **Helm chart name** (matches **`name:`** in **`Chart.yaml`**) and the workload it deploys — not the GitHub repository name (**`pgwd-selfhosted`**). This mirrors **[gghstats-selfhosted](https://github.com/hrodrig/gghstats-selfhosted)** / **`run/kubernetes/helm/gghstats`**.

**Deployment vs application repo:** **All deployment-related work** for pgwd (Helm, Compose layouts, runbooks in **`run/`**, chart CI) lives in **pgwd-selfhosted**. **[hrodrig/pgwd](https://github.com/hrodrig/pgwd)** is only the **Go application**, binary releases, and container image — it does **not** ship this Helm chart on **`main`** (any old **`contrib/helm/pgwd`** path is gone). **`run/kubernetes/helm/pgwd/`** here is the **only** supported chart source until the packaged repo exists. [pgwd **Releases**](https://github.com/hrodrig/pgwd/releases) are **binary / container** **`v*`** tags; the **Helm package index** for installs without a clone is planned on **pgwd-selfhosted** (GitHub Pages) after the first chart release.

**Helm repo (after first chart release):** Once **`index.yaml`** is published on GitHub Pages, **`helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted`** uses **`pgwd`** as the local repo name so **`helm upgrade --install … pgwd/pgwd`** reads as *repo/chart*. The same base URL serves a short **browser landing page** (static `index.html` from **`run/kubernetes/helm/helm-repo-landing/`**, synced by **Release Charts** to **`gh-pages`**). Until the index is live, install from a **clone** (sections below). See **[CONTRIBUTING.md](../../../../CONTRIBUTING.md)** for the chart publish flow.

## Prerequisites

- Helm 3
- Kubernetes 1.28+ (see **`kubeVersion`** in **`Chart.yaml`**; CI validates manifests against 1.30 schemas)
- PostgreSQL accessible from within the cluster (in-cluster DNS)

## Values schema

The chart includes **`values.schema.json`**. **`helm lint`**, **`helm install`**, and **`helm upgrade`** validate merged values: disallowed top-level keys, **`replicaCount`** below 1, invalid **`image.pullPolicy`**, wrong shape for **`env.*`** (string or **`secretKeyRef`** object), and non-empty **`config.extra`** when **`config.enabled`** is **`true`**. CI runs **`helm lint`** on default **`values.yaml`** and on **`values-config-mode.yaml`** merged on top.

## Installation

For any install that uses **`-f my-values.yaml`**, generate defaults first, then edit for your cluster (database URL, Slack/Loki, resources, namespace, etc.):

```bash
# From a clone (chart directory — no packaged version needed):
helm show values ./run/kubernetes/helm/pgwd > my-values.yaml

# From the Helm repo after first chart publish (use chart semver from Chart.yaml / helm search):
helm show values pgwd/pgwd --version <chart-version> > my-values.yaml
```

This repo (**[pgwd-selfhosted](https://github.com/hrodrig/pgwd-selfhosted)**) is the **source of truth** for the chart; a **packaged Helm repo** on GitHub Pages is **planned** (not required to install today). The **container image** is **`ghcr.io/hrodrig/pgwd`** from [pgwd releases](https://github.com/hrodrig/pgwd/releases). **Registry tags use the same form as Git tags** (e.g. **`v0.6.4`**); a tag like **`0.6.0`** (no `v`) will **not** resolve on GHCR. Set **`image.tag`** in values to the published tag you want.

### Secrets

Before **`helm upgrade --install`**, decide how you store credentials: the chart can create a Kubernetes **Secret** from **`secrets.dbUrl`** (Postgres URL) and optional **`secrets.slackWebhook`** / **`secrets.lokiUrl`**. Alternatively set **`secrets.existingSecret`** to a Secret you manage (e.g. Sealed Secrets, External Secrets). For **production**, prefer **`--set-file`**, a private values file, or your secret manager — avoid pasting credentials on a shared shell history.

**`secrets.existingSecret`:** when this name is set, the Deployment still mounts **`PGWD_NOTIFICATIONS_*`** from the same Secret whenever the chart would inject notifier env vars. The Secret should include keys **`url`**, **`slack-webhook`**, and **`loki-url`** (Kubernetes does not create optional keys — use empty **`stringData`** values for notifiers you do not use, or the pod may stay **`CreateContainerConfigError`**).

### From this repository (pgwd-selfhosted sources) — default install path

The smallest install that works **out of the box** needs only a database URL. **`PGWD_DRY_RUN=true`** is a **smoke test**: pgwd connects and evaluates thresholds, but it does **not** send Slack or Loki (you can omit notifier secrets). **To receive real alerts**, run a follow-up install (or start from a full values file) with **`env.PGWD_DRY_RUN=false`** and your **real** **`secrets.slackWebhook`** and/or **`secrets.lokiUrl`** (or the matching **`PGWD_*`** env vars if you inject them another way). If dry-run stays on or notifiers are unset, **no notifications will be delivered**.

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted

export PASSWORD=password
export HOST=postgres.default.svc.cluster.local
export DB=mydb
export NAMESPACE=pgwd
export RELEASE_NAME=pgwd
# Webhook for the one-off exec test below (keep private; do not commit).
export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/...'

helm upgrade --install ${RELEASE_NAME} ./run/kubernetes/helm/pgwd \
  -n ${NAMESPACE} --create-namespace \
  --set secrets.dbUrl="postgres://postgres:${PASSWORD}@${HOST}:5432/${DB}?sslmode=disable" \
  --set env.PGWD_DRY_RUN=true \
  --set env.PGWD_CLIENT="pgwd-demo"

# One-off Slack test from inside the pod (inherits PGWD_* from the Deployment, overrides notifier + dry-run).
kubectl exec -n ${NAMESPACE} deploy/${RELEASE_NAME} -- sh -c "
export PGWD_NOTIFICATIONS_SLACK_WEBHOOK=\"${SLACK_WEBHOOK_URL}\"
export PGWD_FORCE_NOTIFICATION=true
export PGWD_DRY_RUN=false
export PGWD_INTERVAL=0
exec /home/pgwd/pgwd
"
```

Example **Slack** message (**pgwd** `v0.6.4`, test notification / delivery check):

![Slack incoming webhook: pgwd force-notification test](../../../../assets/pgwd-slack-force-notification.png)

For **kind** validation: **`make test-kind-postgres`** (Postgres only) or **`make test-helm-kind`** (Postgres + this chart + log-based Postgres check) — see **[testing/kind/README.md](../../../../testing/kind/README.md)**.

Replace the Postgres URL with one reachable from pods in the **`pgwd`** namespace.

**Live alerts:** same ideas as in the **smoke test** paragraph above (disable dry-run; set real **`secrets.slackWebhook`** / **`secrets.lokiUrl`**). Example second install with the same release and namespace:

```bash
helm upgrade --install pgwd ./run/kubernetes/helm/pgwd \
  -n pgwd \
  --set secrets.dbUrl="postgres://user:pass@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable" \
  --set secrets.slackWebhook="https://hooks.slack.com/services/..." \
  --set secrets.lokiUrl="http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push" \
  --set env.PGWD_DRY_RUN=false
```

*(`loki.monitoring.svc...` is an example: Loki often runs in **`monitoring`**, not the pgwd namespace.)*

For production, use **`--set-file`** or a values file instead of passing secrets on the command line.

### From Helm repository (GitHub Pages, after first chart release)

When **[release-charts](https://github.com/hrodrig/pgwd-selfhosted/blob/develop/.github/workflows/release-charts.yml)** has published **`index.yaml`** and chart **`*.tgz`** artifacts, install from the repo using the **`version:`** in **`Chart.yaml`** (e.g. **`0.1.8`** — chart semver, not the pgwd app release):

```bash
helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted
helm repo update
helm show values pgwd/pgwd --version 0.1.8 > my-values.yaml
# Edit my-values.yaml for your environment.
helm upgrade --install pgwd pgwd/pgwd --version 0.1.8 -n pgwd --create-namespace -f my-values.yaml
```

If **`helm repo add`** or **`helm search`** fails, **`index.yaml`** may not be live yet — use **From this repository** above. Confirm versions with **`helm search repo pgwd -l`** once the index exists.

## Configuration modes

### Env vars (default)

Use `secrets.dbUrl`, `secrets.slackWebhook`, `secrets.lokiUrl` and `env.*` when **`config.enabled`** is **`false`** (default). Secrets are created from values (or reference `secrets.existingSecret`).

```yaml
# values.yaml
secrets:
  create: true
  dbUrl: "postgres://user:pass@postgres.default.svc.cluster.local:5432/mydb"
  slackWebhook: "https://hooks.slack.com/..."
  lokiUrl: "http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"

env:
  PGWD_CLIENT: "pgwd-prod"
  PGWD_INTERVAL: "60"
  PGWD_DRY_RUN: "true"  # set "false" when Slack/Loki are configured and you want live alerts
```

### Config file

Set `config.enabled: true` and provide full YAML in `config.extra` using the pgwd file schema (for example `db:` for the Postgres URL and thresholds, `notifications:` for Slack/Loki). Match field names and structure to the **pgwd image tag** you run (see **`internal/config/file.go`** / **`contrib/pgwd.conf.example`** upstream). Example overlay: **[`values-config-mode.yaml`](values-config-mode.yaml)** (`helm upgrade … -f values-config-mode.yaml`).

**Note:** When using a config file, env vars are ignored by pgwd.

### Config file + persistence (PVC)

When **`config.enabled`** and **`persistence.enabled`** are both **`true`**, pgwd loads **`PGWD_CONFIG`** (e.g. `/etc/pgwd/pgwd.conf` from the chart ConfigMap). In that path, upstream pgwd applies **`config.FromFile`**: if the file exists and parses, **`PGWD_*` environment variables are not applied** — the YAML file is the single source of truth (see **`FromFile`** in [internal/config/file.go](https://github.com/hrodrig/pgwd/blob/main/internal/config/file.go) and **`loadAndParseConfig`** in [cmd/pgwd/main.go](https://github.com/hrodrig/pgwd/blob/main/cmd/pgwd/main.go)). So **`PGWD_SQLITE_PATH` would not override `sqlite.path`** even if the Deployment set it; the chart does not inject **`PGWD_SQLITE_PATH`** in config mode for that reason.

Set **`sqlite.path`** inside **`config.extra`** to an absolute path **on the writable volume**, typically under **`persistence.mountPath`**, e.g. **`/var/lib/pgwd/metrics.db`** when **`mountPath`** is **`/var/lib/pgwd`** and **`sqliteFile`** is **`metrics.db`**. If you use **`persistence.subPath`**, **`sqlite.path`** must still resolve to a file visible at the container mount (under that mount point). Pointing **`sqlite.path`** at ephemeral paths (e.g. under **`/tmp`**) defeats persistence across pod restarts.

**Multi-database (`databases:` in `config.extra`):** The same rules apply as in upstream pgwd: **`databases:`** is for **direct** Postgres URLs only — **not** together with **`kube.postgres`** / **`-kube-postgres`** in that process. Persisted metrics and hysteresis key rows by **`(client, cluster, database)`** (hostname from the URL is **not** part of the key); set a **distinct `client` per `databases:` entry** when several hosts use the same database name. See **[Multi-database limitations](https://github.com/hrodrig/pgwd/blob/main/README.md#multi-database-limitations)**.

```yaml
# values.yaml
config:
  enabled: true
  extra: |
    client: pgwd-k8s
    interval: 60
    db:
      url: postgres://user:pass@postgres.default.svc.cluster.local:5432/prod
      threshold:
        levels: "75,85,95"
    notifications:
      slack:
        webhook: "https://hooks.slack.com/..."
      loki:
        url: "http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"

secrets:
  create: false  # URLs and webhooks are in config
```

For sensitive values in config mode, use [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) or [External Secrets](https://external-secrets.io/) to create a Secret with the config file, then mount it manually or extend the chart.

## Values reference

This table lists the main knobs; the full key set (**`resources.limits`**, **`affinity`**, **`nodeSelector`**, every **`env`** key, etc.) is in **`values.yaml`** next to this README.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/hrodrig/pgwd` |
| `image.tag` | Image tag (must match ghcr, e.g. `v0.6.4`) | `v0.6.4` |
| `secrets.create` | Create Secret from values | `true` |
| `secrets.dbUrl` | Postgres connection URL | `""` |
| `secrets.slackWebhook` | Slack webhook URL | `""` |
| `secrets.lokiUrl` | Loki push URL | `""` |
| `secrets.existingSecret` | Use existing Secret name | `""` |
| `config.enabled` | Use config file instead of env | `false` |
| `config.extra` | Full pgwd YAML config | See values.yaml |
| `env.PGWD_LOG_LEVEL` | Log level: `info` or `debug` (debug = verbose dry-run stats) | `info` |
| `http.enabled` | Expose HTTP server; set `PGWD_HTTP_LISTEN` when `config.enabled=false` | `true` |
| `http.listen` / `containerPort` | Listen address and container port (must align) | `":8080"` / `8080` |
| `http.basePath` / `healthPath` | With `metricsPath`, must match pgwd config and probes | defaults match upstream |
| `http.probes` | Liveness/readiness HTTP GET on health path | enabled |
| `service.enabled` | Create `Service` for probes and Prometheus scrape | `true` (with `http.enabled`) |
| `service.type` / `service.port` | Service type and port | `ClusterIP` / `8080` |
| `service.annotations` | e.g. `prometheus.io/scrape` | `{}` |
| `persistence.enabled` | Create PVC and mount for SQLite (`replicaCount: 1`) | `false` |
| `persistence.size` / `storageClass` / `accessMode` | PVC spec | `1Gi` / `""` / `ReadWriteOnce` |
| `persistence.mountPath` / `sqliteFile` | Mount path and filename; env `PGWD_SQLITE_PATH` when env mode | `/var/lib/pgwd` / `metrics.db` |
| `resources.requests` | CPU/memory requests | `10m/32Mi` |

## Uninstall

```bash
helm uninstall pgwd -n pgwd
```

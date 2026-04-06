# Helm chart: pgwd

← [Back to run/README](../../../README.md).

This chart installs **[pgwd](https://github.com/hrodrig/pgwd)** (Postgres Watch Dog) from the published container image — monitor PostgreSQL connection counts and notify via Slack/Loki.

**Path vs repository name:** In a clone of **[pgwd-selfhosted](https://github.com/hrodrig/pgwd-selfhosted)**, this chart lives under **`run/kubernetes/helm/pgwd/`**. The segment **`pgwd`** is the **Helm chart name** (matches **`name:`** in **`Chart.yaml`**) and the workload it deploys — not the GitHub repository name (**`pgwd-selfhosted`**). This mirrors **[gghstats-selfhosted](https://github.com/hrodrig/gghstats-selfhosted)** / **`run/kubernetes/helm/gghstats`**. Application source and binary releases remain in **[hrodrig/pgwd](https://github.com/hrodrig/pgwd)**.

**Helm repo alias:** `helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted` uses **`pgwd`** as the local repo name so **`helm install … pgwd/pgwd`** reads as *repo/chart* — both refer to the **pgwd** product, not the `-selfhosted` repo name.

## Prerequisites

- Helm 3
- Kubernetes 1.28+ (see **`kubeVersion`** in **`Chart.yaml`**; CI validates manifests against 1.30 schemas)
- PostgreSQL accessible from within the cluster (in-cluster DNS)

## Installation

For any install that uses **`-f my-values.yaml`**, create that file from the chart defaults, then edit it for your cluster (database URL, Slack/Loki, resources, namespace, etc.):

```bash
helm show values <chart-reference> --version <version> > my-values.yaml
# Edit my-values.yaml with your desired settings before helm install.
```

Helm’s **`--version`** is the **chart package** semver (see **`version:`** in **`Chart.yaml`**). This repo (**[pgwd-selfhosted](https://github.com/hrodrig/pgwd-selfhosted)**) is the **canonical** home for the chart: it is published from here (GitHub Pages and/or release automation), not from the **[pgwd](https://github.com/hrodrig/pgwd)** application repo. The **container image** for pgwd remains **`ghcr.io/hrodrig/pgwd`** from [pgwd releases](https://github.com/hrodrig/pgwd/releases); set **`image.tag`** in values to match the binary you run.

### From pgwd-selfhosted (GitHub Pages)

When this chart is published from **[pgwd-selfhosted](https://github.com/hrodrig/pgwd-selfhosted)**, the packaged chart uses **`version:`** from this repo’s **`Chart.yaml`** (currently **`0.1.0`** — not the pgwd release number):

```bash
helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted
helm repo update
helm show values pgwd/pgwd --version 0.1.0 > my-values.yaml
# Edit my-values.yaml for your environment.
helm install pgwd pgwd/pgwd --version 0.1.0 -n pgwd --create-namespace -f my-values.yaml
```

Confirm with `helm search repo pgwd -l` if the index lists a different chart version than **`0.1.0`**.

### From this repository (pgwd-selfhosted sources)

```bash
git clone https://github.com/hrodrig/pgwd-selfhosted.git
cd pgwd-selfhosted
helm install pgwd ./run/kubernetes/helm/pgwd \
  --create-namespace \
  --namespace monitoring \
  --set secrets.dbUrl="postgres://user:password@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable" \
  --set secrets.slackWebhook="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" \
  --set secrets.lokiUrl="http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push" \
  --set env.PGWD_CLIENT="pgwd-prod"
```

### From pgwd application sources (upstream, legacy)

The **[pgwd](https://github.com/hrodrig/pgwd)** repo may still ship a copy under **`contrib/helm/pgwd`** until that tree is retired; **prefer this repository** for the maintained chart. If you only have a clone of **pgwd**:

```bash
helm install pgwd ./contrib/helm/pgwd \
  --create-namespace \
  --namespace monitoring \
  --set secrets.dbUrl="postgres://user:password@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable" \
  --set secrets.slackWebhook="https://hooks.slack.com/services/YOUR/WEBHOOK/URL" \
  --set secrets.lokiUrl="http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push" \
  --set env.PGWD_CLIENT="pgwd-prod"
```

For production, use `--set-file` or a custom values file to avoid passing secrets on the command line.

## Configuration modes

### Env vars (default)

Use `secrets.dbUrl`, `secrets.slackWebhook`, `secrets.lokiUrl` and `env.*` for single-database monitoring. Secrets are created from values (or reference `secrets.existingSecret`).

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
```

### Config file (multiple databases)

Set `config.enabled: true` and provide full YAML in `config.extra`. Use this for multiple Postgres instances. **Note:** When using a config file, env vars are ignored by pgwd.

```yaml
# values.yaml
config:
  enabled: true
  extra: |
    client: pgwd-k8s
    interval: 60
    databases:
      - url: postgres://user:pass@postgres.default.svc.cluster.local:5432/prod
        threshold:
          levels: "75,85,95"
      - url: postgres://user:pass@replica.default.svc.cluster.local:5432/prod
        threshold:
          levels: "75,85,95"
    sqlite:
      path: /var/lib/pgwd/pgwd.db
    http:
      listen: ":8080"
    notifications:
      slack:
        webhook: "https://hooks.slack.com/..."
      loki:
        url: "http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"

secrets:
  create: false  # URLs and webhooks are in config
```

For sensitive values in config mode, use [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) or [External Secrets](https://external-secrets.io/) to create a Secret with the config file, then mount it manually or extend the chart.

## Persistence

By default, a 1Gi PVC is created for `/var/lib/pgwd` (SQLite store). This enables resolution notifications and metrics history across restarts.

- Disable: `persistence.enabled: false` (uses emptyDir)
- Use existing PVC: `persistence.existingClaim: "my-pvc-name"`

## Service and metrics

A ClusterIP Service exposes port 8080 for `/api/pgwd/v1/healthz` and `/api/pgwd/v1/metrics`. Use for Prometheus scraping or health checks.

Optional PodMonitor (Prometheus Operator):

```yaml
podMonitor:
  enabled: true
  interval: 30s
  path: /api/pgwd/v1/metrics
```

## Values reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/hrodrig/pgwd` |
| `image.tag` | Image tag (defaults to appVersion) | `""` |
| `secrets.create` | Create Secret from values | `true` |
| `secrets.dbUrl` | Postgres connection URL | `""` |
| `secrets.slackWebhook` | Slack webhook URL | `""` |
| `secrets.lokiUrl` | Loki push URL | `""` |
| `secrets.existingSecret` | Use existing Secret name | `""` |
| `config.enabled` | Use config file instead of env | `false` |
| `config.extra` | Full pgwd YAML config | See values.yaml |
| `env.PGWD_LOG_LEVEL` | Log level: `info` or `debug` (debug = verbose dry-run stats) | `info` |
| `persistence.enabled` | Use PVC for SQLite | `true` |
| `persistence.size` | PVC size | `1Gi` |
| `service.enabled` | Create Service | `true` |
| `resources.requests` | CPU/memory requests | `10m/32Mi` |

## Uninstall

```bash
helm uninstall pgwd --namespace monitoring
```

Note: The PVC is retained by default. Delete it manually if needed.

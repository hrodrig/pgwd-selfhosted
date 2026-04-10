# Local Kubernetes smoke test (kind)

The manifest **`postgres-minimal.yaml`** deploys Postgres in **`default`** with **`postgres.default.svc.cluster.local:5432`**, user **`user`**, password **`password`**, database **`mydb`** — the same values as the **[Helm chart README](../../run/kubernetes/helm/pgwd/README.md)** quick-start.

## Automated runs

| Make target | What it does |
|-------------|----------------|
| **`make test-kind-postgres`** | kind cluster + **`postgres-minimal`** only |
| **`make test-helm-kind`** | Same Postgres + **`helm upgrade --install`** pgwd (README-style **`PGWD_DRY_RUN`**) + rollout + **log check** for Postgres stats (**v0.5.10** image). |

```bash
make test-kind-postgres   # Postgres only
make test-helm-kind       # Postgres + pgwd chart
```

Requires **Docker**, **kind**, **kubectl**. **`test-helm-kind`** also needs **helm**.

**Environment (optional):**

| Variable | Purpose |
|----------|---------|
| **`PGWD_HELM_E2E_CLUSTER`** | kind cluster name (default **`pgwd-helm-e2e`**) |
| **`PGWD_KIND_POSTGRES_ROLLOUT_TIMEOUT`** | Postgres `kubectl rollout status … --timeout` (default **`180s`**) |
| **`PGWD_HELM_E2E_ROLLOUT_TIMEOUT`** | pgwd Deployment timeout when using **`test-helm-kind`** (default **`300s`**) |
| **`PGWD_HELM_E2E_LOG_WAIT_SECS`** | Seconds to wait for **`total=`/`active=`** lines in pgwd logs (default **`180`**) |
| **`PGWD_HELM_E2E_NO_CLEANUP`** | If non-empty, **do not** delete the kind cluster |

**`test-helm-kind`** sets slightly **higher CPU/memory** on the pgwd pod (`--set resources…`) so the check is stable under kind (default chart limits are tight for **pgx** + log volume).

If Postgres or pgwd fails to become ready, the script prints **`kubectl` describe / logs / events** before exiting.

## Manual Helm (existing cluster)

From the **repository root** (paths below assume that working directory):

```bash
helm upgrade --install pgwd ./run/kubernetes/helm/pgwd \
  -n pgwd --create-namespace \
  --set secrets.dbUrl="postgres://user:password@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable" \
  --set env.PGWD_DRY_RUN=true \
  --set env.PGWD_CLIENT="pgwd-demo"
```

This path is **optional** for contributors; CI still relies on **`helm template`** + **kubeconform** (see **[CONTRIBUTING.md](../../CONTRIBUTING.md)**).

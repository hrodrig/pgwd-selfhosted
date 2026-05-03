# pgwd from a host outside the cluster (kubectl port-forward)

Use these **example scripts** when **pgwd** runs on a bastion, laptop, or VPS with **`kubectl`** access, and each **PostgreSQL** (plus optional **Loki**) lives **inside** Kubernetes. They wrap the upstream patterns documented in **[pgwd README — Kubernetes](https://github.com/hrodrig/pgwd/blob/main/README.md#kubernetes)**.

**This directory is implementation guidance for [pgwd-selfhosted](../../README.md)** — not shipped with the `pgwd` application repo as product code.

## What the examples encode

| Topic | Why |
|--------|-----|
| **`PATH` includes `/snap/bin`** | On Ubuntu, `kubectl` is often `/snap/bin/kubectl`; minimal `PATH` (e.g. cron) misses it. |
| **`PGWD_CRON_SLEEP_BETWEEN`** (default `3`) | Sequential `pgwd` runs each start/stop port-forwards; a short pause avoids **`connection refused`** on the next local port. |
| **`-dry-run=false`**, **`-interval 0`**, **`-notifications-slack-webhook …` on CLI** | If **`/etc/pgwd/pgwd.conf`** exists (e.g. from `.deb`), **`PGWD_*` env may be ignored**; explicit CLI flags still apply. |
| **`-notifications-loki-org-id`** | Renamed flag (not legacy `-loki-org-id`). Must match Grafana **X-Scope-OrgId** when Loki is multi-tenant. |
| **`127.0.0.1` + `-kube-local-port` in `-db-url`** | Matches port-forward binding on the host; **`?sslmode=disable`** avoids TLS mismatch over the tunnel. |
| **Dangling `kubectl port-forward`** | If a local port is **already in use**, check **`ss -ltnp \| grep <port>`** and stop the old **`kubectl`** PID. |
| **Multi-database YAML vs port-forward** | Upstream pgwd **rejects `databases:` + `-kube-postgres` together**. These scripts run **one URL + one kube target per invocation** (or separate processes). For several DBs inside the cluster with **direct** URLs, use **`databases:`** only (no kube stanza). See **[Multi-database limitations](https://github.com/hrodrig/pgwd/blob/main/README.md#multi-database-limitations)**. |

## Environment variables (copy / export)

| Variable | Purpose |
|----------|---------|
| **`PGWD_NOTIFICATIONS_SLACK_WEBHOOK`** | Required for these examples (incoming webhook). Prefer **`export`** in **`~/.bashrc`**, **`~/.profile`**, or a file **`source`d** from cron — cron does **not** load `.bashrc` by default. |
| **`KUBECONFIG`** | Path to kubeconfig (default **`~/.kube/config`** in the examples). |
| **`PGWD_KUBE_CONTEXT`** | Optional; omit to use kubectl’s **current context**. |
| **`PGWD_K8S_NAMESPACE`** | Kubernetes namespace for Postgres and Loki **Services** (default **`default`** in the example scripts — set to your namespace). |
| **`PGWD_NOTIFICATIONS_LOKI_ORG_ID`** | Loki **X-Scope-OrgId** (default **`1`** in examples; must match your Grafana Loki data source if multi-tenant). |
| **`PGWD_K8S_LOKI_SVC`** | Loki **Service** name without namespace (default **`loki`**). |
| **`PGWD_CRON_SLEEP_BETWEEN`** | Seconds to sleep between back-to-back **`pgwd`** invocations (default **`3`**). |
| **`PGWD_KUBE_LOKI_LOCAL_PORT`** | Local port for Loki forward in **cron** example (default **`3100`**). Heartbeat example uses per-target ports in the script body — adjust if they clash. |

## Files

| File | Use |
|------|-----|
| [`pgwd-cron-multi.example.sh`](pgwd-cron-multi.example.sh) | **Threshold** checks (one-shot per service), suitable for **`cron`** every *N* minutes. |
| [`pgwd-heartbeat-multi.example.sh`](pgwd-heartbeat-multi.example.sh) | **`-force-notification`** per service to validate Slack/Loki pipelines. |

**Install:** copy to your **`~/bin`**, **`chmod +x`**, edit the **`run_check` / `run_hb` rows** (service names, ports, DB names) for your environment, and set secrets via env — **do not commit webhooks**.

## See also

- **[`run/scripts/README.md`](../README.md)** — other helper scripts.
- **[pgwd — Running from cron](https://github.com/hrodrig/pgwd/blob/main/README.md#running-from-cron)** — upstream `PATH` and logging notes.

---

**[↑ Back to run/scripts](../README.md)**

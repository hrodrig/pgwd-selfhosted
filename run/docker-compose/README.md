# Docker Compose layouts

← [Back to run/README](../README.md).

Compose files live under this directory; run **`docker compose` from the repository root** with **`--env-file "${PGWD_HOST_DATA}/.env"`** (or **`.env.observability`** for the observability stack). See **[`run/common/.env.example`](../common/.env.example)** for the main template.

| Layout | Use when | README |
|--------|----------|--------|
| **Minimal** | Single **pgwd** container, published host port (**`PGWD_HOST_PORT`**), quick VPS or lab | [`minimal/README.md`](minimal/README.md) |
| **Traefik** | HTTPS on your domain (**`PGWD_HOSTNAME`**), Let’s Encrypt; pgwd **not** exposed on a host port | [`traefik/README.md`](traefik/README.md) |
| **Observability** | Prometheus, Grafana, Loki, Promtail, Node Exporter **after** Traefik (network **`pgwd_edge`**) | [`observability/README.md`](observability/README.md) |

**Data outside the clone:** set **`PGWD_HOST_DATA`** to an absolute path and put **`${PGWD_HOST_DATA}/.env`** there (same idea as [standalone](../standalone/README.md) and [Helm](../kubernetes/helm/pgwd/README.md) in-container **`/var/lib/pgwd`**).

**Shortcut:** **[`run/scripts/compose-stack.sh`](../scripts/compose-stack.sh)** — e.g. **`./run/scripts/compose-stack.sh traefik up -d`**. **`./run/scripts/compose-stack.sh --help`**

**No HTTP / no exposed port:** Compose stacks here **enable** HTTP on pgwd by default (metrics/health). For **notifications-only** runs without a listening port, use **[Cron / one-shot](../standalone/README.md#cron--one-shot-no-daemon-no-http)** (host binary) or **[`docker run --rm`](../docker/README.md#one-shot-container-no-daemon)**.

---

**[↑ Back to run/README](../README.md)**

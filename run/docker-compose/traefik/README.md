# Traefik + TLS (production-style)

← [Back to run/README](../../README.md) · [Compose index](../README.md).

**Shortcut:** [`run/scripts/compose-stack.sh`](../../scripts/compose-stack.sh) — e.g. **`./run/scripts/compose-stack.sh traefik up -d`**.

**Traefik** terminates HTTPS (Let’s Encrypt) and routes to **pgwd** on the **`pgwd_edge`** Docker network. No host port is published for pgwd; only **80** and **443** for Traefik.

From the **repository root**:

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
cp run/common/.env.example "${PGWD_HOST_DATA}/.env"
# Set PGWD_DB_URL, PGWD_HOSTNAME, ACME_EMAIL, PGWD_UID, PGWD_GID,
# PGWD_VERSION, and PGWD_HOST_DATA (same absolute path; directory must be owned by PGWD_UID:PGWD_GID)

docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/traefik/docker-compose.yml up -d
```

Ensure DNS for `PGWD_HOSTNAME` points to this host and **80/443** are reachable for ACME.

**Notifiers vs dry-run:** this compose defaults **`PGWD_DRY_RUN=false`**. You must set **`PGWD_NOTIFICATIONS_SLACK_WEBHOOK`** and/or **`PGWD_NOTIFICATIONS_LOKI_URL`**, or set **`PGWD_DRY_RUN=true`** in **`.env`**, or pgwd will exit and the container will restart in a loop (same rule as upstream pgwd).

Optional **Prometheus / Grafana / Loki**: **[`run/docker-compose/observability/`](../observability/README.md)** (start this Traefik stack first so `pgwd_edge` exists).

For a **simpler** single-service stack (host port to pgwd), use **[`../minimal/`](../minimal/README.md)**.

---

**[↑ Back to run/README](../../README.md)**

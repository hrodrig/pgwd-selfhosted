# Shared environment (`run/common`)

← [Back to run/README](../README.md).

Copy **[`.env.example`](.env.example)** to **`${PGWD_HOST_DATA}/.env`** on the host (same directory as SQLite — outside the git clone). Set **`PGWD_HOST_DATA`** in that file to the same absolute path, then run Compose with **`docker compose --env-file "${PGWD_HOST_DATA}/.env" -f …`** from the repository root. Optional local-only path: **`./.env`** at the repo root with **`PGWD_HOST_DATA`** unset (uses repo **`data/`**). Do not commit real secrets.

The template covers:

- **pgwd** — **`PGWD_DB_URL`**, GHCR **`PGWD_VERSION`**, optional Slack/Loki webhooks, interval / log level
- **minimal Compose** — optional **`PGWD_HOST_PORT`** (host port mapped to container **8080**)
- **Traefik production stack** — hostname, ACME email, **`PGWD_HOST_DATA`** (host path for SQLite under **`/var/lib/pgwd`**; absolute path recommended), container UID/GID must own that directory

**Observability** (optional) uses a **second** file in that same directory: copy **`run/docker-compose/observability/observability.env.example`** to **`${PGWD_HOST_DATA}/.env.observability`**. **`PGWD_HOST_DATA`** must be the same value as in **`${PGWD_HOST_DATA}/.env`**. Pass **`--env-file "${PGWD_HOST_DATA}/.env.observability"`** to every observability `docker compose` command. See **`run/docker-compose/observability/README.md`**.

---

**[↑ Back to run/README](../README.md)**

# Shared environment (`run/common`)

← [Back to run/README](../README.md).

Copy **[`.env.example`](.env.example)** to **`${PGWD_HOST_DATA}/.env`** on the host (outside the git clone). Set **`PGWD_HOST_DATA`** in that file to the same absolute path, then run Compose with **`docker compose --env-file "${PGWD_HOST_DATA}/.env" -f …`** from the repository root. Optional local-only path: **`./.env`** at the repo root with **`PGWD_HOST_DATA`** unset. Do not commit real secrets.

The template covers:

- **pgwd** — **`PGWD_DB_URL`**, GHCR **`PGWD_VERSION`**, optional Slack/Loki webhooks, interval / log level
- **minimal Compose** — optional **`PGWD_HOST_PORT`** (reserved for layouts that publish a port)

---

**[↑ Back to run/README](../README.md)**

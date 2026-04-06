# Minimal Compose

← [Back to run/README](../../README.md) · [Compose index](../README.md).

**Shortcut:** [`run/scripts/compose-stack.sh`](../../scripts/compose-stack.sh) — e.g. **`./run/scripts/compose-stack.sh minimal up -d`** (same `--env-file` / `-f` as below).

Single **pgwd** service using the **GHCR image**. For **HTTPS + domain**, use **[`../traefik/`](../traefik/)** instead. For **`docker run`** without Compose, see **[`run/docker/`](../../docker/README.md)**. Set **`PGWD_HOST_DATA`** in **`${PGWD_HOST_DATA}/.env`** to a **host directory** for SQLite (recommended: absolute path, e.g. `/home/pgwd/pgwd-data`). If **`PGWD_HOST_DATA`** is unset in the env file you pass to Compose, the stack bind-mounts the repo’s **`data/`** (tracked empty via **`data/.keep`**; other files under **`data/`** are gitignored — see root `.gitignore`).

From the **repository root**:

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
cp run/common/.env.example "${PGWD_HOST_DATA}/.env"
# Edit "${PGWD_HOST_DATA}/.env" — PGWD_DB_URL, PGWD_VERSION, PGWD_HOST_DATA (same path); optional notifiers

docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml up -d
```

Stop:

```bash
docker compose --env-file "${PGWD_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml down
```

For **HTTPS and a public hostname**, use **[`run/docker-compose/traefik/`](../traefik/)** instead.

**Defaults:** the Compose file sets **`PGWD_HTTP_LISTEN=0.0.0.0:8080`** and publishes **`PGWD_HOST_PORT`** (default **8080**) for health and **`/api/pgwd/v1/metrics`**. To avoid exposing HTTP entirely, this layout is not ideal (use **[one-shot `docker run`](../../docker/README.md#one-shot-container-no-daemon)** or **[standalone cron](../../standalone/README.md#cron--one-shot-no-daemon-no-http)**); override **`PGWD_INTERVAL`** in **`.env`** only if you understand interaction with **`restart: unless-stopped`** (interval **0** makes the process exit; the container may restart in a loop).

---

**[↑ Back to run/README](../../README.md)**

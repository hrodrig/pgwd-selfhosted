# Minimal Compose

← [Back to run/README](../../README.md).

Single **pgwd** service using the **GHCR image**. Set **`PGWD_HOST_DATA`** in **`${PGWD_HOST_DATA}/.env`** to a **host directory** for SQLite (recommended: absolute path, e.g. `/home/pgwd/pgwd-data`). If **`PGWD_HOST_DATA`** is unset in the env file you pass to Compose, the stack bind-mounts the repo’s **`data/`** (tracked empty via **`data/.keep`**; other files under **`data/`** are gitignored — see root `.gitignore`).

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

---

**[↑ Back to run/README](../../README.md)**

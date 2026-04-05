# Docker (`docker run`)

← [Back to run/README](../README.md).

Run the published image without Compose. Use the same **host directory** idea as in **`run/common/.env.example`**: set **`PGWD_HOST_DATA`** to an **absolute path** on the server (SQLite and optional `.env` colocation).

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"

docker run -d \
  -e PGWD_DB_URL='postgres://user:pass@host:5432/dbname?sslmode=disable' \
  -e PGWD_HTTP_LISTEN=0.0.0.0:8080 \
  -e PGWD_SQLITE_PATH=/var/lib/pgwd/pgwd.db \
  -e PGWD_INTERVAL=60 \
  -p 8080:8080 \
  -v "${PGWD_HOST_DATA}:/var/lib/pgwd" \
  --name pgwd \
  ghcr.io/hrodrig/pgwd:v0.5.10
```

Replace **`PGWD_DB_URL`** with a real URL. Optional: add **`PGWD_NOTIFICATIONS_SLACK_WEBHOOK`** or **`PGWD_NOTIFICATIONS_LOKI_URL`**. The mount path **`/var/lib/pgwd`** matches the default SQLite location used in Compose and Helm.

Use an image tag that exists on GHCR ([releases](https://github.com/hrodrig/pgwd/releases)); match **`PGWD_VERSION`** in **[`run/common/.env.example`](../common/.env.example)**.

**Check:** `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/api/pgwd/v1/healthz` (expect **`200`**).

**Remove:**

```bash
docker stop pgwd && docker rm pgwd
```

For **all** environment variables supported by the binary/container, see the upstream **[README](https://github.com/hrodrig/pgwd/blob/main/README.md)** and **`contrib/pgwd.conf.example`** on **`main`**.

For **Compose-based** setups (persistent layout, Traefik, observability), use **`run/docker-compose/`** instead.

---

**[↑ Back to run/README](../README.md)**

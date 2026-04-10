# Docker (`docker run`)

← [Back to run/README](../README.md) · [Compose](../docker-compose/README.md).

Run the published image without Compose. The **`v0.5.10`** image on GHCR matches **[pgwd](https://github.com/hrodrig/pgwd) v0.5.10**: it monitors Postgres and can notify via Slack/Loki. Configure with **environment variables** (or a **mounted config file** and **`PGWD_CONFIG`** — see **upstream** docs).

```bash
docker run -d \
  --name pgwd \
  -e PGWD_DB_URL='postgres://user:pass@host:5432/dbname?sslmode=disable' \
  -e PGWD_INTERVAL=60 \
  ghcr.io/hrodrig/pgwd:v0.5.10
```

Replace **`PGWD_DB_URL`** with a real URL. Optional: **`PGWD_CLIENT`**, **`PGWD_DRY_RUN=true`** for a safe first run, **`PGWD_NOTIFICATIONS_SLACK_WEBHOOK`**, **`PGWD_NOTIFICATIONS_LOKI_URL`**, etc. — see the upstream **[README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

Use an image tag that exists on GHCR ([releases](https://github.com/hrodrig/pgwd/releases)); match **`PGWD_VERSION`** in **[`run/common/.env.example`](../common/.env.example)**.

**Check:** `docker logs pgwd` (or `docker logs -f pgwd`) — look for lines with **`total=`** / **`active=`** / **`max_connections=`** when the DB is reachable.

**Remove:**

```bash
docker stop pgwd && docker rm pgwd
```

**Compose vs `docker run`:** different layouts may apply for other releases. For Compose with **[`run/common/.env.example`](../common/.env.example)**, use **[`run/docker-compose/minimal`](../docker-compose/minimal/README.md)**. This **`docker run`** section tracks **v0.5.10** as documented here.

For **Compose-based** setups, use **[`run/docker-compose/README.md`](../docker-compose/README.md)**.

### One-shot container (no daemon)

For a **single run** then exit (e.g. from **cron** on the host), use **`--rm`** and **`PGWD_INTERVAL=0`**.

```bash
docker run --rm \
  -e PGWD_INTERVAL=0 \
  -e PGWD_DB_URL='postgres://user:pass@host:5432/dbname?sslmode=disable' \
  ghcr.io/hrodrig/pgwd:v0.5.10
```

Add notifier env vars as needed. Same **cron / one-shot** ideas as **[standalone](../standalone/README.md#cron--one-shot-no-daemon)**.

---

**[↑ Back to run/README](../README.md)**

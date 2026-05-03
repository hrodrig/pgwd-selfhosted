# Minimal Compose

← [Back to run/README](../../README.md) · [Compose index](../README.md).

**Shortcut:** [`run/scripts/compose-stack.sh`](../../scripts/compose-stack.sh) — e.g. **`./run/scripts/compose-stack.sh minimal up -d`** (same `--env-file` / `-f` as below).

Single **pgwd** service using the **GHCR** image. Default **`PGWD_VERSION=v0.6.4`**: env-driven Postgres monitoring and optional Slack/Loki; use **`docker logs`** for output. Optional **SQLite**, **`PGWD_HTTP_LISTEN`**, and published **ports** — see **[`docker-compose.yml`](docker-compose.yml)** comments and **[`run/common/.env.example`](../../common/.env.example)**.

Use **`${PGWD_HOST_DATA}/.env`** so secrets and **`PGWD_DB_URL`** stay outside the git clone (recommended on servers). **`PGWD_HOST_DATA`** is **not** bind-mounted into the container for this layout.

This **`docker-compose.yml`** does **not** map host **`ports:`** and does not ship an extra **Service** for pgwd — there is **no** inbound listener to expose in this layout; use **`docker logs`** and optional **Slack/Loki**. For **`docker run`** without Compose, see **[`run/docker/`](../../docker/README.md)**.

### Host prerequisites

Same checks whether you run Compose by hand or via **[`testing/platforms/`](../../../testing/platforms/README.md)** automation:

- **`docker --version`** and **`docker compose version`** must succeed on the host. A message like **`docker: not found`** means Docker (and the Compose plugin) is not installed or not on your shell `PATH` — fix that before **`up -d`**.

**Notifiers vs dry-run:** pgwd must have **Slack and/or Loki** configured **or** **`PGWD_DRY_RUN=true`**. This layout defaults **`PGWD_DRY_RUN=true`** when the variable is unset, so missing webhooks does not cause a **restart loop**. Set **`PGWD_DRY_RUN=false`** in **`.env`** when real notifier URLs are set.

To run **`-force-notification`** against a mock while the daemon stays in dry-run, use a one-shot override so the child process does not inherit dry-run, e.g. **`docker exec -e PGWD_DRY_RUN=false pgwd /home/pgwd/pgwd -force-notification …`** (plus **`-db-url`** and notifier URLs). The Ansible **[`testing/platforms/`](../../../testing/platforms/README.md)** notification play does this automatically.

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

**Check:** **`docker logs pgwd`** (or **`docker logs -f pgwd`**) — look for **`total=`** / **`active=`** / **`max_connections=`** when Postgres is reachable.

**`PGWD_INTERVAL=0`** with **`restart: unless-stopped`** exits the process after one run and Docker will keep restarting the container; use a one-shot **[`docker run --rm`](../../docker/README.md#one-shot-container-no-daemon)** instead for cron-style single runs.

---

**[↑ Back to run/README](../../README.md)**

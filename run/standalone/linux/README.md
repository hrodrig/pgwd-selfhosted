# Linux (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

1. Download the **Linux** tarball for your architecture from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** (e.g. `pgwd_v0.5.10_linux_amd64.tar.gz`).
2. Extract the **`pgwd`** binary (e.g. `tar xzf …`), then **`chmod +x pgwd`** if needed.
3. Prefer a **persistent data directory** outside the tarball (same idea as **`PGWD_HOST_DATA`** in Compose):

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
mkdir -p "$PGWD_HOST_DATA"
export PGWD_SQLITE_PATH="${PGWD_HOST_DATA}/pgwd.db"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_HTTP_LISTEN=:8080
./pgwd
```

4. Optional YAML config: copy **[`contrib/pgwd.conf.example`](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)** to **`${PGWD_HOST_DATA}/pgwd.conf`**, edit, then **`pgwd -config "${PGWD_HOST_DATA}/pgwd.conf"`**. **Note:** when a config file is loaded, **environment variables are ignored** ([upstream behavior](https://github.com/hrodrig/pgwd/blob/main/README.md)); use env-only mode (no **`-config`**) for the **`PGWD_*`** flow above.

**systemd:** use **`EnvironmentFile=`** pointing to a **root-only** file with secrets; set **`WorkingDirectory=`** or absolute paths for **`PGWD_SQLITE_PATH`** / **`-config`**.

Docker-based paths: **`run/docker/`**, **`run/docker-compose/`**.

---

**[↑ Back to run/standalone](../README.md)**

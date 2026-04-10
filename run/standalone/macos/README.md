# macOS (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

## Homebrew (recommended if you use Homebrew)

Install from the **[`hrodrig/pgwd` tap](https://github.com/hrodrig/homebrew-pgwd)**:

```bash
brew install hrodrig/pgwd/pgwd
```

This puts **`pgwd`** on your **`PATH`** (and installs the **man page** — **`man pgwd`**). Upgrade later with **`brew upgrade pgwd`**. See **[upstream package table](https://github.com/hrodrig/pgwd/blob/main/README.md#package-managers)** for the canonical command.

## Release tarball (no Homebrew)

1. Download the **macOS** tarball for your architecture from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract **`pgwd`**, then **`chmod +x pgwd`** if Gatekeeper blocked execution (see **System Settings → Privacy & Security** if needed).

---

## Data directory and runtime (both options)

Keep runtime state **outside** the download folder — same idea as Compose **`PGWD_HOST_DATA`**:

```bash
export PGWD_HOST_DATA="${HOME}/pgwd-data"
mkdir -p "$PGWD_HOST_DATA"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_INTERVAL=60
./pgwd
```

If **`pgwd`** is on **`PATH`** (Homebrew), run **`pgwd`** instead of **`./pgwd`**.

Optional **`PGWD_CONFIG`** / **`-config`** with YAML under **`PGWD_HOST_DATA`** — fields match **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)**. **Note:** when a config file is loaded, **environment variables are ignored**; use env-only mode for the flow above. Extra behavior — **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)** for your tag.

---

**[↑ Back to run/standalone](../README.md)**

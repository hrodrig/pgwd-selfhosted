# Standalone binary (no Docker)

← [Back to run/README](../README.md).

Install from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** (tarball or zip per OS/arch). OS-specific steps:

| OS | Guide |
|----|--------|
| **Linux** | [linux/README.md](linux/README.md) |
| **macOS** | [macos/README.md](macos/README.md) |
| **Windows** | [windows/README.md](windows/README.md) |
| **\*BSD** (FreeBSD, OpenBSD, NetBSD, DragonFly) | [bsd/README.md](bsd/README.md) |
| **Solaris / illumos** | [solaris/README.md](solaris/README.md) |

## CPU architectures (release binaries)

Release assets are built from **[`.goreleaser.yaml`](https://github.com/hrodrig/pgwd/blob/main/.goreleaser.yaml)** in the **pgwd** repo. The matrix uses **`GOARCH`** **`amd64`**, **`arm64`**, and **`riscv64`** only — there are **no** published binaries for **SPARC** / **sparc64**, **386**, **32-bit arm**, **mips**, **ppc64le**, etc. (build from source with **Go** if you need an unsupported arch).

| Arch | Notes |
|------|--------|
| **`amd64`** | Shipped for every **`GOOS`** in the file (Linux, macOS, Windows, \*BSD, Solaris/illumos). |
| **`arm64`** | Shipped for all of those **except** **`solaris`** — **illumos / Solaris releases are `solaris_amd64` only**. |
| **`riscv64`** | Shipped for **Linux**, **FreeBSD**, **OpenBSD**, **NetBSD** only. **Not** published for **macOS**, **Windows**, **DragonFly**, or **Solaris** (each excluded in **`ignore:`** in `.goreleaser.yaml`). |

Asset names look like **`pgwd_<tag>_<goos>_<goarch>.tar.gz`** (e.g. **`…_linux_riscv64.tar.gz`**, **`…_freebsd_arm64.tar.gz`**). Pick the file that matches your machine.

**Recommended:** keep **SQLite** and any **YAML config** under a single directory **outside** the download folder (same pattern as Compose: **`PGWD_HOST_DATA`**, e.g. `/home/pgwd/pgwd-data`). Set **`PGWD_SQLITE_PATH`** and optionally **`PGWD_CONFIG`** or **`-config`** to paths inside that directory.

## Cron / one-shot (no daemon, no HTTP)

Some operators want **notifications only** — **no** long-running daemon and **no** listening port (e.g. minimal **\*BSD** or VPS setups). pgwd supports that:

| Goal | What to do |
|------|------------|
| **One run per invocation, then exit** | **`PGWD_INTERVAL=0`** or **`-interval 0`**. Schedule with **cron**(8) or a timer; nothing stays running between runs. |
| **No HTTP / health / metrics port** | Do **not** set **`PGWD_HTTP_LISTEN`** (or set **`http.listen`** to empty in YAML). An empty listen address disables the HTTP server — no exposed port. |
| **Test notifications** | **`-force-notification`** (see [upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)). |

**Example cron line** (adjust paths and env):

```bash
PGWD_INTERVAL=0 PGWD_DB_URL='postgres://…' PGWD_NOTIFICATIONS_SLACK_WEBHOOK='https://…' /usr/local/bin/pgwd
```

Use a **config file** instead of env if you prefer; remember that **when a config file is loaded, environment variables are ignored** — put **`interval: 0`** and omit **`http.listen`** (or set it empty) in YAML.

---

**[↑ Back to run/README](../README.md)**

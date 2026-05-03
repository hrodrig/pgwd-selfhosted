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

## Align with this repo’s default (`v0.6.4`)

**Self-hosted paths in this repository** default to the published **GHCR** image **`v0.6.4`**: **`PGWD_DB_URL`**, optional **Slack/Loki**, and **logs** for operational checks. **SQLite, `/metrics`, multi-DB YAML** — **[pgwd README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

Use the minimal env block in the root **[README](../../README.md)** (**Standalone binary**) or **`-config`** per **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)** (`client`, `db`, `databases`, `sqlite`, `http`, `notifications`, `kube`, …). Anything outside that file — **[pgwd README](https://github.com/hrodrig/pgwd/blob/main/README.md)** for your tag.

## CPU architectures (release binaries)

Release assets are built from **[`.goreleaser.yaml`](https://github.com/hrodrig/pgwd/blob/main/.goreleaser.yaml)** in the **pgwd** repo. The matrix uses **`GOARCH`** **`amd64`**, **`arm64`**, and **`riscv64`** only — there are **no** published binaries for **SPARC** / **sparc64**, **386**, **32-bit arm**, **mips**, **ppc64le**, etc. (build from source with **Go** if you need an unsupported arch).

| Arch | Notes |
|------|--------|
| **`amd64`** | Shipped for every **`GOOS`** in the file (Linux, macOS, Windows, \*BSD, Solaris/illumos). |
| **`arm64`** | Shipped for all of those **except** **`solaris`** — **illumos / Solaris releases are `solaris_amd64` only**. |
| **`riscv64`** | Shipped for **Linux**, **FreeBSD**, **OpenBSD**, **NetBSD** only. **Not** published for **macOS**, **Windows**, **DragonFly**, or **Solaris** (each excluded in **`ignore:`** in `.goreleaser.yaml`). |

Asset names look like **`pgwd_<tag>_<goos>_<goarch>.tar.gz`** (e.g. **`…_linux_riscv64.tar.gz`**, **`…_freebsd_arm64.tar.gz`**). Pick the file that matches your machine.

**Recommended:** keep state **outside** the download folder (same idea as Compose **`PGWD_HOST_DATA`**, e.g. `/home/pgwd/pgwd-data`). Use **`PGWD_DB_URL`** (and optional notifiers) for the minimal path. Full YAML config follows **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)**; other behavior — **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

## Cron / one-shot (no daemon)

Some operators want **only scheduled runs** — **no** long-lived process between **cron**(8) or timer invocations (e.g. minimal **\*BSD** or small VPS). pgwd supports that:

| Goal | What to do |
|------|------------|
| **One run per invocation, then exit** | **`PGWD_INTERVAL=0`** or **`-interval 0`**. Schedule with **cron**(8) or a timer; nothing stays running between runs. |
| **Test notifications** | **`-force-notification`** (see [upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)). |

**Example cron line** (adjust paths and env):

```bash
PGWD_INTERVAL=0 PGWD_DB_URL='postgres://…' PGWD_NOTIFICATIONS_SLACK_WEBHOOK='https://…' /usr/local/bin/pgwd
```

Use a **config file** instead of env if you prefer; remember that **when a config file is loaded, environment variables are ignored** — use **`interval: 0`** in YAML per **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)**. Anything beyond that example file — **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)** for your tag.

---

**[↑ Back to run/README](../README.md)**

# *BSD (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

**[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** publish **GoReleaser** tarballs per **OS and architecture** (e.g. **`pgwd_v0.5.10_freebsd_amd64.tar.gz`**). Pick the asset that matches **`freebsd`**, **`openbsd`**, **`netbsd`**, or **`dragonfly`** and your **CPU**. **RISC-V** (`riscv64`) exists for **FreeBSD**, **OpenBSD**, and **NetBSD**; **DragonFly** releases are **amd64** / **arm64** only (see [CPU architectures](../README.md#cpu-architectures-release-binaries) in the standalone index).

**Shared pattern:** keep **SQLite** and optional YAML config under **`PGWD_HOST_DATA`** (outside the extract dir). Set **`PGWD_SQLITE_PATH`**, **`PGWD_DB_URL`**, etc., or use **`-config`** (when a config file is loaded, **env vars are ignored** — [upstream](https://github.com/hrodrig/pgwd/blob/main/README.md)).

| BSD | Guide |
|-----|--------|
| **FreeBSD** | [freebsd/README.md](freebsd/README.md) |
| **OpenBSD** | [openbsd/README.md](openbsd/README.md) |
| **NetBSD** | [netbsd/README.md](netbsd/README.md) |
| **DragonFly** | [dragonfly/README.md](dragonfly/README.md) |

**No daemon / no HTTP:** if you want **cron** only (no resident process, no listening port), see **[Cron / one-shot (no daemon, no HTTP)](../README.md#cron--one-shot-no-daemon-no-http)** in the standalone index.

---

**[↑ Back to run/standalone](../README.md)**

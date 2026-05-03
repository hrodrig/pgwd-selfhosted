# *BSD (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

**[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** publish **GoReleaser** tarballs per **OS and architecture** (e.g. **`pgwd_v0.6.4_freebsd_amd64.tar.gz`**). Pick the asset that matches **`freebsd`**, **`openbsd`**, **`netbsd`**, or **`dragonfly`** and your **CPU**. **RISC-V** (`riscv64`) exists for **FreeBSD**, **OpenBSD**, and **NetBSD**; **DragonFly** releases are **amd64** / **arm64** only (see [CPU architectures](../README.md#cpu-architectures-release-binaries) in the standalone index).

**Shared pattern:** use **`PGWD_HOST_DATA`** outside the extract dir. For minimal env-only runs, **`PGWD_DB_URL`** and optional notifiers are enough ([root README](../../../README.md)). **`-config`** loads YAML as in **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)**; when a config file is loaded, **env vars are ignored**. Anything else — [upstream](https://github.com/hrodrig/pgwd/blob/main/README.md) for your tag.

| BSD | Guide |
|-----|--------|
| **FreeBSD** | [freebsd/README.md](freebsd/README.md) |
| **OpenBSD** | [openbsd/README.md](openbsd/README.md) |
| **NetBSD** | [netbsd/README.md](netbsd/README.md) |
| **DragonFly** | [dragonfly/README.md](dragonfly/README.md) |

**Cron only (no long-lived daemon):** see **[Cron / one-shot (no daemon)](../README.md#cron--one-shot-no-daemon)** in the standalone index.

---

**[↑ Back to run/standalone](../README.md)**

# Solaris / illumos (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

**[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** include **`solaris_amd64`** tarballs only (Go’s **`GOOS=solaris`** covers **illumos** / Solaris-style systems). There is **no** **`solaris_arm64`**, **`solaris_riscv64`**, or other arch in the [upstream](https://github.com/hrodrig/pgwd/blob/main/.goreleaser.yaml) matrix — use **amd64** release binaries, or build from source for other CPUs.

1. Download **`pgwd_<tag>_solaris_amd64.tar.gz`** (or the matching asset name for your tag).
2. Extract and **`chmod +x pgwd`** if needed.
3. Prefer a **persistent data directory** outside the tarball:

```bash
export PGWD_HOST_DATA=/var/pgwd/data
mkdir -p "$PGWD_HOST_DATA"
export PGWD_SQLITE_PATH="${PGWD_HOST_DATA}/pgwd.db"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_HTTP_LISTEN=:8080
./pgwd
```

4. Optional **`pgwd -config …`**: when a config file is loaded, **environment variables are ignored** ([upstream](https://github.com/hrodrig/pgwd/blob/main/README.md)).

## SMF (optional)

The release tarball includes **SMF** manifests under **`share/solaris/smf/`** (see upstream **`contrib/solaris/smf/`** in [pgwd](https://github.com/hrodrig/pgwd)). Copy or adapt them for your site’s paths and **`pgwd`** location before **`svccfg`** / **`svcadm`**.

---

**[↑ Back to run/standalone](../README.md)**

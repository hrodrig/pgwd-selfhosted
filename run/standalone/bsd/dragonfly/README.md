# DragonFly BSD (standalone binary)

← [Back to *BSD index](../README.md) · [run/standalone](../../README.md).

## Tarball from releases

1. Download **`pgwd_<tag>_dragonfly_<arch>.tar.gz`** from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** (Go reports **`dragonfly`** as **`GOOS`**). Releases ship **`dragonfly_amd64`** and **`dragonfly_arm64`** only — there is **no** **`dragonfly_riscv64`** artifact in the [upstream](https://github.com/hrodrig/pgwd/blob/main/.goreleaser.yaml) matrix.
2. Extract and **`chmod +x pgwd`** if needed.
3. Runtime:

```sh
export PGWD_HOST_DATA=/var/db/pgwd
mkdir -p "$PGWD_HOST_DATA"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_INTERVAL=60
./pgwd
# Optional: pgwd -config — YAML per contrib/pgwd.conf.example; extras — upstream README.
```

Optional **`pgwd -config …`** — when used, **environment variables are ignored**.

## rc.d (optional)

Release tarballs include **`share/dragonfly/rc.d/pgwd`** (see upstream **`contrib/dragonflybsd/rc.d/`** in [pgwd](https://github.com/hrodrig/pgwd)). Copy into **`/usr/local/etc/rc.d/`** (or your site’s path), adjust **`command`** / **`command_args`**, then enable with **`rcenable`** / **`service`** as usual on DragonFly.

---

**[↑ Back to *BSD index](../README.md)**

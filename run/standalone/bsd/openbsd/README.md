# OpenBSD (standalone binary)

← [Back to *BSD index](../README.md) · [run/standalone](../../README.md).

## Tarball from releases

1. Download **`pgwd_<tag>_openbsd_<arch>.tar.gz`** from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract and **`chmod +x pgwd`** if needed.
3. Runtime:

```sh
export PGWD_HOST_DATA=/var/db/pgwd
mkdir -p "$PGWD_HOST_DATA"
export PGWD_SQLITE_PATH="${PGWD_HOST_DATA}/pgwd.db"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_HTTP_LISTEN=:8080
./pgwd
```

Optional **`pgwd -config …`** — when used, **environment variables are ignored**.

## rc.d (optional)

Release tarballs include **`share/openbsd/rc.d/pgwd`** (example script). Copy it into **`/etc/rc.d/`** (or your preferred location), adjust **`pgwd`** path and arguments, then enable per **[rc.d(8)](https://man.openbsd.org/rc.d)** / **`rcctl`**.

---

**[↑ Back to *BSD index](../README.md)**

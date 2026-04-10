# NetBSD (standalone binary)

← [Back to *BSD index](../README.md) · [run/standalone](../../README.md).

## Tarball from releases

1. Download **`pgwd_<tag>_netbsd_<arch>.tar.gz`** from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
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

Release tarballs include **`share/netbsd/rc.d/pgwd`**. Install under **`/etc/rc.d/`** (or follow NetBSD conventions for third-party scripts), edit paths and **`pgwd`** invocation, then enable with **`/etc/rc.conf`** / **`rcorder`** as appropriate for NetBSD.

---

**[↑ Back to *BSD index](../README.md)**

# FreeBSD (standalone binary)

← [Back to *BSD index](../README.md) · [run/standalone](../../README.md).

Primary path in this guide: **release tarball** (below). Do **not** assume a **`sysutils/pgwd`** port or **`pkg install pgwd`** exists on your machine until FreeBSD actually ships it for your version.

**Upstream port effort** (outside **pgwd-selfhosted**): track **[bug 294001](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=294001)** and **[contrib/freebsd/README.md](https://github.com/hrodrig/pgwd/blob/main/contrib/freebsd/README.md)** in the pgwd repo if you maintain or follow that work.

## Tarball from releases

1. Download **`pgwd_<tag>_freebsd_<arch>.tar.gz`** from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** (e.g. **`freebsd_amd64`**, **`freebsd_arm64`**).
2. Extract: **`tar xzf …`**, **`chmod +x pgwd`** if needed.
3. Runtime (data outside the tarball):

```sh
export PGWD_HOST_DATA=/var/db/pgwd
mkdir -p "$PGWD_HOST_DATA"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_INTERVAL=60
./pgwd
# Optional: pgwd -config — YAML per contrib/pgwd.conf.example; extras — upstream README.
```

Optional **`pgwd -config /path/to/pgwd.conf`** — when used, **environment variables are ignored**.

## rc.d (daemon from tarball)

If you run the **binary from a tarball**, add an **`rc.d`** script yourself (see **`contrib/freebsd/rc.d/`** in the [pgwd repo](https://github.com/hrodrig/pgwd)) and point it at **`pgwd`** and your **`PGWD_*`** or **`-config`**.

---

**[↑ Back to *BSD index](../README.md)**

# FreeBSD (standalone binary)

← [Back to *BSD index](../README.md) · [run/standalone](../../README.md).

## Ports: `sysutils/pgwd` (recommended when in the tree)

When **`sysutils/pgwd`** is available in the official ports collection, install from source or packages:

```sh
# Package (when published on your FreeBSD version)
sudo pkg install pgwd

# Or build from ports
cd /usr/ports/sysutils/pgwd && sudo make install clean
```

The port installs **`pgwd`** under **`/usr/local/bin`**, **`rc.d`** integration, **`/usr/local/etc/pgwd/pgwd.conf.example`**, and expects config under **`/etc/pgwd/pgwd.conf`** by default — see upstream **[`contrib/freebsd/README.md`](https://github.com/hrodrig/pgwd/blob/main/contrib/freebsd/README.md)**. Until the port lands, track **[bug 294001](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=294001)** and use a **release tarball** below.

## Tarball from releases

1. Download **`pgwd_<tag>_freebsd_<arch>.tar.gz`** from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)** (e.g. **`freebsd_amd64`**, **`freebsd_arm64`**).
2. Extract: **`tar xzf …`**, **`chmod +x pgwd`** if needed.
3. Runtime (data outside the tarball):

```sh
export PGWD_HOST_DATA=/var/db/pgwd
mkdir -p "$PGWD_HOST_DATA"
export PGWD_SQLITE_PATH="${PGWD_HOST_DATA}/pgwd.db"
export PGWD_DB_URL='postgres://user:pass@localhost:5432/mydb?sslmode=disable'
export PGWD_HTTP_LISTEN=:8080
./pgwd
```

Optional **`pgwd -config /path/to/pgwd.conf`** — when used, **environment variables are ignored**.

## rc.d only (raw binary without the port)

If you deploy the **tarball** and not **`sysutils/pgwd`**, install an **`rc.d`** script yourself (see **`contrib/freebsd/rc.d/`** in the [pgwd repo](https://github.com/hrodrig/pgwd)) and point it at **`pgwd`** and your **`PGWD_*`** or **`-config`**.

---

**[↑ Back to *BSD index](../README.md)**

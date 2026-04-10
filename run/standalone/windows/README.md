# Windows (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

1. Download the **Windows** zip for your architecture from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract **`pgwd.exe`** to a folder of your choice (e.g. **`C:\pgwd`**).
3. Prefer a **data directory** outside the zip for env/config (same concept as **`PGWD_HOST_DATA`** on Linux/macOS), e.g. **`C:\pgwd-data`**:

```powershell
$env:PGWD_HOST_DATA = "C:\pgwd-data"
New-Item -ItemType Directory -Force -Path $env:PGWD_HOST_DATA | Out-Null
$env:PGWD_DB_URL = "postgres://user:pass@localhost:5432/mydb?sslmode=disable"
$env:PGWD_INTERVAL = "60"
.\pgwd.exe
```

4. Optional config file: **`pgwd.exe -config C:\pgwd-data\pgwd.conf`** — YAML shape follows **[contrib/pgwd.conf.example](https://github.com/hrodrig/pgwd/blob/main/contrib/pgwd.conf.example)**. Anything else — **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)** for your tag.

---

**[↑ Back to run/standalone](../README.md)**

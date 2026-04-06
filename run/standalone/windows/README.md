# Windows (standalone binary)

← [Back to run/standalone](../README.md) · [run/README](../../README.md).

1. Download the **Windows** zip for your architecture from **[pgwd Releases](https://github.com/hrodrig/pgwd/releases)**.
2. Extract **`pgwd.exe`** to a folder of your choice (e.g. **`C:\pgwd`**).
3. Prefer a **data directory** outside the zip for SQLite and config (same concept as **`PGWD_HOST_DATA`** on Linux/macOS), e.g. **`C:\pgwd-data`**:

```powershell
$env:PGWD_HOST_DATA = "C:\pgwd-data"
New-Item -ItemType Directory -Force -Path $env:PGWD_HOST_DATA | Out-Null
$env:PGWD_SQLITE_PATH = "$env:PGWD_HOST_DATA\pgwd.db"
$env:PGWD_DB_URL = "postgres://user:pass@localhost:5432/mydb?sslmode=disable"
.\pgwd.exe
```

4. Optional config file: **`pgwd.exe -config C:\pgwd-data\pgwd.conf`** — see **[upstream README](https://github.com/hrodrig/pgwd/blob/main/README.md)**.

---

**[↑ Back to run/standalone](../README.md)**

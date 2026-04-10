# Docker Compose layouts

← [Back to run/README](../README.md).

Compose files live under this directory; run **`docker compose` from the repository root** with **`--env-file "${PGWD_HOST_DATA}/.env"`**. See **[`run/common/.env.example`](../common/.env.example)** for the template.

**Custom image:** set **`PGWD_IMAGE`** in **`.env`** for a full OCI reference; otherwise **`minimal`** uses **`ghcr.io/hrodrig/pgwd:${PGWD_VERSION}`**.

**Host prerequisites:** **`docker`** and **`docker compose`** on `PATH`.

| Layout | Use when | README |
|--------|----------|--------|
| **Minimal** | Single **pgwd** container (defaults **`v0.5.10`**), quick VPS or lab | [`minimal/README.md`](minimal/README.md) |

**Data outside the clone:** set **`PGWD_HOST_DATA`** and keep **`${PGWD_HOST_DATA}/.env`** there.

**Shortcut:** **[`run/scripts/compose-stack.sh`](../scripts/compose-stack.sh)** — **`./run/scripts/compose-stack.sh --help`**

---

**[↑ Back to run/README](../README.md)**

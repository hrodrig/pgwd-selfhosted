# Compose platform tests (Ansible)

Batch validation of the **Docker Compose minimal stack** from this repository on **real machines** (VPS, lab VMs), similar in spirit to **pgwd** `make test-platforms` but for the **self-hosted Compose path** instead of native `.deb` / `.rpm` / tarball install.

These playbooks **fail fast on the same prerequisite checks** a human operator would hit: missing **Docker** or **Compose**, wrong **inventory**, unreachable **SSH** or **Postgres**, etc. They are **not** random errors — they mirror what an end user sees when running **`compose-stack.sh`** or **`docker compose …`** on a host that is not ready yet. Fix the host or config, then re-run.

## Scope

| Suite | What it validates |
| --- | --- |
| **This directory** | **Docker** + **Compose v2** on each host; clone or update **pgwd-selfhosted**; render `${PGWD_HOST_DATA}/.env`; `compose-stack.sh minimal up -d`; **`/api/pgwd/v1/healthz`**; **per-VPS Python mock** on **`notification_mock_port`**; **`docker exec pgwd … -force-notification`** to Loki + Slack URLs via the **Docker bridge gateway**; asserts captures in **`/tmp/pgwd-mock-*.json`**; `minimal down` in teardown |
| [pgwd `testing/platforms/`](https://github.com/hrodrig/pgwd/tree/develop/testing/platforms) | Native package/binary, init systems, same mock pattern on **`127.0.0.1`**, timers |
| [pgwd `make test-e2e-kube`](https://github.com/hrodrig/pgwd/blob/develop/Makefile) | **Kind** + `-kube-postgres` / `-kube-loki` |

**Not in scope here:** Traefik (needs DNS / ACME), full observability stack, Helm apply. Extend playbooks later if you need those paths on a subset of hosts.

## Prerequisites

### Control node (your laptop or CI with SSH access)

- **Ansible** 2.14+
- SSH key access to targets (**`root`** or a user with **passwordless `sudo`** and **Docker** — playbooks use `become: true`)

### Each target host

1. **Docker Engine** and **Docker Compose v2** (`docker compose`). Install on each target **before** running playbooks — these playbooks **do not** install Docker. Tasks prepend a standard `PATH` so non-login SSH can find **`docker`** (e.g. under `/usr/bin` or `/snap/bin`).
2. **Git** (the prepare role installs **git** via the distro package manager when missing).
3. **Python 3** for Ansible (same expectations as pgwd platform tests). On *BSD set `ansible_python_interpreter` in inventory (see `inventory/hosts.yml.example`).
4. A **reachable PostgreSQL** for **`PGWD_DB_URL`** (see [pgwd platform README](https://github.com/hrodrig/pgwd/blob/develop/testing/platforms/README.md) — you can point several VPS at the same DB or use separate instances).

The notification test runs mock and **pgwd** on the **same** host; only the **Docker bridge gateway** must be correct so the container can reach the mock on that host. If `docker inspect` does not report a gateway, set **`pgwd_compose_docker_host_fallback`** (default `172.17.0.1`).

The daemon may run with **`PGWD_DRY_RUN=true`** (recommended when no Slack/Loki in **`.env`**). **`docker exec` inherits that env**, and pgwd would only log *would send* instead of posting — so the playbook uses **`docker exec -e PGWD_DRY_RUN=false`** for the **`-force-notification`** probe only. Real one-shot tests by hand should do the same or pass **`-dry-run=false`** on the pgwd CLI.

## Quick start

```bash
cd /path/to/pgwd-selfhosted
cp testing/platforms/inventory/hosts.yml.example testing/platforms/inventory/hosts.yml
# Edit hosts.yml: ansible_host, ansible_port, pgwd_db_url, optional per-host overrides

make                    # shows available targets (default — does not run Ansible)
make test-compose-platforms

# Single host
make test-compose-platforms LIMIT=vps-ubuntu
```

Or from `testing/platforms/`:

```bash
ansible-playbook playbooks/full-cycle.yml
ansible-playbook playbooks/full-cycle.yml --limit vps-ubuntu
```

## Playbooks

| Playbook | Description |
| --- | --- |
| `playbooks/setup.yml` | Install **git** if needed, clone/update repo, create **`pgwd_host_data`**, template **`${pgwd_host_data}/.env`** |
| `playbooks/test.yml` | **`minimal up -d`**, **healthz**, then **mock + `docker exec` `-force-notification`** (Loki + Slack) |
| `playbooks/teardown.yml` | **`compose-stack.sh minimal down`** (idempotent) |
| `playbooks/full-cycle.yml` | **setup** → **test** → **teardown** |

To leave the stack running after a successful test, run **setup** and **test** only:

```bash
cd testing/platforms
ansible-playbook playbooks/setup.yml playbooks/test.yml
```

## Inventory

Copy **`inventory/hosts.yml.example`** to **`inventory/hosts.yml`** (the latter is gitignored). Set at least:

- **`ansible_host`**, **`ansible_port`**, **`ansible_user`** (often `root`)
- **`pgwd_db_url`** — Postgres URL for the container (`PGWD_DB_URL`)
- **`pgwd_host_data`** — host directory for **`.env`** and SQLite bind-mount (e.g. `/var/lib/pgwd-compose`)

Optional: **`pgwd_compose_repo_version`** (branch/tag, default `develop`), **`pgwd_image_version`** (image tag, default `v0.5.10`), **`pgwd_host_port`**, **`notification_mock_port`** (default **9999**), **`pgwd_compose_docker_host_fallback`** if `docker inspect` does not report a gateway.

The **`.env`** template may leave Slack/Loki empty; the notification test passes URLs on the **`docker exec`** command line (no shared notifications VPS).

## Relationship to pgwd `test-platforms`

- **pgwd** exercises the **bare-metal** install story per OS family.
- **This repo** exercises **Compose + GHCR image** as documented under **`run/docker-compose/`**.

Run both before a release if you ship manifest changes and care about native packages too.

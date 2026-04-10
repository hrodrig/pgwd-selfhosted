# How to run pgwd (self-hosted)

← [Back to the repository README](../README.md).

Pick a **mode** below. Commands are documented in each subdirectory’s `README.md`.

### Compose helper script

From the **repository root**, after **`PGWD_HOST_DATA`** is set and **`${PGWD_HOST_DATA}/.env`** exists (see **[`run/common/.env.example`](common/.env.example)**), you can use **[`run/scripts/compose-stack.sh`](scripts/compose-stack.sh)** instead of typing long `docker compose --env-file … -f …` lines:

```bash
export PGWD_HOST_DATA=/home/pgwd/pgwd-data
./run/scripts/compose-stack.sh minimal up -d
```

Pass any Compose subcommand (`up`, `down`, `restart`, `logs`, `ps`, `pull`, …) and extra flags. **`./run/scripts/compose-stack.sh --help`** for options (`--data-dir`).

| Directory | When to use |
|-----------|-------------|
| [`run/common/`](common/) | Shared **environment template** for Compose. Copy to **`${PGWD_HOST_DATA}/.env`**, set **`PGWD_HOST_DATA`** inside that file, then `docker compose --env-file "${PGWD_HOST_DATA}/.env" -f …` from the clone root (see [`run/common/.env.example`](common/.env.example)). |
| [`standalone/`](standalone/) | **Release binaries** from [pgwd Releases](https://github.com/hrodrig/pgwd/releases) — no Docker. See **[`standalone/README.md`](standalone/README.md)** (Linux, macOS, Windows, *BSD, Solaris/illumos). **Cron only** (no long-lived daemon): [Cron / one-shot](standalone/README.md#cron--one-shot-no-daemon). |
| [`docker/`](docker/) | **`docker run`** with the GHCR image — minimal, no Compose; **[one-shot / `--rm`](docker/README.md#one-shot-container-no-daemon)** for cron-style runs. |
| [`docker-compose/`](docker-compose/) | **Index:** minimal stack — [`docker-compose/README.md`](docker-compose/README.md). |
| [`docker-compose/minimal/`](docker-compose/minimal/) | **One Compose service** — quick test or small VPS. |
| [`kubernetes/helm/pgwd/`](kubernetes/helm/pgwd/) | **Helm** chart — **only** here (not shipped under **[pgwd](https://github.com/hrodrig/pgwd)** **`main`**). Install from a **clone**; **[`README`](kubernetes/helm/pgwd/README.md)**. **Helm repo** on [GitHub Pages](https://hrodrig.github.io/pgwd-selfhosted) with the **first chart release**. |
| [`kubernetes/manifests/`](kubernetes/manifests/) | Raw manifests — optional; see folder README. |

**Batch test many VPS (Ansible):** after Docker is installed on each machine, use **[`testing/platforms/README.md`](../testing/platforms/README.md)** and **`make test-compose-platforms`** from the repository root (clone + **`.env`** + **minimal** stack **up** / log-based check / **down**).

Always use the **published image tag** that matches your desired [pgwd](https://github.com/hrodrig/pgwd) release (see `PGWD_VERSION` in [`run/common/.env.example`](common/.env.example)).

---

**[↑ Back to the repository README](../README.md)**

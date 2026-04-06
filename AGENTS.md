# Agent Guidelines (pgwd-selfhosted)

- Use **English** for all project artifacts (code, comments, commit messages, docs, README).
- Follow **git flow**: work on `develop`; **`main`** for production snapshots; **annotated tags** `v<semver>` on `main` for infra releases (see root **`VERSION`**).
- **`VERSION`** (repository root): canonical **pgwd-selfhosted** semver (`0.1.1` style, no `v`). When it changes, align the README **Version** badge, optional CHANGELOG, and Git tag **`v…`** on **`main`**. **`Chart.yaml` `version:`** tracks the **Helm chart package** only — bump it when **`run/kubernetes/helm/pgwd/`** changes materially, **not** automatically on every **`VERSION`** bump (see **Versioning** in README and **`.cursor/rules/version-sync.mdc`**).
- **`PGWD_VERSION`** in **`${PGWD_HOST_DATA}/.env`** (recommended) or any env file passed to Compose: pins the **application** OCI image (`ghcr.io/hrodrig/pgwd:…`); align with **[pgwd](https://github.com/hrodrig/pgwd)** releases — not the same field as this repo’s **`VERSION`**.
- This repo has **no** Go `Makefile` or `make release-check`; validation is manifest/docs review and optional `docker compose … config`.
- Keep **`run/`** paths, **`PGWD_HOST_DATA`**, and **`${PGWD_HOST_DATA}/.env`** / **`${PGWD_HOST_DATA}/.env.observability`** documentation consistent across README files (always **`--env-file`** those paths from the clone root — no default of secrets in the repository root).
- Do not commit without first showing the proposed commit message and getting **explicit user approval** (same convention as **pgwd**).

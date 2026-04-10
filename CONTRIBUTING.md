# Contributing to pgwd-selfhosted

Thank you for helping improve these deployment manifests.

## How to contribute

- **Issues:** Use [GitHub Issues](https://github.com/hrodrig/pgwd-selfhosted/issues) for bugs, doc gaps, or manifest improvements (Compose, Helm).
- **Pull requests:** Open PRs against **`develop`**. Keep changes focused (one concern per PR when possible).
- **Application behavior** (Go code, UI, API): contribute in **[pgwd](https://github.com/hrodrig/pgwd)** — this repo is **infrastructure only**.

## Checks before submitting

- Paths under **`run/`** match the documented layout; **`docker compose … config`** succeeds when a minimal env file is provided (e.g. **`--env-file "${PGWD_HOST_DATA}/.env"`** with **`PGWD_HOST_DATA`** set, or a dev **`./.env`** at the repo root with defaults). Shortcut from the repo root (Helm + kubeconform + minimal Compose **`config`**): **`make release-check`** (requires **helm**, **kubeconform**, **docker**).
- **Helm:** If your PR changes **`run/kubernetes/helm/`**, run **`make release-check`** or **[Helm chart validation (same as CI)](#helm-chart-validation-same-as-ci)** below. GitHub Actions runs [**.github/workflows/helm-lint.yml**](.github/workflows/helm-lint.yml) on those paths.
- **English** for README and comments.
- If you bump **[`VERSION`](VERSION)**, keep the README **Version** badge and **CHANGELOG** aligned. Bump **`Chart.yaml` `version:`** only when **`run/kubernetes/helm/pgwd/`** changes and you intend to publish a **new chart package** — **`VERSION`** and chart **`version:`** do not need to match on every release (see **Versioning** in the root README).

### Helm chart validation (same as CI)

Replicate locally what [.github/workflows/helm-lint.yml](.github/workflows/helm-lint.yml) does: **`helm lint`** (Chart metadata, **`values.schema.json`** on merged values, template syntax), a second **`helm lint`** with **`-f run/kubernetes/helm/pgwd/values-config-mode.yaml`**, and **`helm template`** piped to **[kubeconform](https://github.com/yannh/kubeconform)** (rendered manifests validated against Kubernetes OpenAPI schemas **without** a cluster). **`kubectl apply --dry-run=client`** is **not** used in CI: recent kubectl builds may still contact **`localhost:8080`** for API discovery and fail where no apiserver exists.

#### Requirements

| Tool | Purpose | Version in CI (reference) |
|------|---------|---------------------------|
| **Helm** | `helm lint`, `helm template` | [v3.16.4](https://github.com/helm/helm/releases) (any recent **Helm 3** is usually fine) |
| **kubeconform** | Validate YAML against K8s resource schemas | [v0.7.0](https://github.com/yannh/kubeconform/releases) — align with **`KUBECONFORM_VERSION`** in **helm-lint.yml** when you need bit-for-bit parity |

Install **kubeconform**, for example: **`brew install kubeconform`**, or download a release tarball for your OS/architecture from the [kubeconform releases](https://github.com/yannh/kubeconform/releases) page.

Set **`KUBERNETES_VERSION`** to the same value as **`KUBERNETES_VERSION`** in **helm-lint.yml** (currently **`1.30.0`**). That flag selects which upstream Kubernetes OpenAPI schemas kubeconform uses; change it here when the workflow changes.

#### Commands (run from the repository root)

```bash
export CHART_DIR=run/kubernetes/helm/pgwd
export KUBERNETES_VERSION=1.30.0

helm lint "$CHART_DIR"

helm lint "$CHART_DIR" -f "$CHART_DIR/values-config-mode.yaml"

helm template test-rel "$CHART_DIR" --namespace test-ns | \
  kubeconform -strict -kubernetes-version "$KUBERNETES_VERSION" -summary -

helm template test-rel "$CHART_DIR" --namespace test-ns \
  --set config.enabled=true \
  --set secrets.create=false | \
  kubeconform -strict -kubernetes-version "$KUBERNETES_VERSION" -summary -

helm template test-rel "$CHART_DIR" --namespace test-ns \
  --set secrets.dbUrl='postgres://ci:ci@postgres.default.svc.cluster.local:5432/db?sslmode=disable' | \
  kubeconform -strict -kubernetes-version "$KUBERNETES_VERSION" -summary -

helm template test-rel "$CHART_DIR" --namespace test-ns \
  --set secrets.create=false \
  --set secrets.existingSecret=my-imported-secret | \
  kubeconform -strict -kubernetes-version "$KUBERNETES_VERSION" -summary -
```

#### Expected kubeconform summaries

With the current templates, **`kubeconform -summary`** should report **Valid** only (no invalid/errors). Approximate **resource counts** (each **`---`** document):

| Scenario | Typical count | Notes |
|----------|---------------|--------|
| Default values | 1 | **`Deployment`** only (empty **`secrets.*`** → no chart **`Secret`**) |
| **`config.enabled=true`** (**`secrets.create=false`**) | 2 | **`Deployment`** + **`ConfigMap`** |
| **`secrets.dbUrl`** set (inline Secret) | 2 | Adds chart-managed **`Secret`** |
| **`secrets.existingSecret`** set (**`secrets.create=false`**) | 1 | No chart-managed Secret; Deployment references the existing Secret name |

If counts change after you edit templates, trust the workflow steps in **helm-lint.yml** and the rendered YAML, not this table.

#### Optional: validation with a real cluster

If you use **kind**, **minikube**, or another cluster and **`kubectl`** points at it, you can additionally run server-side dry-run (not required for CI parity):

```bash
helm template test-rel run/kubernetes/helm/pgwd --namespace test-ns | kubectl apply --dry-run=server -f -
```

Use the same **`helm template`** flags as in the kubeconform scenarios to exercise each path.

**Optional: kind smoke tests** — **[testing/kind/README.md](testing/kind/README.md)**:

```bash
make test-kind-postgres   # Postgres only (Docker, kind, kubectl)
make test-helm-kind       # + Helm pgwd + log-based Postgres check (adds helm)
```

Requires **Docker**, **kind**, **kubectl**; **`test-helm-kind`** also **helm**.

## Release flow (this repo)

- **`VERSION`** at the repo root — semver without `v` (e.g. `0.2.0`).
- Git tags **`v<version>`** on **`main`** after merging from **`develop`**.
- See **[CHANGELOG.md](CHANGELOG.md)** for notable infra-facing changes.

### Helm chart on GitHub Pages (maintainers)

The install path **`helm repo add pgwd https://hrodrig.github.io/pgwd-selfhosted`** expects **`index.yaml`** and packaged **`.tgz`** files on the **`gh-pages`** branch.

- **Automation:** [**.github/workflows/release-charts.yml**](.github/workflows/release-charts.yml) runs **[helm/chart-releaser-action](https://github.com/helm/chart-releaser-action)** when you **push an annotated tag `v*`** on **`main`** (aligned with the repo’s **`VERSION`** / release tags). It packages the chart, creates a GitHub Release (artifact `.tgz`), and updates **`gh-pages`** with **`index.yaml`**. **`workflow_dispatch`** is available for a manual re-run. Continuous validation before merge: [**helm-lint.yml**](.github/workflows/helm-lint.yml).
- **One-time setup:** Repository **Settings → Pages → Build and deployment → Source:** branch **`gh-pages`**, folder **`/` (root)**.
- **Release checklist (chart publish):** When the **chart** changes, bump **`Chart.yaml` `version:`** (semver) and **`appVersion`** if the image story changes. Merge to **`main`**, push **`git tag -a v…`** and **`git push origin v…`**. Confirm [Release Charts](.github/workflows/release-charts.yml) is green; then **`helm repo update`** on a test machine. **Repo `VERSION`** and Git tag **`v*`** snapshot the **whole repository** — they need not equal **`Chart.yaml` `version:`** if this release did not touch the chart.
- **“No chart changes detected”:** Normal when you tag **`v*`** for a **docs-only or Compose-only** release. chart-releaser only updates **`gh-pages`** / chart packages when **`run/kubernetes/helm/`** has meaningful diffs. **No action required** unless you intended to ship a new **`.tgz`** — then edit the chart, bump **`Chart.yaml` `version:`**, merge, and tag again.
- **First chart upload failed with `invalid reference: origin/gh-pages`:** Fixed in the workflow by bootstrapping an **orphan `gh-pages`** branch when it does not exist yet; use workflow and chart version **≥ 0.1.2** (or re-tag after pulling that workflow).

The chart **source of truth** remains **`run/kubernetes/helm/pgwd/`**.

## Questions

Open an issue to discuss larger refactors before investing heavy work.

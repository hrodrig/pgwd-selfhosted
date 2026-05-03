# Kubernetes manifests (optional)

← [Back to run/README](../../README.md).

This directory is reserved for **raw YAML** manifests (e.g. `Deployment`, optional `Service` / `Ingress` for your own tooling) if you prefer not to use Helm. For the default **v0.6.4** image as documented in this repo, treat **`kubectl logs`** as the primary runtime check unless you enable HTTP **`/metrics`** and scrape it yourself.

The maintained install path is the **[Helm chart](../helm/pgwd/)**. You can generate a starting point with:

```bash
helm template pgwd ../helm/pgwd > example-rendered.yaml
```

Review and edit before applying; values are the source of truth in **`../helm/pgwd/values.yaml`**.

---

**[↑ Back to run/README](../../README.md)**

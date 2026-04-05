# Kubernetes manifests (optional)

← [Back to run/README](../../README.md).

This directory is reserved for **raw YAML** manifests (e.g. `Deployment` + `Service` + `Ingress`) if you prefer not to use Helm.

The maintained install path is the **[Helm chart](../helm/pgwd/)**. You can generate a starting point with:

```bash
helm template pgwd ../helm/pgwd > example-rendered.yaml
```

Review and edit before applying; values are the source of truth in **`../helm/pgwd/values.yaml`**.

---

**[↑ Back to run/README](../../README.md)**

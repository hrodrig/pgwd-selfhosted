#!/usr/bin/env bash
# kind smoke tests (see Makefile: test-kind-postgres vs test-helm-kind).
# - PGWD_KIND_E2E_PGWD=0: cluster + postgres-minimal only
# - PGWD_KIND_E2E_PGWD=1: helm install pgwd + rollout + log-based Postgres check
# Requires: docker, kind, kubectl; helm when PGWD_KIND_E2E_PGWD=1
set -euo pipefail

RUN_PGWD="${PGWD_KIND_E2E_PGWD:-0}"
CLUSTER_NAME="${PGWD_HELM_E2E_CLUSTER:-pgwd-helm-e2e}"
POSTGRES_ROLLOUT_TIMEOUT="${PGWD_KIND_POSTGRES_ROLLOUT_TIMEOUT:-180s}"
PGWD_ROLLOUT_TIMEOUT="${PGWD_HELM_E2E_ROLLOUT_TIMEOUT:-300s}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHART_DIR="$REPO_ROOT/run/kubernetes/helm/pgwd"
POSTGRES_MANIFEST="$REPO_ROOT/testing/kind/postgres-minimal.yaml"
NS_DEFAULT="default"
NS_PGWD="pgwd"
LABEL_PGWD="app.kubernetes.io/name=pgwd"

dump_postgres_diagnostics() {
  echo ""
  echo "========== postgres-minimal diagnostics (namespace $NS_DEFAULT) =========="
  kubectl get pods -n "$NS_DEFAULT" -o wide 2>/dev/null || true
  echo ""
  kubectl describe deployment/postgres-minimal -n "$NS_DEFAULT" 2>/dev/null || true
  echo ""
  kubectl describe pod -n "$NS_DEFAULT" -l app.kubernetes.io/name=postgres-minimal 2>/dev/null || true
  echo ""
  kubectl logs -n "$NS_DEFAULT" -l app.kubernetes.io/name=postgres-minimal --tail=80 2>/dev/null || true
  echo ""
  kubectl get events -n "$NS_DEFAULT" --sort-by='.lastTimestamp' 2>/dev/null | tail -30 || true
  echo "========== end diagnostics =========="
  echo ""
}

dump_pgwd_diagnostics() {
  echo ""
  echo "========== pgwd diagnostics (namespace $NS_PGWD) =========="
  kubectl get pods -n "$NS_PGWD" -o wide 2>/dev/null || true
  echo ""
  kubectl describe pod -n "$NS_PGWD" -l "$LABEL_PGWD" 2>/dev/null || true
  echo ""
  kubectl logs -n "$NS_PGWD" -l "$LABEL_PGWD" --tail=120 2>/dev/null || true
  echo ""
  kubectl logs -n "$NS_PGWD" -l "$LABEL_PGWD" --previous --tail=120 2>/dev/null || true
  echo ""
  kubectl get events -n "$NS_PGWD" --sort-by='.lastTimestamp' 2>/dev/null | tail -40 || true
  echo "========== end diagnostics =========="
  echo ""
}

cleanup() {
  if [[ -n "${PGWD_HELM_E2E_NO_CLEANUP:-}" ]]; then
    echo "PGWD_HELM_E2E_NO_CLEANUP is set; keeping kind cluster: $CLUSTER_NAME"
    echo "  kubectl config use-context kind-$CLUSTER_NAME"
    return 0
  fi
  echo "Cleaning up: kind delete cluster --name $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

for cmd in docker kind kubectl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "error: '$cmd' not found on PATH"
    exit 1
  }
done
if [[ "$RUN_PGWD" == "1" ]]; then
  command -v helm >/dev/null 2>&1 || {
    echo "error: 'helm' not found on PATH (required for pgwd install)"
    exit 1
  }
  test -d "$CHART_DIR" || {
    echo "error: chart directory not found: $CHART_DIR"
    exit 1
  }
fi

test -f "$POSTGRES_MANIFEST" || {
  echo "error: missing $POSTGRES_MANIFEST"
  exit 1
}

echo "Creating kind cluster: $CLUSTER_NAME"
kind create cluster --name "$CLUSTER_NAME" --wait 60s

echo "Deploying minimal Postgres (matches README dbUrl host/db/user)..."
kubectl apply -f "$POSTGRES_MANIFEST"

echo "Waiting for Postgres rollout (timeout $POSTGRES_ROLLOUT_TIMEOUT)..."
if ! kubectl rollout status deployment/postgres-minimal -n "$NS_DEFAULT" --timeout="$POSTGRES_ROLLOUT_TIMEOUT"; then
  echo "error: postgres-minimal Deployment did not become ready."
  dump_postgres_diagnostics
  exit 1
fi

echo ""
echo "Postgres is up on kind cluster '$CLUSTER_NAME'."

if [[ "$RUN_PGWD" != "1" ]]; then
  echo "  Service DNS: postgres.default.svc.cluster.local:5432"
  echo "  URL: postgres://user:password@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable"
  echo "  kubectl config use-context kind-$CLUSTER_NAME"
  echo ""
  echo "kind Postgres smoke test passed."
  exit 0
fi

echo "Installing pgwd chart (README quick-start + higher memory for kind)..."
helm upgrade --install pgwd "$CHART_DIR" \
  -n "$NS_PGWD" --create-namespace \
  --set secrets.dbUrl="postgres://user:password@postgres.default.svc.cluster.local:5432/mydb?sslmode=disable" \
  --set env.PGWD_DRY_RUN=true \
  --set env.PGWD_CLIENT="pgwd-demo" \
  --set resources.requests.memory="96Mi" \
  --set resources.requests.cpu="50m" \
  --set resources.limits.memory="256Mi" \
  --set resources.limits.cpu="500m"

echo "Waiting for pgwd rollout (timeout $PGWD_ROLLOUT_TIMEOUT)..."
if ! kubectl rollout status deployment/pgwd -n "$NS_PGWD" --timeout="$PGWD_ROLLOUT_TIMEOUT"; then
  echo "error: pgwd Deployment did not become ready."
  dump_pgwd_diagnostics
  exit 1
fi

echo "--- pgwd logs (tail) ---"
kubectl logs -n "$NS_PGWD" -l "$LABEL_PGWD" --tail=80

echo "Checking logs for successful DB stats (matches published image behaviour)..."
LOG_WAIT_SECS="${PGWD_HELM_E2E_LOG_WAIT_SECS:-180}"
deadline=$((SECONDS + LOG_WAIT_SECS))
ok=0
while (( SECONDS < deadline )); do
  if kubectl logs -n "$NS_PGWD" -l "$LABEL_PGWD" --tail=200 2>/dev/null | grep -qE 'total=[0-9]+ active=[0-9]+'; then
    ok=1
    break
  fi
  sleep 2
done
if [[ "$ok" != "1" ]]; then
  echo "error: did not see total=/active= stats in pgwd logs within ${LOG_WAIT_SECS}s (check DB URL and connectivity)."
  dump_pgwd_diagnostics
  exit 1
fi
echo "Log check OK (Postgres reachable)."

echo ""
echo "kind + Postgres + pgwd (Helm) smoke test passed."

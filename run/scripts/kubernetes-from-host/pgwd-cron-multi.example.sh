#!/usr/bin/env bash
# Example: cron — one pgwd threshold check per in-cluster Postgres (+ Loki notify).
# Copy, chmod +x, replace run_check rows with your Service names, DB names, ports, -client ids.
# Upstream: https://github.com/hrodrig/pgwd
#
# Required:
#   export PGWD_NOTIFICATIONS_SLACK_WEBHOOK='https://hooks.slack.com/...'
# Optional:
#   export KUBECONFIG=/path/to/kubeconfig
#   export PGWD_KUBE_CONTEXT=my-context    # omit for kubectl current-context
#   export PGWD_K8S_NAMESPACE=mynamespace    # default: default
#   export PGWD_NOTIFICATIONS_LOKI_ORG_ID=1  # must match Grafana Loki tenant if used
#   export PGWD_CRON_SLEEP_BETWEEN=5
#
# Cron: PATH must include kubectl (e.g. /snap/bin). Example:
#   PATH=/snap/bin:/usr/local/bin:/usr/bin:/bin
#   */5 * * * * . $HOME/.config/pgwd/env.sh; $HOME/bin/pgwd-cron-multi.sh >> $HOME/log/pgwd-cron.log 2>&1

set -uo pipefail

: "${PGWD_NOTIFICATIONS_SLACK_WEBHOOK:?Set PGWD_NOTIFICATIONS_SLACK_WEBHOOK}"
: "${KUBECONFIG:=${HOME}/.kube/config}"
export KUBECONFIG PGWD_NOTIFICATIONS_SLACK_WEBHOOK

NS="${PGWD_K8S_NAMESPACE:-default}"
LOKI_SVC="${PGWD_K8S_LOKI_SVC:-loki}"
LOKI_ORG="${PGWD_NOTIFICATIONS_LOKI_ORG_ID:-1}"
LOKI_LOCAL="${PGWD_KUBE_LOKI_LOCAL_PORT:-3100}"
SLEEP_BETWEEN="${PGWD_CRON_SLEEP_BETWEEN:-3}"

export PATH="/usr/local/bin:/snap/bin:/usr/bin:/bin:${PATH:-}"

PGWD_BIN="${PGWD:-}"
if [[ -z "${PGWD_BIN}" || ! -x "${PGWD_BIN}" ]]; then
  PGWD_BIN="$(command -v pgwd 2>/dev/null || true)"
fi
if [[ -z "${PGWD_BIN}" || ! -x "${PGWD_BIN}" ]]; then
  echo "pgwd not found; set PGWD or install pgwd in PATH" >&2
  exit 127
fi

kube_ctx_args=()
if [[ -n "${PGWD_KUBE_CONTEXT:-}" ]]; then
  kube_ctx_args=(-kube-context "${PGWD_KUBE_CONTEXT}")
fi

run_check() {
  local name="$1"
  local client="$2"
  local pg_svc="$3"
  local local_port="$4"
  local db_name="$5"

  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) checking ${name}"
  "${PGWD_BIN}" \
    "${kube_ctx_args[@]}" \
    -dry-run=false \
    -interval 0 \
    -notifications-slack-webhook "${PGWD_NOTIFICATIONS_SLACK_WEBHOOK}" \
    -kube-postgres "${NS}/svc/${pg_svc}" \
    -kube-local-port "${local_port}" \
    -db-url "postgres://postgres:DISCOVER_MY_PASSWORD@127.0.0.1:${local_port}/${db_name}?sslmode=disable" \
    -kube-loki "${NS}/svc/${LOKI_SVC}" \
    -kube-loki-local-port "${LOKI_LOCAL}" \
    -notifications-loki-org-id "${LOKI_ORG}" \
    -client "${client}"
}

errs=0
# --- Replace with your K8s Service names, local ports, database names, unique -client values ---
run_check "postgres-a" "pgwd-cron-postgres-a" postgres-a 15432 db_a || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_check "postgres-b" "pgwd-cron-postgres-b" postgres-b 15433 db_b || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_check "postgres-c" "pgwd-cron-postgres-c" postgres-c 15434 db_c || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_check "postgres-d" "pgwd-cron-postgres-d" postgres-d 15435 db_d || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_check "postgres-e" "pgwd-cron-postgres-e" postgres-e 15436 db_e || errs=$((errs + 1))

exit "${errs}"

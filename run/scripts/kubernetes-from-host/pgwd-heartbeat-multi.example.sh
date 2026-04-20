#!/usr/bin/env bash
# Example: heartbeat — pgwd -force-notification per in-cluster Postgres (+ Loki).
# Copy, chmod +x, replace run_hb rows with your Service names, DB names, ports, -client ids.
# Upstream: https://github.com/hrodrig/pgwd
#
# Required:
#   export PGWD_NOTIFICATIONS_SLACK_WEBHOOK='https://hooks.slack.com/...'
# Optional: same as pgwd-cron-multi.example.sh (KUBECONFIG, PGWD_KUBE_CONTEXT, namespace, Loki org, PGWD_CRON_SLEEP_BETWEEN).

set -uo pipefail

: "${PGWD_NOTIFICATIONS_SLACK_WEBHOOK:?Set PGWD_NOTIFICATIONS_SLACK_WEBHOOK}"
: "${KUBECONFIG:=${HOME}/.kube/config}"
export KUBECONFIG PGWD_NOTIFICATIONS_SLACK_WEBHOOK

NS="${PGWD_K8S_NAMESPACE:-default}"
LOKI_SVC="${PGWD_K8S_LOKI_SVC:-loki}"
LOKI_ORG="${PGWD_NOTIFICATIONS_LOKI_ORG_ID:-1}"
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

run_hb() {
  local client="$1"
  local pg_svc="$2"
  local local_port="$3"
  local db_name="$4"
  local loki_local="$5"

  "${PGWD_BIN}" \
    "${kube_ctx_args[@]}" \
    -dry-run=false \
    -interval 0 \
    -notifications-slack-webhook "${PGWD_NOTIFICATIONS_SLACK_WEBHOOK}" \
    -kube-postgres "${NS}/svc/${pg_svc}" \
    -kube-local-port "${local_port}" \
    -db-url "postgres://postgres:DISCOVER_MY_PASSWORD@127.0.0.1:${local_port}/${db_name}?sslmode=disable" \
    -kube-loki "${NS}/svc/${LOKI_SVC}" \
    -kube-loki-local-port "${loki_local}" \
    -notifications-loki-org-id "${LOKI_ORG}" \
    -client "${client}" \
    -force-notification
}

errs=0
# --- Replace with your K8s Service names, local ports, DB names, Loki local ports (avoid clashes) ---
run_hb "pgwd-hb-postgres-a" postgres-a 25432 db_a 3102 || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_hb "pgwd-hb-postgres-b" postgres-b 25433 db_b 3103 || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_hb "pgwd-hb-postgres-c" postgres-c 25434 db_c 3104 || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_hb "pgwd-hb-postgres-d" postgres-d 25435 db_d 3105 || errs=$((errs + 1))
sleep "${SLEEP_BETWEEN}"
run_hb "pgwd-hb-postgres-e" postgres-e 25436 db_e 3106 || errs=$((errs + 1))

exit "${errs}"

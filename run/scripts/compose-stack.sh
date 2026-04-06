#!/usr/bin/env bash
# Wrapper for docker compose: correct --env-file, -f paths, and project name from repo root.
# See run/README.md and per-stack READMEs under run/docker-compose/.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TRAEFIK_OVERLAY=0
DATA_DIR=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <stack> <compose-subcommand> [arguments...]

Run from any directory; paths are resolved relative to the repository clone.

Stacks:
  minimal         run/docker-compose/minimal/docker-compose.yml
  traefik         run/docker-compose/traefik/docker-compose.yml
  observability   run/docker-compose/observability/docker-compose.observability.yml (project: pgwd-obs)

  For Traefik + pgwd + observability on the shared Docker network (pgwd_edge):
  start the traefik stack first, then observability. The observability stack does not
  start Traefik or pgwd; --traefik only adds the Grafana-through-Traefik overlay file.

Options:
  --data-dir DIR   Set PGWD_HOST_DATA for this invocation (otherwise use env PGWD_HOST_DATA)
  --traefik        (observability only) Also load docker-compose.observability.traefik.yml (Grafana via Traefik)
  -h, --help       Show this help

Environment:
  PGWD_HOST_DATA   Host directory for operator files (required):
                   - minimal, traefik:  \${PGWD_HOST_DATA}/.env
                   - observability:     \${PGWD_HOST_DATA}/.env.observability

Examples:
  export PGWD_HOST_DATA=/home/pgwd/pgwd-data
  $(basename "$0") minimal up -d
  $(basename "$0") traefik down
  $(basename "$0") traefik restart
  # Full prod-style stack (order matters):
  $(basename "$0") traefik up -d
  $(basename "$0") --traefik observability up -d
  $(basename "$0") observability logs grafana -f
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --traefik)
      TRAEFIK_OVERLAY=1
      shift
      ;;
    --data-dir)
      [[ -n "${2:-}" ]] || {
        echo "error: --data-dir requires a path" >&2
        exit 1
      }
      DATA_DIR="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ -n "$DATA_DIR" ]]; then
  export PGWD_HOST_DATA="$DATA_DIR"
fi

if [[ -z "${PGWD_HOST_DATA:-}" ]]; then
  echo "error: set PGWD_HOST_DATA or pass --data-dir DIR" >&2
  usage >&2
  exit 1
fi

if [[ $# -lt 2 ]]; then
  echo "error: expected <stack> <compose-subcommand> [...]" >&2
  usage >&2
  exit 1
fi

STACK="$1"
shift
COMPOSE_SUBCMD="$1"
shift

MAIN_ENV="${PGWD_HOST_DATA}/.env"
OBS_ENV="${PGWD_HOST_DATA}/.env.observability"

COMPOSE_ARGS=()

case "$STACK" in
  minimal)
    [[ -f "$MAIN_ENV" ]] || {
      echo "error: missing main env file: $MAIN_ENV" >&2
      exit 1
    }
    COMPOSE_ARGS+=(--env-file "$MAIN_ENV" -f "$ROOT/run/docker-compose/minimal/docker-compose.yml")
    ;;
  traefik)
    [[ -f "$MAIN_ENV" ]] || {
      echo "error: missing main env file: $MAIN_ENV" >&2
      exit 1
    }
    COMPOSE_ARGS+=(--env-file "$MAIN_ENV" -f "$ROOT/run/docker-compose/traefik/docker-compose.yml")
    ;;
  observability)
    [[ -f "$OBS_ENV" ]] || {
      echo "error: missing observability env file: $OBS_ENV" >&2
      exit 1
    }
    COMPOSE_ARGS+=(--env-file "$OBS_ENV" -p pgwd-obs -f "$ROOT/run/docker-compose/observability/docker-compose.observability.yml")
    if [[ "$TRAEFIK_OVERLAY" -eq 1 ]]; then
      COMPOSE_ARGS+=(-f "$ROOT/run/docker-compose/observability/docker-compose.observability.traefik.yml")
    fi
    ;;
  *)
    echo "error: unknown stack: $STACK (use minimal, traefik, or observability)" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ "$STACK" != "observability" && "$TRAEFIK_OVERLAY" -eq 1 ]]; then
  echo "error: --traefik applies only to the observability stack" >&2
  exit 1
fi

cd "$ROOT"
exec docker compose "${COMPOSE_ARGS[@]}" "$COMPOSE_SUBCMD" "$@"

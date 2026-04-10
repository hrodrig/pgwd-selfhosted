#!/usr/bin/env bash
# Wrapper for docker compose: correct --env-file, -f paths from repo root.
# See run/README.md and per-stack READMEs under run/docker-compose/.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DATA_DIR=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <stack> <compose-subcommand> [arguments...]

Run from any directory; paths are resolved relative to the repository clone.

Stacks:
  minimal         run/docker-compose/minimal/docker-compose.yml

Options:
  --data-dir DIR   Set PGWD_HOST_DATA for this invocation (otherwise use env PGWD_HOST_DATA)
  -h, --help       Show this help

Environment:
  PGWD_HOST_DATA   Host directory for operator files (required):
                   - minimal: \${PGWD_HOST_DATA}/.env
  PGWD_DRY_RUN     Optional; for stack minimal, if unset in the shell and missing from .env, the script
                   exports PGWD_DRY_RUN=true before docker compose (safe default without notifiers).

Examples:
  export PGWD_HOST_DATA=/home/pgwd/pgwd-data
  $(basename "$0") minimal up -d
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
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

COMPOSE_ARGS=()

case "$STACK" in
  minimal)
    [[ -f "$MAIN_ENV" ]] || {
      echo "error: missing main env file: $MAIN_ENV" >&2
      exit 1
    }
    COMPOSE_ARGS+=(--env-file "$MAIN_ENV" -f "$ROOT/run/docker-compose/minimal/docker-compose.yml")
    ;;
  *)
    echo "error: unknown stack: $STACK (use minimal)" >&2
    usage >&2
    exit 1
    ;;
esac

# Minimal stack: pgwd requires dry-run or notifiers. If the operator .env omits PGWD_DRY_RUN and the
# shell does not set it, export true so compose file interpolation ${PGWD_DRY_RUN:-true} always
# resolves (avoids "no notifier configured" restart loops when using an older compose copy).
if [[ "$STACK" == "minimal" && -z "${PGWD_DRY_RUN:-}" ]]; then
  if [[ -f "$MAIN_ENV" ]] && ! grep -qE '^[[:space:]]*PGWD_DRY_RUN=' "$MAIN_ENV"; then
    export PGWD_DRY_RUN=true
  fi
fi

cd "$ROOT"
exec docker compose "${COMPOSE_ARGS[@]}" "$COMPOSE_SUBCMD" "$@"

#!/usr/bin/env bash
# Docker compose entry for development stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
COMPOSE_FILES=(-f "$SCRIPT_DIR/docker-compose.yaml" -f "$SCRIPT_DIR/docker-compose.dev.yaml")
DEFAULT_SERVICES=(postgres pgadmin app)

usage() {
  cat <<'USAGE'
Usage: docker/dev.sh <command> [options]

Commands:
  up [--no-migrate] [compose-opts]   启动 Postgres + pgAdmin,默认执行 Flyway 迁移
  down [compose-opts]                停止服务；附加 --volumes 清理匿名卷
  help                               显示本说明

示例:
  docker/dev.sh up --no-migrate
  docker/dev.sh down --volumes
USAGE
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

command="$1"
shift || true

case "$command" in
  up)
    SKIP_MIGRATE=0
    compose_args=()
    while (($#)); do
      case "$1" in
        --no-migrate)
          SKIP_MIGRATE=1
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          compose_args+=("$1")
          ;;
      esac
      shift || true
    done

    if [[ ${#compose_args[@]} -gt 0 ]]; then
      docker compose "${COMPOSE_FILES[@]}" up -d "${compose_args[@]}" "${DEFAULT_SERVICES[@]}"
    else
      docker compose "${COMPOSE_FILES[@]}" up -d "${DEFAULT_SERVICES[@]}"
    fi

    if [[ $SKIP_MIGRATE -eq 0 ]]; then
      docker compose "${COMPOSE_FILES[@]}" run --rm flyway migrate
    fi
    ;;

  down)
    echo "docker compose "${COMPOSE_FILES[@]}" down "$@""
    docker compose "${COMPOSE_FILES[@]}" down "$@"
    ;;

  help|-h|--help)
    usage
    ;;

  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;

esac

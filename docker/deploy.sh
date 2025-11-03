#!/usr/bin/env bash
# Docker compose entry for deploy/CI stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yaml"

usage() {
  cat <<'USAGE'
Usage: docker/deploy.sh <command> [options]

Commands:
  up [--no-migrate] [compose-opts]   启动 Postgres，默认执行 Flyway 迁移
  down [--volumes] [compose-opts]    停止服务；附带 --volumes 会删除宿主数据目录
  help                               显示说明

示例:
  docker/deploy.sh up --no-migrate
  docker/deploy.sh down --volumes
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

    # db 辅助脚本 ensure_pg_data_path 
    # shellcheck disable=SC1090
    source "$SCRIPT_DIR/db/deploy_aux.sh"

    if [[ ${#compose_args[@]} -gt 0 ]]; then
      docker compose -f "$COMPOSE_FILE" up -d "${compose_args[@]}" postgres
    else
      docker compose -f "$COMPOSE_FILE" up -d postgres
    fi

    if [[ $SKIP_MIGRATE -eq 0 ]]; then
      docker compose -f "$COMPOSE_FILE" run --rm flyway migrate
    fi
    ;;

  down)
    docker compose -f "$COMPOSE_FILE" down "$@"
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

#!/usr/bin/env bash
# shellcheck disable=SC2148

# 部署辅助脚本：加载 docker/db/.env 并提供 ensure_pg_data_path。
# 被 docker/deploy.sh 引用；引用即加载环境变量但不主动执行命令。

# 计算 db 目录根路径（当前文件所在目录）。
DB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

set -a
source "$DB_ROOT/.env"
set +a

ensure_pg_data_path() {
  if [[ -z "${PG_DATA_PATH:-}" ]]; then
    echo "[db] PG_DATA_PATH 未设置，请在 docker/db/.env 配置" >&2
    return 1
  fi
  if [[ -d "$PG_DATA_PATH" ]]; then
    echo "[db] 数据目录已存在: $PG_DATA_PATH"
    return 0
  fi
  if mkdir -p "$PG_DATA_PATH"; then
    echo "[db] 已创建数据目录: $PG_DATA_PATH"
    return 0
  fi
  echo "[db] 无法创建数据目录 $PG_DATA_PATH, 请手动创建或调整 PG_DATA_PATH" >&2
  return 1
}

echo "$(cd "$DB_ROOT" && ensure_pg_data_path)" 

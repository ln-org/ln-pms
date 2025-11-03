# Docker Stack Overview

该目录集中维护 ln-pms 的 Docker Compose 相关文件(不维护Dockerfile)，分为两层：

- 根目录：聚合 Compose、脚本入口。
- 组件子目录
    - `db/` ：数据库相关 Compose 片段、环境文件及部署辅助脚本。

## 主要文件

```bash
docker
├── dev.sh      # 开发环境入口脚本
├── deploy.sh   # 部署环境入口脚本
├── docker-compose.yaml     # 部署环境的聚合 Compose
├── docker-compose.dev.yaml # 本地开发环境聚合 Compose
└── db/         # db 组件子目录
```

## 使用方式

### 本地开发

```bash
bash ./dev.sh up             # 启动 Postgres + pgAdmin
bash ./dev.sh down --volumes # 停止并清空匿名卷
```

默认凭据来源于 `db/.env.dev`。匿名卷不会写入宿主机，方便重置。

### 部署 / CI

1. 在 `db/.env` 中配置数据库凭据并设置 `PG_DATA_PATH`（宿主机持久化目录）。
2. 运行：

```bash
bash ./deploy.sh up                # 启动 Postgres 并运行 Flyway 迁移
bash ./deploy.sh up --no-migrate   # 不进行 FLyway 迁移
bash ./deploy.sh down              # 停止服务（不会删除宿主目录）
```

`deploy.sh` 会在启动时自动创建 `PG_DATA_PATH` 指向的目录（若不存在且权限允许）。

## 其他说明

- 各 Compose 文件使用 Docker Compose v2 的 `include` 能力，使不同组件独立维护。
- `docker/db/deploy_aux.sh` 在被 `deploy.sh` 引用时会加载 `.env` 并提供 `ensure_pg_data_path`，保证部署脚本的检查逻辑保持精简。
- 如需扩展其它组件，可参考 `db/` 的组织结构，将对应的 Compose 片段与脚本拆分到专属子目录。

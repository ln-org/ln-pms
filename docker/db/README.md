# 数据库 Compose 栈说明

`docker/db/` 目录中放置了可独立使用的 Compose 配置和脚本，用来在部署环境与本地开发环境下运行 ln-pms 的 PostgreSQL + Flyway 组合。

## 文件说明

```bash
db
├── README.md
├── agents.md
├── .env         # 提供(部署)pg账号,端口,角色密码, `db.yaml` 读取.
├── .env.dev     # 提供(开发)pg账号,端口,角色密码, `db.dev.yaml` 读取.
├── deploy_aux.sh# 部署脚本引用的辅助函数（加载 .env 并检查 PG_DATA_PATH）
├── db.dev.yaml  # 本地开发配置，启动 pg(匿名卷)、Flyway 以及 pgAdmin
└── db.yaml      # 部署配置，数据目录通过 PG_DATA_PATH 指定（必须配置）
```

## 常用命令

```bash
# 启动本地开发栈（Postgres + pgAdmin，可选迁移）
./docker/dev.sh up
./docker/dev.sh up --no-migrate

# 停止本地开发栈
./docker/dev.sh down
./docker/dev.sh down --volumes      # 清空匿名卷中的 Postgres 数据

# 部署/CI 栈
./docker/deploy.sh up
./docker/deploy.sh up --no-migrate
./docker/deploy.sh down
./docker/deploy.sh down --volumes   # 仅删除 Docker 卷，不会自动清理宿主目录
```

若需要统一入口，可使用仓库根目录的 `./dev.sh` / `./deploy.sh`，它们只是简单调用上述脚本。

## 注意事项

- 迁移脚本位于 `../../db/migrations`，执行 `flyway migrate` 时会按照版本顺序运行 `V*__*.sql`。
- `db.yaml` 将数据目录绑定到宿主机 `PG_DATA_PATH`（必须在 `.env` 中配置）。`docker/deploy.sh up` 会尝试自动创建该目录，必要时请提前赋予写权限。
- 开发环境使用匿名卷存储数据，如需重置直接运行 `./docker/dev.sh down --volumes`。

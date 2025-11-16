# LN-PMS

面向测绘/地理信息领域的项目管理系统

---

## 目录结构

LN-PMS

``` bash
ln-pms/
├─ api/         # 后端(Java 21 + Spring Boot 3.? + JPA）
├─ web/         # 前端(Vue 3.x + TypeScript + shadcn-vue + Vite + UnoCss)
├─ db/          # 数据库构建与迁移脚本(Flyway SQL)
├─ docker/      # Compose 与脚本入口，聚合 DB 栈
├─ storage/     # 非结构化数据存储(还没决定用什么)
└─ docs/        # 设计文档与架构说明
```

---

## 主要功能

LN-PMS 的结构与 GitHub 类似：
* **Project(项目)**：相当于仓库（Repo），管理项目基本信息、进度与负责人
* **Stage(阶段)**：相当于Milestone, 对应项目阶段（外业、内业、质检、交付）
* **Issue(问题)**：记录外业/内业问题、风险与处理状态
* **Comment(讨论)**：问题处理过程与附件记录，形成时间线
* **Deliverable(成果)**：项目成果与交付记录（报告、影像、数据等）

---

## 快速开始

* **数据库**：Postgres 17 + Flyway；使用 `docker/dev.sh` / `docker/deploy.sh` 管理
* **后端 / 前端**：本机运行开发，生产环境独立部署（待完善）
* **非结构化数据**：待定

### Docker 入口

请先安装最新版本 docker: `https://docs.docker.com/engine/install/ubuntu/`

```bash
# 启动开发环境
bash ./docker/dev.sh up             # 启动 Postgres + pgAdmin + app(api服务)
bash ./docker/dev.sh down --volumes # 停止

# 部署 / CI 环境
bash ./docker/deploy.sh up      # 启动 读取 docker/db/.env 并校验 PG_DATA_PATH
bash ./docker/deploy.sh down    # 停止
```
数据库连接配置 `docker/db/.env.dev` / `docker/db/.env` (开发/部署)

```bash
# .env 开发环境数据库配置
用户名: lnpms_app
密码: lnpms_app
主机地址: localhost
端口号: 5432
连接的数据库名称: lnpms_db
表在 schema core. 中
```

更多细节见 `docker/README.md` 与 `docker/db/README.md`。

### Docker Compose 手动操作

若不使用脚本，可直接在 `docker/` 目录下执行 Compose 命令：

```bash
cd docker

# 开发环境
# 启动
docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d postgres pgadmin
docker compose -f docker-compose.yaml -f docker-compose.dev.yaml run --rm flyway migrate
# 停止
docker compose -f docker-compose.yaml -f docker-compose.dev.yaml down -v

# 部署/CI
# 启动
docker compose -f docker-compose.yaml up -d postgres
docker compose -f docker-compose.yaml run --rm flyway migrate
#停止
docker compose -f docker-compose.yaml down
```

> 注意：执行前先在 `db/.env` 中设置 `PG_DATA_PATH`,并确保路径存在 (使用脚本会自动创建)。

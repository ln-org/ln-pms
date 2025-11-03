# Docker agents

## File overview
- `docker-compose.yaml`: base stack for staging/production environments; extends the DB definition in `./db/db.yaml`.
- `docker-compose.dev.yaml`: overrides tuned for local work; extends `./db/db.yaml` plus `./db/db.dev.yaml` to layer dev-only tweaks.
- `db/db.yaml` / `db/db.dev.yaml`: standalone Compose files for deploy and dev respectively; can be used directly with `docker compose -f` if needed.
- `db/deploy_env.sh`: 部署脚本引用的辅助函数（自动加载 .env 并校验 PG_DATA_PATH）。
- `docker/dev.sh` / `docker/deploy.sh`: compose entry scripts for dev/CI stacks; repo 根目录的 `./dev.sh` / `./deploy.sh` 会调用它们。
- `../db/migrations`: Flyway SQL migrations (e.g. `V1__init.sql`) run via Flyway services/scripts.
- `db/.env` / `db/.env.dev`: PostgreSQL credentials and port mappings. Copy `db/.env.dev` to `db/.env` (and edit) when preparing a deployable stack.

## Services
### postgres
- Image `postgres:17` exposed on `${PG_PORT:-5432}`.
- Health check waits for `pg_isready`.
- Persists data to the named volume `pg_data` configured with the `local` driver and `driver_opts` (`type=none`, `o=bind`, `device=/srv/ln-pms/postgres`); make sure that host directory exists and is writable before booting. The development override swaps this out for an anonymous volume.
- Flyway migration `V1__init.sql` provisions the application role `lnpms_app` (read/write) and grants it rights on the `core` schema. Create additional roles via future migrations if needed.

### flyway
- Image `flyway/flyway:11` with migrations mounted from `../db/migrations` (read-only).
- Shares the same `db/.env` / `db/.env.dev` credentials as Postgres.
- Depends on a healthy `postgres`; default command is `info`, switch to `migrate` when running migrations.

### pgadmin (dev only)
- Optional UI container enabled via `docker-compose.dev.yaml`; exposed on host port `5050`.

## Volumes
| Name | Mountpoint | Host path | Driver |
| --- | --- | --- | --- |
| `pg_data` | `/var/lib/postgresql/data` | `${PG_DATA_PATH}` | `local` (bind) |

The development override replaces the named data volume with an anonymous one, so nothing is written to the deploy data path during local work. Docker automatically provisions the anonymous volume; prune it with `./dev.sh down --volumes` (or the equivalent `docker compose ... down -v`) when you need a clean slate.

## Environment variables
| Key | Default | Purpose |
| --- | --- | --- |
| `POSTGRES_USER` | `lnpms` | Database user for Postgres and Flyway |
| `POSTGRES_PASSWORD` | `lnpms` | Password shared between Postgres and Flyway |
| `POSTGRES_DB` | `lnpms_db` | Default database created on init |
| `PG_PORT` | `5432` | Host port binding for Postgres |
| `APP_DB_USER` | `lnpms_app` | Application read/write role created by migration |
| `APP_DB_PASSWORD` | `lnpms_app` | Password for the read/write role (`FLYWAY_PLACEHOLDERS_APP_DB_PASSWORD`) |

Flyway picks up its `FLYWAY_URL/USER/PASSWORD/CONNECT_RETRIES` from `docker-compose.yaml`, which interpolates the `POSTGRES_*` values; override them in `.env.dev` / `.env` only if you need different credentials or retry counts.

## Common workflows
### Local development
1. From repo root run `./dev.sh up` (starts postgres + pgadmin; add `--no-migrate` to skip Flyway). 也可直接使用 `docker/dev.sh up`。
2. Tear down the stack with `./dev.sh down`. Add `--volumes` when you need a clean slate.

### Deployment / CI
1. Copy credentials: `cp docker/db/.env.dev docker/db/.env` and adjust secrets（必须填写 `PG_DATA_PATH`）。
2. `docker/deploy.sh up` 会尝试创建 `PG_DATA_PATH`；若需要特殊权限，请提前处理。
3. Use `./deploy.sh up` (或 `docker/deploy.sh up`) to boot the stack; add `--no-migrate` if migrations are managed elsewhere.
4. Stop services with `./deploy.sh down`; append `--volumes` if you need to prune the named data volume (`pg_data` + 宿主目录)。

## Troubleshooting
- Check health: `docker compose ps` and `docker compose logs postgres`.
- If Flyway waits for Postgres, confirm `.env` credentials match container settings.
- When running locally, use `docker volume ls` / `docker volume rm` to inspect or reset the anonymous dev volume; in deployment, inspect `/srv/ln-pms/postgres` directly.

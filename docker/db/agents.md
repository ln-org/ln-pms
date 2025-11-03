# DB Stack Reference

## Compose files
- `db.yaml`: production/CI stack (Postgres 17 + Flyway 11). Uses `./.env` for credentials and persists the database under `${PG_DATA_PATH}` (must be set).
- `deploy_aux.sh`: helper sourced by `docker/deploy.sh` to load `.env` and ensure the bind directory exists.
- `db.dev.yaml`: local development stack (Postgres with anonymous volume, Flyway, pgAdmin). Uses `./.env.dev` and exposes pgAdmin on `localhost:5050`.

## Scripts
- `docker/deploy.sh up|down [options]`: wrapper around `docker-compose.yaml` (which includes `db.yaml`).
  - `up` supports `--no-migrate` to skip Flyway；启动前会根据 `PG_DATA_PATH` 创建宿主目录。
  - Additional flags are forwarded to `docker compose`.
- `docker/dev.sh up|down [options]`: wrapper around `docker-compose.dev.yaml`.
  - `up` starts Postgres and pgAdmin; `--no-migrate` skips Flyway。
  - `down --volumes` removes the anonymous data volume.

Repository-level `./deploy.sh` / `./dev.sh` 仍然可用，它们只是在根目录转调上述脚本。

## Environment files
- `.env`: deployment credentials (copied from `.env.dev` and adjusted for real secrets).
- `.env.dev`: dev credentials (`lnpms` user, default passwords, etc.).

Common variables:
| Key | Purpose |
| --- | ------- |
| `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` | Core Postgres credentials |
| `PG_PORT` | Host port binding for Postgres |
| `APP_DB_USER`, `APP_DB_PASSWORD` | App read/write role created by migrations（默认 `lnpms_app` / `lnpms_app`） |
| `FLYWAY_CONNECT_RETRIES` | Optional retry count for Flyway |

## Migrations
Flyway reads SQL files from `../../db/migrations`. The baseline `V1__init.sql` creates the `core` schema, the `core.users` table, and the application role `lnpms_app` (password sourced from `APP_DB_PASSWORD`).

Run migrations via:
```bash
docker compose -f db.yaml run --rm flyway migrate
# or dev variant
docker compose -f db.dev.yaml run --rm flyway migrate
```
The helper scripts run this automatically unless `--no-migrate` is provided.

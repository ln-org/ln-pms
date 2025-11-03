-- Flyway baseline migration: create core schema and sample table
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS core;

-- Application roles (credentials provided via Flyway placeholders)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${app_db_user}') THEN
        EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', '${app_db_user}', '${app_db_password}');
    END IF;

    EXECUTE format('GRANT USAGE ON SCHEMA core TO %I', '${app_db_user}');
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA core TO %I', '${app_db_user}');
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I', '${app_db_user}');
END
$$;

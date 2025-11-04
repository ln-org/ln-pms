-- Core application schema objects (projects, issues, timelines, deliverables)
CREATE SCHEMA IF NOT EXISTS core;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'project_status' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.project_status AS ENUM (''draft'', ''active'', ''completed'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'stage_status' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.stage_status AS ENUM (''pending'', ''in_progress'', ''done'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'issue_type' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.issue_type AS ENUM (''task'', ''risk'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'issue_status' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.issue_status AS ENUM (''open'', ''in_progress'', ''closed'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'deliverable_status' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.deliverable_status AS ENUM (''draft'', ''submitted'', ''approved'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'member_role' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.member_role AS ENUM (''owner'', ''member'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'auth_provider' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.auth_provider AS ENUM (''wecom'', ''dingtalk'', ''feishu'')';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'identity_status' AND n.nspname = 'core'
    ) THEN
        EXECUTE 'CREATE TYPE core.identity_status AS ENUM (''active'', ''disabled'', ''pending'')';
    END IF;
END
$$;

-- Users
CREATE TABLE IF NOT EXISTS core.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    email TEXT,
    mobile TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deactivated_at TIMESTAMPTZ,
    synced_at TIMESTAMPTZ,
    sync_source TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE core.users IS 'Directory-synced user profiles for LN-PMS.';
COMMENT ON COLUMN core.users.sync_source IS 'Last synchronization provider, e.g. wecom:corpId.';

-- User identities (external providers)
CREATE TABLE IF NOT EXISTS core.user_identities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES core.users(id) ON DELETE CASCADE,
    provider core.auth_provider NOT NULL,
    tenant_key TEXT NOT NULL,
    external_user_id TEXT NOT NULL,
    status core.identity_status NOT NULL DEFAULT 'active',
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,
    profile JSONB NOT NULL DEFAULT '{}'::jsonb,
    credentials JSONB NOT NULL DEFAULT '{}'::jsonb,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (provider, tenant_key, external_user_id),
    UNIQUE (provider, tenant_key, user_id)
);

COMMENT ON TABLE core.user_identities IS 'External identity bindings used for login and synchronization.';

-- Projects
CREATE TABLE IF NOT EXISTS core.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status core.project_status NOT NULL DEFAULT 'draft',
    planned_start_at TIMESTAMPTZ,
    planned_end_at TIMESTAMPTZ,
    actual_start_at TIMESTAMPTZ,
    actual_end_at TIMESTAMPTZ,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_by UUID NOT NULL REFERENCES core.users(id),
    version INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (code)
);

-- Project members
CREATE TABLE IF NOT EXISTS core.project_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES core.users(id) ON DELETE CASCADE,
    role core.member_role NOT NULL,
    note TEXT,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (project_id, user_id, role)
);

-- Project stages
CREATE TABLE IF NOT EXISTS core.project_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    sequence INT NOT NULL,
    status core.stage_status NOT NULL DEFAULT 'pending',
    planned_start_at TIMESTAMPTZ,
    planned_end_at TIMESTAMPTZ,
    actual_start_at TIMESTAMPTZ,
    actual_end_at TIMESTAMPTZ,
    lead_id UUID REFERENCES core.users(id),
    extra JSONB NOT NULL DEFAULT '{}'::jsonb,
    version INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (project_id, sequence)
);

-- Issues
CREATE TABLE IF NOT EXISTS core.issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES core.project_stages(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    type core.issue_type NOT NULL DEFAULT 'task',
    status core.issue_status NOT NULL DEFAULT 'open',
    severity TEXT,
    assignee_id UUID REFERENCES core.users(id),
    reported_by_id UUID REFERENCES core.users(id),
    due_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    version INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_issues_project ON core.issues (project_id);
CREATE INDEX IF NOT EXISTS idx_issues_stage ON core.issues (stage_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON core.issues (status);

-- Issue comments
CREATE TABLE IF NOT EXISTS core.issue_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES core.issues(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES core.users(id),
    body TEXT NOT NULL,
    attachments_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_issue_comments_issue ON core.issue_comments (issue_id);

-- Deliverables
CREATE TABLE IF NOT EXISTS core.deliverables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES core.project_stages(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    status core.deliverable_status NOT NULL DEFAULT 'draft',
    submitted_by UUID REFERENCES core.users(id),
    submitted_at TIMESTAMPTZ,
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMPTZ,
    notes TEXT,
    version INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deliverables_project ON core.deliverables (project_id);

-- Attachments
CREATE TABLE IF NOT EXISTS core.attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket TEXT NOT NULL,
    object_path TEXT NOT NULL,
    filename TEXT NOT NULL,
    mime_type TEXT,
    byte_size BIGINT NOT NULL,
    checksum TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_attachments_bucket_path ON core.attachments (bucket, object_path);

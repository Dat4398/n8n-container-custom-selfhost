--  ← 512 MB-budget PG performance tuning for n8n self-hosting (runs once)
-- ─────────────────────────────────────────────────────────────
--  01-init.sql  — runs once on first container start
--  Creates useful extensions and ensures the n8n user has
--  all needed privileges.
-- ─────────────────────────────────────────────────────────────

-- Enable query statistics (useful for monitoring)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Enable UUID generation helpers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ensure the n8n database and user exist (idempotent)
-- Note: DB & user are already created by the POSTGRES_* env vars.
-- This block adds extra grants / schema setup.

\connect n8n;

-- Allow the n8n user to create schemas (needed for future migrations)
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
GRANT ALL ON SCHEMA public TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO n8n;
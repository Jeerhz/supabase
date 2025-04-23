-- 102‑projects.sql

-- Create projects table (idempotent)
CREATE TABLE IF NOT EXISTS public.projects (
  id                UUID               PRIMARY KEY
                          DEFAULT gen_random_uuid(),
  created_at        TIMESTAMPTZ        NOT NULL
                          DEFAULT now(),
  institution       public.institution NOT NULL,
  country           TEXT,
  sector            public.sector,
  status            public.status,
  project_name      TEXT,
  project_url       TEXT,
  project_id        TEXT,
  commitment_amount NUMERIC,
  approval_date     TIMESTAMPTZ,
  metadata          JSONB,
  region            public.region
);

-- 2) Enable RLS
ALTER TABLE IF EXISTS public.profiles
  ENABLE ROW LEVEL SECURITY;

-- 3) Policies
DROP POLICY IF EXISTS profiles_select ON public.profiles;
CREATE POLICY profiles_select
  ON public.profiles
  FOR SELECT
  USING (true);

CREATE TABLE IF NOT EXISTS public.projects (
  id                UUID                 PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at        TIMESTAMPTZ          NOT NULL DEFAULT now(),
  institution       public.institution   NOT NULL,
  country           TEXT,
  sector            public.sector        NOT NULL,
  status            public.status        NOT NULL,
  project_name      TEXT                 NOT NULL,
  project_url       TEXT,
  project_id        TEXT,
  commitment_amount NUMERIC,
  approval_date     TIMESTAMPTZ,
  metadata          JSONB,
  region            public.region
);

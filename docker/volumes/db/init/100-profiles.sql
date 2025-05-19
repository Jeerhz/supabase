-- 1) Create profiles table if it doesn't exist (now with favorite_project_ids)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL PRIMARY KEY
    REFERENCES auth.users ON DELETE CASCADE,
  updated_at timestamptz,
  username text UNIQUE,
  full_name text,
  avatar_url text,
  website text,
  email text,
  admin_confirmation boolean DEFAULT false,
  favorite_project_ids uuid[] DEFAULT '{}'::uuid[],
  is_admin boolean DEFAULT false,
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- If the table already existed without the new column, add it now:
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS favorite_project_ids uuid[] DEFAULT '{}'::uuid[];

-- 2) Enable RLS
ALTER TABLE IF EXISTS public.profiles
  ENABLE ROW LEVEL SECURITY;

-- 3) Policies
DROP POLICY IF EXISTS profiles_select ON public.profiles;
CREATE POLICY profiles_select
  ON public.profiles
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS profiles_insert ON public.profiles;
CREATE POLICY profiles_insert
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS profiles_update ON public.profiles;
CREATE POLICY profiles_update
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- 4) Trigger function + trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, email)
    VALUES (
      NEW.id,
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'avatar_url',
      NEW.email
    );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user();

-- 5) Storage bucket (idempotent)
INSERT INTO storage.buckets (id, name)
VALUES ('avatars', 'avatars')
ON CONFLICT (id) DO NOTHING;

-- 6) Enable RLS on storage.objects
ALTER TABLE IF EXISTS storage.objects
  ENABLE ROW LEVEL SECURITY;

-- 7) Storage policies
DROP POLICY IF EXISTS storage_objects_select ON storage.objects;
CREATE POLICY storage_objects_select
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS storage_objects_insert ON storage.objects;
CREATE POLICY storage_objects_insert
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'avatars');

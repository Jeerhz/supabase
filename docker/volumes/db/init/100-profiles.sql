-- 1) Create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  updated_at timestamptz,
  username text UNIQUE,
  full_name text,
  avatar_url text,
  website text,
  email text,
  admin_confirmation boolean DEFAULT false,
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- 2) Enable RLS
ALTER TABLE public.profiles
  ENABLE ROW LEVEL SECURITY;

-- 3) Policies (Postgres 15+ supports IF NOT EXISTS)
CREATE POLICY IF NOT EXISTS "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Users can insert their own profile."
  ON public.profiles FOR INSERT WITH CHECK ((auth.uid()) = id);
CREATE POLICY IF NOT EXISTS "Users can update own profile."
  ON public.profiles FOR UPDATE USING ((auth.uid()) = id);

-- 4) Trigger function and trigger (idempotent)
CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, email)
    VALUES (NEW.id,
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.email);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 5) Storage bucket + policies
INSERT INTO storage.buckets (id, name)
  VALUES ('avatars', 'avatars')
  ON CONFLICT (id) DO NOTHING;

CREATE POLICY IF NOT EXISTS "Avatar images are publicly accessible."
  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY IF NOT EXISTS "Anyone can upload an avatar."
  ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');

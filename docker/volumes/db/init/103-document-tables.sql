-- Create themes table
CREATE TABLE IF NOT EXISTS themes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create documents table
CREATE TABLE IF NOT EXISTS documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  file_url TEXT NOT NULL,
  theme_id UUID NOT NULL REFERENCES themes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create theme_useful_links table
CREATE TABLE IF NOT EXISTS theme_useful_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  theme_id UUID NOT NULL REFERENCES themes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_documents_theme_id ON documents(theme_id);
CREATE INDEX IF NOT EXISTS idx_theme_useful_links_theme_id ON theme_useful_links(theme_id);
CREATE INDEX IF NOT EXISTS idx_themes_created_at ON themes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_useful_links ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access (adjust based on your auth requirements)
CREATE POLICY "Allow public read access on themes" ON themes FOR SELECT USING (true);
CREATE POLICY "Allow public read access on documents" ON documents FOR SELECT USING (true);
CREATE POLICY "Allow public read access on theme_useful_links" ON theme_useful_links FOR SELECT USING (true);

-- Create policies for authenticated users to manage data (adjust based on your auth requirements)
-- You might want to restrict this to admin users only
CREATE POLICY "Allow authenticated users to manage themes" ON themes FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage documents" ON documents FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage theme_useful_links" ON theme_useful_links FOR ALL USING (auth.role() = 'authenticated');



-- Create ifi_news table
CREATE TABLE IF NOT EXISTS ifi_news (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  file_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ifi_news_created_at ON ifi_news(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ifi_news_title ON ifi_news(title);

-- Enable Row Level Security (RLS)
ALTER TABLE ifi_news ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access on ifi_news" ON ifi_news FOR SELECT USING (true);

-- Create policies for authenticated users to manage data (adjust based on your auth requirements)
CREATE POLICY "Allow authenticated users to manage ifi_news" ON ifi_news FOR ALL USING (auth.role() = 'authenticated');

-- Create storage bucket policy for ifi-news
INSERT INTO storage.buckets (id, name, public) VALUES ('ifi-news', 'ifi-news', true) ON CONFLICT DO NOTHING;

-- Create storage policies
CREATE POLICY "Allow public read access on ifi-news bucket" ON storage.objects FOR SELECT USING (bucket_id = 'ifi-news');
CREATE POLICY "Allow authenticated users to manage ifi-news bucket" ON storage.objects FOR ALL USING (bucket_id = 'ifi-news' AND auth.role() = 'authenticated');


-- Grant all permissions to public for the ifi-news bucket
-- This allows anyone to SELECT, INSERT, UPDATE, DELETE files in the bucket

-- 1. Allow anyone to view/list files in the ifi-news bucket
CREATE POLICY "Allow public to view ifi-news files" ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'ifi-news');

-- 2. Allow anyone to upload files to the ifi-news bucket
CREATE POLICY "Allow public to upload to ifi-news" ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'ifi-news');

-- 3. Allow anyone to update files in the ifi-news bucket
CREATE POLICY "Allow public to update ifi-news files" ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'ifi-news')
WITH CHECK (bucket_id = 'ifi-news');

-- 4. Allow anyone to delete files from the ifi-news bucket
CREATE POLICY "Allow public to delete ifi-news files" ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'ifi-news');

-- Optional: If you want to allow public access to the bucket itself
-- (This is usually not needed for file operations)
CREATE POLICY "Allow public to access ifi-news bucket" ON storage.buckets
FOR SELECT
TO public
USING (id = 'ifi-news');

-- Create storage bucket policy for documents
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', true) ON CONFLICT DO NOTHING;

-- Grant all permissions to public for the documents bucket
-- This allows anyone to SELECT, INSERT, UPDATE, DELETE files in the bucket

-- 1. Allow anyone to view/list files in the documents bucket
CREATE POLICY "Allow public to view documents files" ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'documents');

-- 2. Allow anyone to upload files to the documents bucket
CREATE POLICY "Allow public to upload to documents" ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'documents');

-- 3. Allow anyone to update files in the documents bucket
CREATE POLICY "Allow public to update documents files" ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'documents')
WITH CHECK (bucket_id = 'documents');

-- 4. Allow anyone to delete files from the documents bucket
CREATE POLICY "Allow public to delete documents files" ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'documents');

-- Optional: If you want to allow public access to the bucket itself
-- (This is usually not needed for file operations)
CREATE POLICY "Allow public to access documents bucket" ON storage.buckets
FOR SELECT
TO public
USING (id = 'documents');


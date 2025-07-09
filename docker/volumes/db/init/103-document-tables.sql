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

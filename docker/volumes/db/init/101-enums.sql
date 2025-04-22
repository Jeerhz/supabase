-- 101-enums.sql

-- 1) Drop any existing enum types
DROP TYPE IF EXISTS public.status;
DROP TYPE IF EXISTS public.region;
DROP TYPE IF EXISTS public.sector;
DROP TYPE IF EXISTS public.institution;

-- 2) Recreate the institution enum
CREATE TYPE public.institution AS ENUM (
  'World Bank (WB)',
  'Agence Française de Développement (AFD)',
  'The African Development Bank (AfDB)',
  'Banque Ouest-Africaine de Développement (BOAD)',
  'Inter-American Development Bank (IDB)',
  'European Investment Bank (EIB)',
  'European Bank for Reconstruction and Development (EBRD)',
  'Asian Development Bank (ADB)',
  'Asian Infrastructure Investment Bank (AIIB)',
  'Millennium Challenge Corporation (MCC)',
  'U.S. Agency for International Development (USAID)',
  'PROPARCO (Groupe AFD)',
  'International Finance Corporation (IFC - World Bank Group)',
  'U.S. International Development Finance Corporation (DFC)',
  'IDB Invest (IDB Group)',
  'United Nations Development Programme (UNDP)'
);

-- 3) Recreate the sector enum
CREATE TYPE public.sector AS ENUM (
  'Energy',
  'Water and Sanitation',
  'Urban Development',
  'Transport',
  'Digital',
  'Agriculture'
);

-- 4) Recreate the region enum
CREATE TYPE public.region AS ENUM (
  'East Asia and Pacific',
  'Africa - Eastern and Southern Africa',
  'Europe and Central Asia',
  'Latin America and Caribbean',
  'Africa - Middle East and North Africa',
  'South Asia',
  'Western and Central Africa',
  'Other/Regional'
);

-- 5) Recreate the status enum
CREATE TYPE public.status AS ENUM (
  'In preparation',
  'Active',
  'Dropped',
  'Closed'
);

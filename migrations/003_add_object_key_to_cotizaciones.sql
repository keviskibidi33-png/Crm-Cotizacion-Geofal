-- Migration: Add object_key column to cotizaciones table
-- This column stores the path to the file in Supabase Storage (bucket/path)

-- Add column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'cotizaciones' AND column_name = 'object_key'
    ) THEN
        ALTER TABLE cotizaciones ADD COLUMN object_key TEXT;
        COMMENT ON COLUMN cotizaciones.object_key IS 'Path to the XLSX file in Supabase Storage (e.g., 2026/COT-2026-001-ClientName.xlsx)';
    END IF;
END $$;

-- Update existing records to generate object_key based on existing data
UPDATE cotizaciones 
SET object_key = year || '/COT-' || year || '-' || numero || '-' || COALESCE(REPLACE(cliente_nombre, ' ', '-'), 'S-N') || '.xlsx'
WHERE object_key IS NULL;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_cotizaciones_object_key ON cotizaciones(object_key);

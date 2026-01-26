-- Crear tabla para plantillas reutilizables de cotizaciones
-- Los vendedores pueden guardar configuraciones de cotizaciones como plantillas
-- para reutilizarlas con diferentes clientes/proyectos

CREATE TABLE IF NOT EXISTS plantillas_cotizacion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    
    -- Vendedor dueño de la plantilla
    vendedor_id UUID NOT NULL REFERENCES auth.users(id),
    
    -- Datos de configuración (sin cliente/proyecto específico)
    items_json JSONB NOT NULL,
    condiciones_ids UUID[] DEFAULT '{}',
    
    -- Condiciones comerciales
    plazo_dias INTEGER,
    condicion_pago TEXT,
    
    -- Metadata
    veces_usada INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_plantillas_vendedor ON plantillas_cotizacion(vendedor_id);
CREATE INDEX idx_plantillas_activo ON plantillas_cotizacion(activo);
CREATE INDEX idx_plantillas_veces_usada ON plantillas_cotizacion(veces_usada);

-- RLS Policies
ALTER TABLE plantillas_cotizacion ENABLE ROW LEVEL SECURITY;

-- Los usuarios solo pueden ver sus propias plantillas
CREATE POLICY "Usuarios ven sus propias plantillas"
    ON plantillas_cotizacion
    FOR SELECT
    TO authenticated
    USING (vendedor_id = auth.uid());

-- Los usuarios pueden crear sus propias plantillas
CREATE POLICY "Usuarios pueden crear plantillas"
    ON plantillas_cotizacion
    FOR INSERT
    TO authenticated
    WITH CHECK (vendedor_id = auth.uid());

-- Los usuarios pueden actualizar sus propias plantillas
CREATE POLICY "Usuarios pueden actualizar sus plantillas"
    ON plantillas_cotizacion
    FOR UPDATE
    TO authenticated
    USING (vendedor_id = auth.uid())
    WITH CHECK (vendedor_id = auth.uid());

-- Los usuarios pueden eliminar sus propias plantillas
CREATE POLICY "Usuarios pueden eliminar sus plantillas"
    ON plantillas_cotizacion
    FOR DELETE
    TO authenticated
    USING (vendedor_id = auth.uid());

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_plantillas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_plantillas_updated_at
    BEFORE UPDATE ON plantillas_cotizacion
    FOR EACH ROW
    EXECUTE FUNCTION update_plantillas_updated_at();

COMMENT ON TABLE plantillas_cotizacion IS 'Almacena plantillas reutilizables de cotizaciones creadas por vendedores';
COMMENT ON COLUMN plantillas_cotizacion.nombre IS 'Nombre descriptivo de la plantilla (ej: "Full Proctor - Estándar")';
COMMENT ON COLUMN plantillas_cotizacion.items_json IS 'Array de items/ensayos con cantidades y precios base';
COMMENT ON COLUMN plantillas_cotizacion.condiciones_ids IS 'Array de UUIDs de condiciones específicas seleccionadas';
COMMENT ON COLUMN plantillas_cotizacion.veces_usada IS 'Contador de cuántas veces se ha aplicado esta plantilla';

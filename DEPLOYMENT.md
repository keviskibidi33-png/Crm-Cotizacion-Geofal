# Despliegue y Actualización

## 🚀 Actualizar Backend (api-geofal-crm) en Producción

Después de agregar nuevos endpoints o cambiar configuración CORS:

### Opción 1: Desde Coolify Dashboard
1. Ir a https://coolify.geofal.com.pe
2. Buscar servicio `quotes-service` o `api-geofal-crm`
3. Click en **"Redeploy"** o **"Restart"**
4. Esperar que el contenedor reinicie (~30 segundos)

### Opción 2: Desde servidor via SSH
```bash
ssh usuario@servidor.geofal.com.pe
cd /ruta/del/proyecto/api-geofal-crm
docker-compose down
docker-compose up -d --build
```

### Opción 3: Coolify CLI (si está configurado)
```bash
coolify deploy api-geofal-crm
```

## 🔧 Cambios Recientes que Requieren Reinicio

### ✅ CORS Origins actualizados
- Agregado: `https://cotizador.geofal.com.pe`
- Agregado: `https://crm.geofal.com.pe`
- **Requiere reinicio del servicio** para aplicar cambios

### ✅ Nuevos Endpoints de Plantillas
- `GET /plantillas?vendedor_id=X`
- `POST /plantillas`
- `GET /plantillas/{id}`
- `PUT /plantillas/{id}`
- `DELETE /plantillas/{id}`
- **Ya están en el código**, solo necesita reinicio

## 🗃️ Migraciones SQL Pendientes

Ejecutar en Supabase SQL Editor (https://db.geofal.com.pe):

### 1. Condiciones Específicas
```bash
migrations/005_condiciones_especificas_table.sql
```

### 2. Plantillas de Cotización
```bash
migrations/006_plantillas_cotizacion.sql
```

## ✅ Verificación Post-Despliegue

### 1. Health Check
```bash
curl https://api.geofal.com.pe/health
# Debe responder: {"status":"ok","service":"quotes-service","db":true}
```

### 2. Verificar CORS
```bash
curl -X OPTIONS https://api.geofal.com.pe/plantillas \
  -H "Origin: https://cotizador.geofal.com.pe" \
  -H "Access-Control-Request-Method: GET" \
  -v
# Debe incluir: Access-Control-Allow-Origin: https://cotizador.geofal.com.pe
```

### 3. Test de Plantillas (con token válido)
```bash
curl https://api.geofal.com.pe/plantillas?vendedor_id=UUID_VENDEDOR
# Debe responder con array de plantillas (puede estar vacío: [])
```

## 🔐 Variables de Entorno

Verificar que el servidor en producción tenga:

```env
QUOTES_DATABASE_URL=postgresql://...
SUPABASE_URL=https://db.geofal.com.pe
SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAi...
QUOTES_CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000,https://cotizador.geofal.com.pe,https://crm.geofal.com.pe
```

## 📝 Logs del Servidor

Ver logs en tiempo real:

```bash
# Docker Compose
docker-compose logs -f quotes-service

# Docker directo
docker logs -f quotes-service

# Coolify Dashboard
Ir a servicio → Logs tab
```

## 🚨 Rollback en Caso de Error

```bash
# Revertir al commit anterior
git reset --hard HEAD~1
git push origin main --force

# O específico
git reset --hard 62b2dbc  # commit antes de plantillas
git push origin main --force

# Luego reiniciar servicio
```

## 📞 Contacto

Para problemas de despliegue contactar al administrador del servidor.

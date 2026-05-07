/* ===============================================================================
ETL INFRASTRUCTURE - FASE 6: MANTENIMIENTO PRE-CARGA (DROPS DINÁMICOS)
===============================================================================
Descripción: 
Este script de SQL Dinámico automatiza la eliminación de Foreign Keys e Índices 
no agrupados antes de una carga masiva al Data Warehouse.

Objetivo: 
Optimizar el rendimiento de la ingesta de datos (Bulk Load) al eliminar la 
sobrecarga de validación de integridad y actualización de índices en tiempo real.
===============================================================================
*/

USE [bd_datawarehouse_sales];
GO

SET NOCOUNT ON;

DECLARE @sql_drop_fks NVARCHAR(MAX) = N'';
DECLARE @sql_drop_indexes NVARCHAR(MAX) = N'';

-- 1. GENERAR CAÍDA DINÁMICA DE FOREIGN KEYS
-- Busca todas las FKs del esquema dbo para eliminarlas temporalmente
SELECT @sql_drop_fks += 'ALTER TABLE ' + QUOTENAME(cs.name) + '.' + QUOTENAME(st.name) + 
                        ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(13)
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS st ON fk.parent_object_id = st.object_id
INNER JOIN sys.schemas AS cs ON st.schema_id = cs.schema_id
WHERE cs.name = 'dbo';

-- 2. GENERAR CAÍDA DINÁMICA DE ÍNDICES (Excepto Primary Keys)
-- Identifica índices no agrupados que podrían ralentizar el INSERT masivo
SELECT @sql_drop_indexes += 'DROP INDEX ' + QUOTENAME(ix.name) + ' ON ' + QUOTENAME(cs.name) + '.' + QUOTENAME(st.name) + ';' + CHAR(13)
FROM sys.indexes AS ix
INNER JOIN sys.tables AS st ON ix.object_id = st.object_id
INNER JOIN sys.schemas AS cs ON st.schema_id = cs.schema_id
WHERE ix.is_primary_key = 0    -- Preservamos las PKs por seguridad
  AND ix.type = 2             -- Índices Non-Clustered
  AND st.is_ms_shipped = 0    -- Solo tablas de usuario
  AND cs.name = 'dbo';

-- 3. EJECUCIÓN DEL SQL DINÁMICO
IF @sql_drop_fks <> N''
BEGIN
    PRINT 'Eliminando restricciones de Foreign Key...';
    EXEC sp_executesql @sql_drop_fks;
END

IF @sql_drop_indexes <> N''
BEGIN
    PRINT 'Eliminando índices no agrupados...';
    EXEC sp_executesql @sql_drop_indexes;
END

PRINT 'Mantenimiento pre-carga finalizado.';
GO
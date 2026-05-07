/* ===============================================================================
ETL INFRASTRUCTURE - FASE 7: LIMPIEZA DE DWH Y CARGA DE DIMENSIÓN TIEMPO
===============================================================================
Descripción: 
Este script prepara el entorno del Data Warehouse para la carga final. 
Realiza el truncamiento de las tablas de dimensiones y la tabla de hechos, 
e invoca la sincronización de la dimensión temporal.

Orden de ejecución recomendado:
1. Ejecutar script 06 (Drop de FKs e Índices).
2. Ejecutar este script (07).
3. Ejecutar procesos de carga masiva de Dimensiones y Hechos.
===============================================================================
*/

USE [bd_datawarehouse_sales];
GO

/* 1. LIMPIEZA DE DIMENSIONES Y FACT TABLE CON VERIFICACIÓN */
-- Se verifica la existencia de cada objeto antes de truncar para evitar errores de ejecución.

PRINT 'Iniciando truncamiento de tablas en el DWH...';

IF OBJECT_ID('[dbo].[DIM_CUSTOMERS]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[DIM_CUSTOMERS];

IF OBJECT_ID('[dbo].[DIM_EMPLOYEES]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[DIM_EMPLOYEES];

IF OBJECT_ID('[dbo].[DIM_PRODUCTS]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[DIM_PRODUCTS];

IF OBJECT_ID('[dbo].[DIM_REGIONS]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[DIM_REGIONS];

IF OBJECT_ID('[dbo].[DIM_AGE_RANGE]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[DIM_AGE_RANGE];

IF OBJECT_ID('[dbo].[FACT_SALES]', 'U') IS NOT NULL
    TRUNCATE TABLE [dbo].[FACT_SALES];

PRINT 'Limpieza completada.';

/* 2. CARGA AUTOMÁTICA DE LA DIMENSIÓN TIEMPO */
-- Sincroniza los datos temporales calculados en la capa intermedia.

IF OBJECT_ID('[dbo].[SP_LOAD_DIM_TIME_DWH]', 'P') IS NOT NULL
BEGIN
    PRINT 'Ejecutando sincronización de DIM_TIME...';
    EXEC [dbo].[SP_LOAD_DIM_TIME_DWH];
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: El procedimiento SP_LOAD_DIM_TIME_DWH no fue encontrado.';
END
GO
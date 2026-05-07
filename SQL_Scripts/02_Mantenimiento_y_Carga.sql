/* ETL INFRASTRUCTURE - FASE 2: MANTENIMIENTO
Descripción: Truncamiento selectivo de tablas e inicialización de dimensión tiempo.
*/

USE [bd_inter_sales];
GO

-- 1. Truncamiento de tablas con verificación de existencia
IF OBJECT_ID('[dbo].[INT_CUSTOMERS_TOTAL]', 'U') IS NOT NULL TRUNCATE TABLE [dbo].[INT_CUSTOMERS_TOTAL];
IF OBJECT_ID('[dbo].[INT_EMPLOYEES]', 'U') IS NOT NULL       TRUNCATE TABLE [dbo].[INT_EMPLOYEES];
IF OBJECT_ID('[dbo].[INT_PRODUCTS]', 'U') IS NOT NULL        TRUNCATE TABLE [dbo].[INT_PRODUCTS];
IF OBJECT_ID('[dbo].[INT_REGIONS]', 'U') IS NOT NULL         TRUNCATE TABLE [dbo].[INT_REGIONS];
IF OBJECT_ID('[dbo].[INT_HOLIDAY]', 'U') IS NOT NULL         TRUNCATE TABLE [dbo].[INT_HOLIDAY];
IF OBJECT_ID('[dbo].[INT_AGE_RANGE]', 'U') IS NOT NULL       TRUNCATE TABLE [dbo].[INT_AGE_RANGE];
IF OBJECT_ID('[dbo].[INT_FACT_SALES]', 'U') IS NOT NULL      TRUNCATE TABLE [dbo].[INT_FACT_SALES];
GO

-- 2. Carga automática de la dimensión tiempo mediante SP
IF OBJECT_ID('[dbo].[SP_LOAD_INT_TIME]', 'P') IS NOT NULL
BEGIN
    EXEC [dbo].[SP_LOAD_INT_TIME];
END;
GO
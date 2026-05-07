/* ===============================================================================
ETL INFRASTRUCTURE - FASE 5: CARGA DE DIMENSIÓN TIEMPO (DWH)
===============================================================================
Descripción: 
Este Stored Procedure sincroniza la dimensión de tiempo desde la capa intermedia
hacia la capa final del Data Warehouse (bd_datawarehouse_sales).

Al realizar un traspaso directo, se mantiene la integridad de las llaves (KEY_TIME)
generadas previamente, facilitando la consistencia en el esquema en estrella.
===============================================================================
*/

USE [bd_datawarehouse_sales];
GO

/* 1. ELIMINAR EL SP SI YA EXISTE */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_LOAD_DIM_TIME_DWH]') AND type in (N'P'))
BEGIN
    DROP PROCEDURE [dbo].[SP_LOAD_DIM_TIME_DWH];
END;
GO

/* 2. CREACIÓN DEL STORED PROCEDURE DE CARGA FINAL */
CREATE PROCEDURE [dbo].[SP_LOAD_DIM_TIME_DWH]
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpieza de la tabla de destino en el DWH para asegurar una carga limpia
    TRUNCATE TABLE [dbo].[DIM_TIME];

    -- Traspaso directo de datos pre-calculados desde la capa Intermedia
    INSERT INTO [dbo].[DIM_TIME] (
        [KEY_TIME], 
        [FULL_DATE], 
        [DAY], 
        [MONTH], 
        [MONTH_NAME], 
        [YEAR], 
        [QUARTER], 
        [SEMESTER], 
        [WEEKDAY], 
        [WEEKDAY_NAME], 
        [WEEK_NUMBER], 
        [DAY_OF_YEAR]
    )
    SELECT 
        [KEY_TIME], 
        [FULL_DATE], 
        [DAY], 
        [MONTH], 
        [MONTH_NAME], 
        [YEAR], 
        [QUARTER], 
        [SEMESTER], 
        [WEEKDAY], 
        [WEEKDAY_NAME], 
        [WEEK_NUMBER], 
        [DAY_OF_YEAR]
    FROM [bd_inter_sales].[dbo].[INT_TIME]; 
    
    PRINT 'Sincronización de DIM_TIME completada exitosamente.';
END;
GO
/* ETL INFRASTRUCTURE - FASE 1: DIMENSIÓN TIEMPO
Descripción: Creación de la tabla de dimensiones temporal y Stored Procedure de carga dinámica.
Nota: El rango de fechas se ajusta automáticamente según los datos existentes en Staging.
*/

USE [bd_inter_sales];
GO

-- 1. ESTRUCTURA DE LA TABLA DE TIEMPO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_TIME]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_TIME](
        [KEY_TIME] [int] NOT NULL,
        [FULL_DATE] [date] NULL,
        [DAY] [int] NULL,
        [MONTH] [int] NULL,
        [MONTH_NAME] [nvarchar](50) NULL,
        [YEAR] [int] NULL,
        [QUARTER] [int] NULL,
        [SEMESTER] [int] NULL,
        [WEEKDAY] [int] NULL,
        [WEEKDAY_NAME] [nvarchar](50) NULL,
        [WEEK_NUMBER] [int] NULL,
        [DAY_OF_YEAR] [int] NULL,
        CONSTRAINT [PK_INT_TIME] PRIMARY KEY CLUSTERED ([KEY_TIME] ASC)
    )
END;
GO

-- 2. ELIMINAR EL SP SI YA EXISTE (Para actualización de lógica)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_LOAD_INT_TIME]') AND type in (N'P'))
BEGIN
    DROP PROCEDURE [dbo].[SP_LOAD_INT_TIME];
END;
GO

-- 3. CREACIÓN DEL STORED PROCEDURE DE CARGA DINÁMICA
CREATE PROCEDURE [dbo].[SP_LOAD_INT_TIME]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;

    -- Obtenemos los rangos dinámicos desde Staging para cubrir todo el espectro de datos
    SELECT @StartDate = MIN(date) FROM [bd_staging_sales].[dbo].[STG_SQL_BILLING];
    SELECT @EndDate = MAX(date) FROM [bd_staging_sales].[dbo].[STG_MYSQL_BILLING];

    -- Si no hay datos en staging, evitar error de carga
    IF @StartDate IS NULL SET @StartDate = GETDATE();
    IF @EndDate IS NULL SET @EndDate = GETDATE();

    -- Limpieza interna antes de recargar
    TRUNCATE TABLE [dbo].[INT_TIME];

    -- Generación de fechas mediante CTE recursivo
    WITH Fechas(Fecha) AS (
        SELECT @StartDate
        UNION ALL
        SELECT DATEADD(d, 1, Fecha)
        FROM Fechas
        WHERE Fecha < @EndDate
    )
    INSERT INTO [dbo].[INT_TIME] (
        [KEY_TIME], [FULL_DATE], [DAY], [MONTH], [MONTH_NAME], [YEAR], 
        [QUARTER], [SEMESTER], [WEEKDAY], [WEEKDAY_NAME], [WEEK_NUMBER], [DAY_OF_YEAR]
    )
    SELECT 
        (YEAR(Fecha) * 10000) + (MONTH(Fecha) * 100) + DAY(Fecha) AS [KEY_TIME], -- Formato AAAAMMDD
        Fecha AS [FULL_DATE],
        DAY(Fecha) AS [DAY], 
        MONTH(Fecha) AS [MONTH], 
        DATENAME(MONTH, Fecha) AS [MONTH_NAME], 
        YEAR(Fecha) AS [YEAR], 
        DATEPART(QUARTER, Fecha) AS [QUARTER], 
        (DATEPART(QUARTER, Fecha) + 1) / 2 AS [SEMESTER], 
        DATEPART(WEEKDAY, Fecha) AS [WEEKDAY], 
        DATENAME(WEEKDAY, Fecha) AS [WEEKDAY_NAME], 
        DATEPART(WEEK, Fecha) AS [WEEK_NUMBER], 
        DATEPART(DAYOFYEAR, Fecha) AS [DAY_OF_YEAR]
    FROM Fechas
    OPTION (MAXRECURSION 0);
END;
GO
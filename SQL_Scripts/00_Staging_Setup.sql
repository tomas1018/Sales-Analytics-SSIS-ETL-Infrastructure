/* ETL INFRASTRUCTURE - FASE 0: STAGING SETUP
Descripción: Creación de base de datos bd_staging_sales y tablas de ingesta cruda.
Nota: Se utiliza NVARCHAR(255) para evitar fallos de truncado en la carga inicial.
*/

USE [master];
GO

-- Creación de la base de datos de Staging
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'bd_staging_sales')
BEGIN
    CREATE DATABASE [bd_staging_sales];
END;
GO

USE [bd_staging_sales];
GO

-- 1. CLIENTE MAYORISTA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_CLIENTE_MAYORISTA]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_CLIENTE_MAYORISTA](
        [CUSTOMER_ID] NVARCHAR(255) NULL,
        [FULL_NAME] NVARCHAR(255) NULL,
        [BIRTH_DATE] NVARCHAR(255) NULL,
        [CITY] NVARCHAR(255) NULL,
        [STATE] NVARCHAR(255) NULL,
        [ZIPCODE] NVARCHAR(255) NULL
    )
END;

-- 2. CLIENTE MINORISTA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_CLIENTE_MINORISTA]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_CLIENTE_MINORISTA](
        [CUSTOMER_ID] NVARCHAR(255) NULL,
        [FULL_NAME] NVARCHAR(255) NULL,
        [BIRTH_DATE] NVARCHAR(255) NULL,
        [CITY] NVARCHAR(255) NULL,
        [STATE] NVARCHAR(255) NULL,
        [ZIPCODE] NVARCHAR(255) NULL
    )
END;

-- 3. EMPLEADOS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_EMPLEADOS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_EMPLEADOS](
        [EMPLOYEE_ID] NVARCHAR(255) NULL,
        [FULL_NAME] NVARCHAR(255) NULL,
        [CATEGORY] NVARCHAR(255) NULL,
        [EMPLOYMENT_DATE] NVARCHAR(255) NULL,
        [BIRTH_DATE] NVARCHAR(255) NULL,
        [EDUCATION_LEVEL] NVARCHAR(255) NULL,
        [GENDER] NVARCHAR(255) NULL
    )
END;

-- 4. HOLIDAY (Corregido de Holyday a Holiday en el comentario por profesionalismo)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_HOLYDAY]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_HOLYDAY](
        [DATE] NVARCHAR(255) NULL,
        [HOLIDAY] NVARCHAR(255) NULL
    )
END;

-- 5. MYSQL BILLING DETAIL
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_MYSQL_BILLING_DETAIL]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_MYSQL_BILLING_DETAIL](
        [BILLING_ID] NVARCHAR(255) NULL,
        [PRODUCT_ID] NVARCHAR(255) NULL,
        [QUANTITY] NVARCHAR(255) NULL
    )
END;

-- 6. MYSQL BILLING
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_MYSQL_BILLING]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_MYSQL_BILLING](
        [BILLING_ID] NVARCHAR(255) NULL,
        [REGION] NVARCHAR(255) NULL,
        [BRANCH_ID] NVARCHAR(255) NULL,
        [DATE] NVARCHAR(255) NULL,
        [CUSTOMER_ID] NVARCHAR(255) NULL,
        [EMPLOYEE_ID] NVARCHAR(255) NULL
    )
END;

-- 7. MYSQL DESCUENTOS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_MYSQL_DESCUENTOS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_MYSQL_DESCUENTOS](
        [DISCOUNT_ID] NVARCHAR(255) NULL,
        [FROM] NVARCHAR(255) NULL,
        [UNTIL] NVARCHAR(255) NULL,
        [TOTAL_BILLING] NVARCHAR(255) NULL,
        [PERCENTAGE] NVARCHAR(255) NULL
    )
END;

-- 8. MYSQL PRICE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_MYSQL_PRICE]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_MYSQL_PRICE](
        [PRODUCT_ID] NVARCHAR(255) NULL,
        [DATE] NVARCHAR(255) NULL,
        [PRICE] NVARCHAR(255) NULL
    )
END;

-- 9. PRODUCTOS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_PRODUCTOS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_PRODUCTOS](
        [PRODUCT_ID] NVARCHAR(255) NULL,
        [PRODUCT_NAME] NVARCHAR(255) NULL,
        [CAPACITY] NVARCHAR(255) NULL
    )
END;

-- 10. REGIONES
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_REGIONES]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_REGIONES](
        [AREA] NVARCHAR(255) NULL,
        [REGION] NVARCHAR(255) NULL,
        [CITY] NVARCHAR(255) NULL,
        [ZIPCODE] NVARCHAR(255) NULL
    )
END;

-- 11. SQL BILLING
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_SQL_BILLING]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_SQL_BILLING](
        [ID] NVARCHAR(255) NULL,
        [BILLING_ID] NVARCHAR(255) NULL,
        [DATE] NVARCHAR(255) NULL,
        [CUSTOMER_ID] NVARCHAR(255) NULL,
        [EMPLOYEE_ID] NVARCHAR(255) NULL,
        [PRODUCT_ID] NVARCHAR(255) NULL,
        [QUANTITY] NVARCHAR(255) NULL,
        [REGION] NVARCHAR(255) NULL
    )
END;

-- 12. STOCK
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stg_STOCK]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[stg_STOCK](
        [PRODUCT_ID] NVARCHAR(255) NULL,
        [INTERACTION_DATE] NVARCHAR(255) NULL,
        [QUANTITY] NVARCHAR(255) NULL
    )
END;
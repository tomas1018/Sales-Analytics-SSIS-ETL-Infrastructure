/* ===============================================================================
ETL INFRASTRUCTURE - FASE 4: DATA WAREHOUSE FINAL (STAR SCHEMA)
===============================================================================
Descripción: 
Creación de la base de datos definitiva para explotación de datos (Reporting/BI).
Se implementa un diseño de Esquema en Estrella con tablas de dimensiones (DIM)
y una tabla de hechos (FACT).

Cambios:
- Uso de BIGINT en la Fact Table para soportar volúmenes masivos (+1.6M filas).
- Indexación Clustered en llaves primarias para optimización de JOINs.
- Separación de preocupaciones: De Staging -> Intermedia -> Data Warehouse.
===============================================================================
*/

-- 1. Creación de la base de datos de Data Warehouse
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'bd_datawarehouse_sales')
BEGIN
    CREATE DATABASE [bd_datawarehouse_sales];
END;
GO

USE [bd_datawarehouse_sales];
GO

/* ============================================================
   SECCIÓN: DIMENSIONES (DIM TABLES)
   ============================================================ */

-- DIMENSIÓN CUSTOMERS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_CUSTOMERS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_CUSTOMERS](
        [CUSTOMER_ID] [int] NOT NULL, 
        [FULL_NAME] [nvarchar](255) NULL,
        [BIRTH_DATE] [datetime] NULL,
        [CUSTOMER_AGE] [int] NULL,
        [CITY] [nvarchar](255) NULL,
        [STATE] [nvarchar](255) NULL,
        [ZIPCODE] [nvarchar](255) NULL,
        [CUSTOMER_TYPE] [nvarchar](9) NULL,
        CONSTRAINT [PK_DIM_CUSTOMER] PRIMARY KEY CLUSTERED ([CUSTOMER_ID] ASC)
    )
END;

-- DIMENSIÓN EMPLOYEES
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_EMPLOYEES]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_EMPLOYEES](
        [EMPLOYEE_ID] [int] NOT NULL,
        [FULL_NAME] [nvarchar](255) NULL,
        [CATEGORY] [nvarchar](255) NULL,
        [GENDER] [nvarchar](255) NULL,
        [EMPLOYMENT_DATE] [datetime] NULL,
        [BIRTH_DATE] [datetime] NULL,
        CONSTRAINT [PK_DIM_EMPLOYEE] PRIMARY KEY CLUSTERED ([EMPLOYEE_ID] ASC)
    )
END;

-- DIMENSIÓN PRODUCTS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_PRODUCTS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_PRODUCTS](
        [PRODUCT_ID] [int] NOT NULL,
        [PRODUCT_NAME] [nvarchar](255) NULL,
        [LITERS] [decimal](18, 2) NULL, 
        [PACKAGING_TYPE] [nvarchar](50) NULL, 
        [IS_CAN] [int] NULL,
        CONSTRAINT [PK_DIM_PRODUCT] PRIMARY KEY CLUSTERED ([PRODUCT_ID] ASC)
    )
END;

-- DIMENSIÓN REGIONS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_REGIONS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_REGIONS](
        [REGION_ID] [int] IDENTITY(1,1) NOT NULL,
        [REGION_NAME] [nvarchar](255) NULL,
        [AREA] [nvarchar](255) NULL,
        [CITY] [nvarchar](255) NULL,
        [ZIPCODE] [nvarchar](255) NULL,
        CONSTRAINT [PK_DIM_REGION] PRIMARY KEY CLUSTERED ([REGION_ID] ASC)
    )
END;

-- DIMENSIÓN AGE RANGE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_AGE_RANGE]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_AGE_RANGE](
        [AgeRangeID] [int] IDENTITY(1,1) NOT NULL,
        [AGE_RANGE_NAME] [nvarchar](50) NULL,
        [MinAge] [int] NULL, 
        [MaxAge] [int] NULL, 
        CONSTRAINT [PK_DIM_AGE_RANGE] PRIMARY KEY CLUSTERED ([AgeRangeID] ASC)
    )
END;

-- DIMENSIÓN TIME
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIM_TIME]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[DIM_TIME](
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
        CONSTRAINT [PK_DIM_TIME] PRIMARY KEY CLUSTERED ([KEY_TIME] ASC)
    )
END;

/* ============================================================
   SECCIÓN: TABLA DE HECHOS (FACT TABLE)
   ============================================================ */

-- TABLA DE HECHOS: FACT_SALES
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FACT_SALES]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[FACT_SALES](
        [Fact_SalesKey] [bigint] IDENTITY(1,1) NOT NULL, -- BIGINT para escalar a millones de registros
        [BillingID] [int] NOT NULL,
        [CustomerID] [int] NOT NULL,
        [EmployeeID] [int] NOT NULL,
        [ProductID] [int] NOT NULL,
        [RegionID]  [int] NOT NULL,
        [TimeKey] [int] NOT NULL,
        [TransactionTimestamp] [datetime] NULL,
        [Month] [nvarchar](50) NULL,
        [Year] [int] NULL,
        [IsHoliday] [nvarchar](3) NULL,
        [HolidayDescription] [nvarchar](100) NULL,
        [ValidatedRegion] [nvarchar](100) NULL,
        [CustomerZipCode] [nvarchar](255) NOT NULL,
        [AgeRangeID] [int] NOT NULL,
        [PackagingType] [nvarchar](50) NULL,
        [Quantity] [decimal](18, 1) NULL,
        [LitersSold] [decimal](18, 1) NULL,
        [ListUnitPrice] [decimal](18, 2) NULL,
        [DiscountPercentage] [decimal](18, 2) NULL,
        [GrossLineTotal] [decimal](18, 2) NULL,
        [NetLineTotal] [decimal](18, 2) NULL,
        [GlobalCartTotal] [decimal](18, 2) NULL,
        CONSTRAINT [PK_FACT_SALES] PRIMARY KEY CLUSTERED ([Fact_SalesKey] ASC)
    ) ON [PRIMARY];
END;
GO
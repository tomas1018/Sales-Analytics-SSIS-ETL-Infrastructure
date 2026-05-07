/* ETL INFRASTRUCTURE - FASE 1: DDL
Descripción: Creación de base de datos bd_inter_sales y tablas.
*/

USE [master];
GO

-- 1. Creación de la base de datos intermedia
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'bd_inter_sales')
BEGIN
    CREATE DATABASE [bd_inter_sales];
END;
GO

USE [bd_inter_sales];
GO

-- 2. Creación de tablas de dimensiones e intermedia
/* TABLA CUSTOMERS */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_CUSTOMERS_TOTAL]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_CUSTOMERS_TOTAL](
        [CUSTOMER_ID] [int] NOT NULL,
        [FULL_NAME] [nvarchar](255) NULL,
        [BIRTH_DATE] [datetime] NULL,
        [CUSTOMER_AGE] [int] NULL,
        [CITY] [nvarchar](255) NULL,
        [STATE] [nvarchar](255) NULL,
        [ZIPCODE] [nvarchar](255) NULL,
        [CUSTOMER_TYPE] [nvarchar](9) NULL,
        CONSTRAINT [PK_CUSTOMER] PRIMARY KEY CLUSTERED ([CUSTOMER_ID] ASC)
    )
END;

/* TABLA EMPLOYEES */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_EMPLOYEES]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_EMPLOYEES](
        [EMPLOYEE_ID] [int] NOT NULL,
        [FULL_NAME] [nvarchar](255) NULL,
        [CATEGORY] [nvarchar](255) NULL,
        [GENDER] [nvarchar](255) NULL,
        [EMPLOYMENT_DATE] [datetime] NULL,
        [BIRTH_DATE] [datetime] NULL,
        CONSTRAINT [PK_EMPLOYEE] PRIMARY KEY CLUSTERED ([EMPLOYEE_ID] ASC)
    )
END;

/* TABLA PRODUCTS */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_PRODUCTS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_PRODUCTS](
        [PRODUCT_ID] [int] NOT NULL,
        [PRODUCT_NAME] [nvarchar](255) NULL,
        [LITERS] [decimal](18, 2) NULL, 
        [PACKAGING_TYPE] [nvarchar](50) NULL, 
        [IS_CAN] [int] NULL,
        CONSTRAINT [PK_PRODUCT] PRIMARY KEY CLUSTERED ([PRODUCT_ID] ASC)
    )
END;

/* TABLA REGIONS */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_REGIONS]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_REGIONS](
        [REGION_ID] [int] IDENTITY(1,1) NOT NULL,
        [REGION_NAME] [nvarchar](255) NULL,
        [AREA] [nvarchar](255) NULL,
        [CITY] [nvarchar](255) NULL,
        [ZIPCODE] [nvarchar](255) NULL,
        CONSTRAINT [PK_REGION] PRIMARY KEY CLUSTERED ([REGION_ID] ASC)
    )
END;

/* TABLA FACT SALES */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INT_FACT_SALES]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[INT_FACT_SALES](
        [Fact_SalesKey] [int] IDENTITY(1,1) NOT NULL, 
        [BillingID] [int] NOT NULL,
        [CustomerID] [int] NULL,
        [EmployeeID] [int] NULL,
        [ProductID] [int] NULL,
        [RegionID] [int] NULL,
        [TimeKey] [int] NULL,
        [TransactionTimestamp] [datetime] NULL,
        [Month] [nvarchar](50) NULL,
        [Year] [int] NULL,
        [IsHoliday] [nvarchar](3) NULL,
        [HolidayDescription] [nvarchar](100) NULL,
        [ValidatedRegion] [nvarchar](100) NULL,
        [CustomerZipCode] [nvarchar](255) NULL,
        [AgeRangeID] [int] NULL,
        [PackagingType] [nvarchar](50) NULL,
        [Quantity] [decimal](18, 1) NULL,
        [LitersSold] [decimal](18, 1) NULL,
        [ListUnitPrice] [decimal](18, 2) NULL,
        [DiscountPercentage] [decimal](18, 2) NULL,
        [GrossLineTotal] [decimal](18, 2) NULL,
        [NetLineTotal] [decimal](18, 2) NULL,
        [GlobalCartTotal] [decimal](18, 2) NULL,
        CONSTRAINT [PK_INT_FACT_SALES] PRIMARY KEY CLUSTERED ([Fact_SalesKey] ASC)
    ) ON [PRIMARY];
END;
GO
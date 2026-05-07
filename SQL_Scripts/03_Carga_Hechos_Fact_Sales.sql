/* ===============================================================================
ETL INFRASTRUCTURE - FASE 3: TRANSFORMACIÓN Y CARGA DE HECHOS (FACT_SALES)
===============================================================================
Descripción: 
Este script realiza la unificación de fuentes híbridas (SQL Server y MySQL), 
aplica lógica de precios históricos (SCD Tipo 2) y calcula descuentos 
dinámicos por volumen y fecha.

Técnicas utilizadas:
- Common Table Expressions (CTE) para modularidad.
- Funciones de ventana (LEAD, ROW_NUMBER) para vigencia de precios.
- Normalización de tipos de datos (Cast y Replace).
- Enriquecimiento de datos (Joins con dimensiones de tiempo, edad y región).
===============================================================================
*/

USE [bd_inter_sales];
GO

-- 1. CTE para gestionar la vigencia de precios de productos
WITH cte_precio_base AS 
(
    SELECT
        PRODUCT_ID,
        TRY_CAST(DATE AS DATETIME) AS FechaDesde,
        LEAD(TRY_CAST(DATE AS DATETIME)) OVER (PARTITION BY PRODUCT_ID ORDER BY TRY_CAST(DATE AS DATETIME)) AS FechaHasta,
        TRY_CAST(REPLACE(PRICE, ',', '.') AS DECIMAL(18,4)) AS PRICE,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID ORDER BY TRY_CAST(DATE AS DATETIME) ASC) AS FirstPrice,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID ORDER BY TRY_CAST(DATE AS DATETIME) DESC) AS LastPrice
    FROM [bd_staging_sales].[dbo].[stg_MYSQL_PRICE]
),
cte_precio AS
(
    SELECT 
        PRODUCT_ID,
        CASE WHEN FirstPrice = 1 THEN CAST('1900-01-01' AS DATETIME) ELSE FechaDesde END AS StartDate,
        CASE WHEN LastPrice = 1 THEN CAST('9999-12-31' AS DATETIME) ELSE FechaHasta END AS EndDate,
        PRICE
    FROM cte_precio_base
    WHERE PRICE IS NOT NULL
),

-- 2. Unificación de fuentes de facturación (SQL Server + MySQL)
cte_facturacion_union AS
(
    SELECT BILLING_ID, TRY_CAST(DATE AS DATETIME) AS DATE, CUSTOMER_ID, EMPLOYEE_ID, PRODUCT_ID,
           TRY_CAST(REPLACE(QUANTITY, ',', '.') AS DECIMAL(18,4)) AS QUANTITY, REGION
    FROM [bd_staging_sales].[dbo].[stg_SQL_BILLING]
    UNION ALL
    SELECT MySql.BILLING_ID, TRY_CAST(MySql.DATE AS DATETIME) AS DATE, MySql.CUSTOMER_ID, MySql.EMPLOYEE_ID,
           MySqlDetail.PRODUCT_ID,
           TRY_CAST(REPLACE(MySqlDetail.QUANTITY, ',', '.') AS DECIMAL(18,4)) AS QUANTITY,
           MySql.REGION
    FROM [bd_staging_sales].[dbo].[stg_MYSQL_BILLING] AS MySql
    INNER JOIN [bd_staging_sales].[dbo].[stg_MYSQL_BILLING_DETAIL] AS MySqlDetail
        ON MySql.BILLING_ID = MySqlDetail.BILLING_ID
),

-- 3. Cálculo del total bruto por factura para aplicar descuentos por escala
cte_facturacion_total_por_factura AS 
(
    SELECT fu.BILLING_ID, fu.DATE,
           SUM(fu.QUANTITY * ISNULL(p.PRICE, 0)) AS TOTAL_BRUTO_FACTURA
    FROM cte_facturacion_union AS fu
    LEFT JOIN cte_precio AS p ON fu.PRODUCT_ID = p.PRODUCT_ID AND fu.DATE >= p.StartDate AND fu.DATE < p.EndDate
    GROUP BY fu.BILLING_ID, fu.DATE
),

-- 4. Lógica compleja de descuentos estacionales y por volumen
cte_descuentos AS
(
    SELECT ft.BILLING_ID, 
           (100.0 - TRY_CAST(REPLACE(MAX(sd.PERCENTAGE), ',', '.') AS DECIMAL(18,4))) / 100.0 AS FACTOR_PRECIO,
           MAX(TRY_CAST(REPLACE(sd.PERCENTAGE, ',', '.') AS DECIMAL(18,4))) AS Porcentaje_Descuento
    FROM cte_facturacion_total_por_factura AS ft
    INNER JOIN [bd_staging_sales].[dbo].[stg_MYSQL_DESCUENTOS] sd 
        ON ft.TOTAL_BRUTO_FACTURA >= TRY_CAST(REPLACE(sd.TOTAL_BILLING, ',', '.') AS DECIMAL(18,4))
        AND ft.DATE >= TRY_CAST(sd.[FROM] AS DATETIME) 
        AND (
            (sd.PERCENTAGE IN ('10', '20') AND ft.DATE <= TRY_CAST(sd.UNTIL AS DATETIME))
            OR (sd.PERCENTAGE IN ('15', '25'))
        )
    GROUP BY ft.BILLING_ID
)

-- 5. Inserción final en la tabla de Hechos con enriquecimiento de dimensiones
INSERT INTO [bd_inter_sales].[dbo].[INT_FACT_SALES] 
(
    BillingID, CustomerID, EmployeeID, ProductID, RegionID, TimeKey, TransactionTimestamp, 
    Month, Year, IsHoliday, HolidayDescription, ValidatedRegion, CustomerZipCode,
    AgeRangeID, PackagingType, Quantity, LitersSold, ListUnitPrice, 
    DiscountPercentage, GrossLineTotal, NetLineTotal, GlobalCartTotal
)
SELECT 
    bu.BILLING_ID,
    bu.CUSTOMER_ID,
    bu.EMPLOYEE_ID,
    bu.PRODUCT_ID,
    reg.REGION_ID, 
    (YEAR(bu.DATE) * 10000) + (MONTH(bu.DATE) * 100) + DAY(bu.DATE),
    bu.DATE,
    t.MONTH_NAME,
    t.YEAR,
    CASE WHEN h.DATE IS NOT NULL THEN 'YES' ELSE 'NO' END,
    h.HOLIDAY_NAME,
    reg.REGION_NAME,
    -- Normalización de códigos postales a 5 dígitos
    RIGHT('00000' + CAST(CAST(cus.ZIPCODE AS BIGINT) AS VARCHAR(10)), 5) AS CustomerZipCode,
    ar.AgeRangeID, 
    dp.Packaging_type,
    CAST(bu.QUANTITY AS DECIMAL(18,1)),
    CAST((bu.QUANTITY * TRY_CAST(REPLACE(dp.Liters, ',', '.') AS DECIMAL(18,4))) AS DECIMAL(18,1)),
    CAST(ISNULL(Precios.PRICE, 0) AS DECIMAL(18,2)),
    CAST(COALESCE(d.Porcentaje_Descuento, 0) AS DECIMAL(18,2)),
    CAST((bu.QUANTITY * ISNULL(Precios.PRICE, 0)) AS DECIMAL(18,2)),
    CAST((bu.QUANTITY * (ISNULL(Precios.PRICE, 0) * COALESCE(d.FACTOR_PRECIO, 1.0))) AS DECIMAL(18,2)),
    CAST(ftf.TOTAL_BRUTO_FACTURA AS DECIMAL(18,2))
FROM cte_facturacion_union AS bu
LEFT JOIN [bd_inter_sales].[dbo].[INT_TIME] AS t 
    ON (YEAR(bu.DATE) * 10000) + (MONTH(bu.DATE) * 100) + DAY(bu.DATE) = t.KEY_TIME
LEFT JOIN [bd_inter_sales].[dbo].[INT_HOLIDAY] AS h 
    ON MONTH(bu.DATE) = MONTH(h.DATE) AND DAY(bu.DATE) = DAY(h.DATE)
LEFT JOIN [bd_inter_sales].[dbo].[INT_CUSTOMERS_TOTAL] AS cus 
    ON bu.CUSTOMER_ID = cus.CUSTOMER_ID
LEFT JOIN [bd_inter_sales].[dbo].[INT_AGE_RANGE] AS ar 
    ON cus.customer_age BETWEEN ar.MinAge AND ar.MaxAge
LEFT JOIN [bd_inter_sales].[dbo].[INT_REGIONS] AS reg 
    ON RIGHT('00000' + CAST(CAST(cus.ZIPCODE AS BIGINT) AS VARCHAR(10)), 5) = 
       RIGHT('00000' + CAST(CAST(reg.ZIPCODE AS BIGINT) AS VARCHAR(10)), 5)
LEFT JOIN cte_precio AS Precios 
    ON bu.PRODUCT_ID = Precios.PRODUCT_ID AND bu.DATE >= Precios.StartDate AND bu.DATE < Precios.EndDate
LEFT JOIN cte_descuentos d 
    ON bu.BILLING_ID = d.BILLING_ID
LEFT JOIN cte_facturacion_total_por_factura ftf 
    ON bu.BILLING_ID = ftf.BILLING_ID
LEFT JOIN [bd_inter_sales].[dbo].[int_PRODUCTS] AS dp 
    ON bu.PRODUCT_ID = dp.PRODUCT_ID
ORDER BY bu.DATE ASC;
GO
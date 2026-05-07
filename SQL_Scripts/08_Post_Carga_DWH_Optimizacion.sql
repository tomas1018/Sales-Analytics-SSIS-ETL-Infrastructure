/* ===============================================================================
ETL INFRASTRUCTURE - FASE 8: POST-CARGA Y OPTIMIZACIÓN ANALÍTICA
===============================================================================
Descripción: 
Este script restaura la integridad referencial y crea la estrategia de indexación
para la explotación de datos. 

Técnicas de optimización:
- Restricciones de integridad (FK) con verificación.
- Índices no agrupados para acelerar los JOINs en el Esquema en Estrella.
- Índice de cobertura (Covering Index) para métricas clave de Reporting, 
  minimizando el I/O del disco en consultas agregadas.
===============================================================================
*/

USE [bd_datawarehouse_sales];
GO

PRINT 'Restaurando integridad referencial (Foreign Keys)...';

-- 1. CREACIÓN DE FOREIGN KEYS
-- Vinculamos la FACT con las dimensiones maestras para garantizar la calidad del dato.

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_CUSTOMERS] 
FOREIGN KEY([CustomerID]) REFERENCES [dbo].[DIM_CUSTOMERS] ([Customer_ID]);

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_PRODUCTS] 
FOREIGN KEY([ProductID]) REFERENCES [dbo].[DIM_PRODUCTS] ([Product_ID]);

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_EMPLOYEES] 
FOREIGN KEY([EmployeeID]) REFERENCES [dbo].[DIM_EMPLOYEES] ([Employee_ID]);

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_TIME] 
FOREIGN KEY([TimeKey]) REFERENCES [dbo].[DIM_TIME] ([KEY_TIME]);

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_REGIONS] 
FOREIGN KEY([RegionID]) REFERENCES [dbo].[DIM_REGIONS] ([REGION_ID]);

ALTER TABLE [dbo].[FACT_SALES] WITH CHECK ADD CONSTRAINT [FK_FACT_SALES_DIM_AGE_RANGE] 
FOREIGN KEY([AgeRangeID]) REFERENCES [dbo].[DIM_AGE_RANGE] ([AgeRangeID]);

GO

PRINT 'Creando índices de optimización para Reporting...';

-- 2. CREACIÓN DE ÍNDICES NO AGRUPADOS
-- Optimizan los tiempos de respuesta en Power BI y herramientas de OLAP.

CREATE NONCLUSTERED INDEX [IX_FACT_SALES_TimeKey] ON [dbo].[FACT_SALES] ([TimeKey]);
CREATE NONCLUSTERED INDEX [IX_FACT_SALES_ProductID] ON [dbo].[FACT_SALES] ([ProductID]);
CREATE NONCLUSTERED INDEX [IX_FACT_SALES_CustomerID] ON [dbo].[FACT_SALES] ([CustomerID]);
CREATE NONCLUSTERED INDEX [IX_FACT_SALES_REGION_ID] ON [dbo].[FACT_SALES] ([RegionID]);
CREATE NONCLUSTERED INDEX [IX_FACT_SALES_EmployeeID] ON [dbo].[FACT_SALES] ([EmployeeID]);

/* Índice de Cobertura para Performance:
   Evita el Key Lookup en la tabla de hechos para las métricas más consultadas. */
CREATE NONCLUSTERED INDEX [IX_FACT_SALES_Reporting_Performance] 
ON [dbo].[FACT_SALES] ([TimeKey]) 
INCLUDE ([GrossLineTotal], [NetLineTotal], [Quantity]);

PRINT 'Optimización finalizada con éxito.';
GO
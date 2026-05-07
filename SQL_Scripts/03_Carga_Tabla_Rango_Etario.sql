/* ETL INFRASTRUCTURE - FASE 1: SEMILLAS (DATA SEEDING)
Descripción: Carga de valores estáticos para dimensiones de control.
*/

USE [bd_inter_sales];
GO

-- Limpieza previa para evitar duplicados en caso de re-ejecución
TRUNCATE TABLE [dbo].[INT_AGE_RANGE];

-- Inserción de Rangos de Edad para segmentación demográfica
INSERT INTO [dbo].[INT_AGE_RANGE] (AGE_RANGE_NAME, MinAge, MaxAge) 
VALUES
('Teenagers', 13, 19),
('Young Adults', 20, 39),
('Middle-aged Adults', 40, 50),
('Older Adults', 51, 65),
('Senior Management Age', 66, 66),
('Seniors', 67, 100);
GO

-- Verificación de carga
SELECT * FROM [dbo].[INT_AGE_RANGE];
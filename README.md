# Pipeline ETL de Ventas: De SQL/MySQL a Data Warehouse 🚀

### Descripción
Desarrollo de un sistema ETL robusto que integra fuentes de datos heterogéneas (SQL Server y MySQL) para consolidar un Data Warehouse de ventas con más de **1.6 millones de registros**. El proyecto destaca por su eficiencia en el procesamiento de grandes volúmenes de datos, su portabilidad y la implementación de reglas de negocio para asegurar la integridad referencial.

### 🛠️ Stack Tecnológico
* **Motor de BD:** SQL Server & MySQL
* **ETL Tool:** SQL Server Integration Services (SSIS)
* **Arquitectura:** Staging Area -> Intermedia -> Data Warehouse (Star Schema)

### 📈 Características Principales
* **Procesamiento Masivo:** Alta eficiencia de carga, procesando **1.67M de registros en aproximadamente 2:30 minutos**.
* **Diseño Parametrizado:** Proyecto 100% portable mediante el uso de variables de paquete para configurar instancias de servidor y rutas de archivos de forma dinámica.
* **Orquestación Automatizada:** El flujo de SSIS integra scripts SQL para el mantenimiento de índices, gestión de FKs y limpieza de tablas, eliminando la intervención manual.
* **Data Cleansing:** Implementación de lógica de filtrado mediante *Conditional Split* para sanear IDs huérfanos y registros con errores de desbordamiento (IDs > 8 dígitos).
* **Modelo Estrella:** Esquema optimizado con tablas de dimensiones (`Employees`, `Customers`, `Products`, `Time`) y tabla de hechos (`Sales`).
* **Gestión de Precios Históricos:** Implementación de lógica SCD (Slowly Changing Dimensions) Tipo 2 para la trazabilidad exacta de precios mediante funciones de ventana.

### 📂 Estructura de Scripts
*El paquete SSIS orquesta la ejecución de estos archivos de forma secuencial:*
1. `00_al_05`: Definición de infraestructura, lógica de transformación y carga de dimensiones.
2. `06_Mantenimiento_Pre_Carga`: Optimización dinámica (Drop de FKs e Índices).
3. `07_Truncate_y_Carga`: Limpieza de tablas y carga de semillas temporales.
4. `08_Post_Carga_Optimizacion`: Restauración de integridad y creación de índices de cobertura para Power BI.

### 🚀 Configuración y Uso
1. **Previo** descomprima la carpeta `Data_Source` dentro de la carpeta raiz.
2. **Apertura:** Abra la solución `Sales-Analytics-SSIS-ETL-Infrastructure.sln` en Visual Studio (SSDT).
3. **Preparación:** Ejecute los scripts SQL del `00` al `05` para crear la estructura de las bases de datos (desde la sql task).
4. **Parametrización:** - Diríjase al panel de **Variables** del paquete `Package.dtsx`.
   - Actualice los valores de `InstanciaServidor`, `CarpetaArchivos` (ruta de las carpetas de datos) y `CarpetaManejoErrores`.
5. **Ejecución:** Inicie el proceso. El sistema automatizado se encargará de la limpieza, el mantenimiento de índices y la carga final de datos.

# Proyecto BI NorthWind - OLTP, Data Warehouse y ETL Incremental

## Descripción del proyecto

Este proyecto implementa una solución de Business Intelligence basada en la base de datos **NorthWind**.  
El objetivo principal es construir un flujo completo desde una base de datos transaccional **OLTP** hacia un **Data Warehouse** orientado al análisis, utilizando SQL Server, SSIS, SQL Server Agent y proyectos DACPAC.

La solución permite extraer cambios desde la base operacional mediante `rowversion`, cargarlos en tablas `staging`, sincronizarlos con dimensiones y hechos del Data Warehouse, y automatizar el proceso mediante un Job de SQL Server Agent.

La solución incluye:

- Base OLTP normalizada: `NorthWindOLTP`
- Data Warehouse: `NorthWindDW`
- Tablas `staging` para carga intermedia
- Procedimientos almacenados para carga incremental mediante `rowversion`
- Paquetes SSIS para ejecutar el proceso ETL
- Despliegue del proyecto SSIS en `SSISDB`
- Job en SQL Server Agent para ejecución automática
- Proyecto DACPAC y archivos `.dacpac`
- Scripts SQL completos
- Prueba incremental documentada

---

## Arquitectura general

```text
NorthWindOLTP
    ↓
Procedimientos Get...ChangesByRowVersion
    ↓
SSIS / SQL Server Agent Job
    ↓
Tablas staging
    ↓
Procedimientos DW_Sync...FromStaging
    ↓
NorthWindDW
```

El flujo general trabaja de la siguiente manera:

1. La base `NorthWindOLTP` contiene los datos operacionales.
2. Los procedimientos `Get...ChangesByRowVersion` extraen solo los registros nuevos o modificados.
3. SSIS carga los datos hacia tablas `staging` en `NorthWindDW`.
4. Los procedimientos `DW_Sync...FromStaging` sincronizan los datos con dimensiones y hechos.
5. La tabla `PackageConfig` controla la última `rowversion` procesada.
6. SQL Server Agent ejecuta automáticamente los paquetes SSIS mediante el Job `NorthWind`.

---

## Bases de datos utilizadas

### NorthWindOLTP

Base de datos operacional/transaccional.  
Contiene las tablas normalizadas del sistema original, como:

- `Customers`
- `Employees`
- `Products`
- `Categories`
- `Suppliers`
- `Shippers`
- `Orders`
- `Order Details`

También contiene procedimientos almacenados para extraer cambios mediante `rowversion`, por ejemplo:

- `GetCustomerChangesByRowVersion`
- `GetEmployeeChangesByRowVersion`
- `GetProductChangesByRowVersion`
- `GetShipperChangesByRowVersion`
- `GetShipLocationChangesByRowVersion`
- `GetSalesChangesByRowVersion`

---

### NorthWindDW

Base de datos analítica orientada a consultas de negocio.  
Está estructurada como un Data Warehouse con dimensiones y tabla de hechos.

Dimensiones principales:

- `DimCustomer`
- `DimEmployee`
- `DimProduct`
- `DimShipper`
- `DimShipLocation`
- `DimDate`

Tabla de hechos:

- `FactSales`

También incluye:

- Esquema `staging`
- Tabla `PackageConfig`
- Procedimientos `DW_Sync...FromStaging`

---

## Modelo OLTP

El modelo OLTP mantiene una estructura normalizada, separando entidades como clientes, empleados, productos, proveedores, transportistas, órdenes y detalles de órdenes.

Se evita duplicar información innecesariamente, manteniendo relaciones mediante claves primarias y claves foráneas.

Ejemplos de entidades principales:

```text
Customers
Employees
Products
Categories
Suppliers
Shippers
Orders
Order Details
```

Imagen sugerida:

```text
Docs/Diagramas/Modelo_OLTP.png
```

---

## Modelo Data Warehouse

El Data Warehouse está diseñado con orientación analítica.  
No replica directamente el OLTP, sino que organiza la información en dimensiones y hechos.

Modelo general:

```text
DimCustomer
DimEmployee
DimProduct
DimShipper
DimShipLocation
DimDate
        ↓
     FactSales
```

La tabla `FactSales` permite analizar ventas mediante dimensiones como cliente, empleado, producto, transportista, ubicación de envío y fecha.

Imagen sugerida:

```text
Docs/Diagramas/Modelo_DW.png
```

---

## ETL con SSIS

El proceso ETL fue construido en Visual Studio mediante SQL Server Integration Services.

Paquetes SSIS incluidos:

- `Customer.dtsx`
- `Employee.dtsx`
- `Product.dtsx`
- `Shipper.dtsx`
- `ShipLocation.dtsx`
- `Orders.dtsx`

Cada paquete maneja una parte del proceso de carga incremental.

Flujo general de los paquetes:

```text
Get DataBase Version
    ↓
Get Last RowVersion
    ↓
Clean staging
    ↓
Load datos incrementales
    ↓
Sync-Staging
    ↓
Update Config
```

### Paquetes principales

| Paquete | Origen OLTP | Staging | Destino DW |
|---|---|---|---|
| `Customer.dtsx` | `Customers` | `staging.Customer` | `DimCustomer` |
| `Employee.dtsx` | `Employees` | `staging.Employee` | `DimEmployee` |
| `Product.dtsx` | `Products`, `Categories`, `Suppliers` | `staging.Product` | `DimProduct` |
| `Shipper.dtsx` | `Shippers` | `staging.Shipper` | `DimShipper` |
| `ShipLocation.dtsx` | `Orders` | `staging.ShipLocation` | `DimShipLocation` |
| `Orders.dtsx` | `Orders`, `Order Details` | `staging.Sales` | `FactSales` |

---

## Despliegue en SSISDB

El proyecto SSIS fue desplegado en el catálogo de Integration Services:

```text
SSISDB
└── ETL
    └── Projects
        └── NorthWindETL
            └── Packages
                ├── Customer.dtsx
                ├── Employee.dtsx
                ├── Product.dtsx
                ├── Shipper.dtsx
                ├── ShipLocation.dtsx
                └── Orders.dtsx
```

El archivo desplegable del proyecto SSIS se encuentra en:

```text
VisualStudio/SSIS_Output/NorthWindETL.ispac
```

---

## SQL Server Agent Job

Se creó un Job llamado:

```text
NorthWind
```

Este Job ejecuta los paquetes SSIS en el siguiente orden:

```text
1. Load Customer
2. Load Employee
3. Load Product
4. Load Shipper
5. Load ShipLocation
6. Load Orders
```

El Job puede ejecutarse manualmente o mediante programación automática cada 1 minuto.

Orden recomendado:

1. Cargar dimensiones.
2. Cargar ubicaciones de envío.
3. Cargar la tabla de hechos al final.

`Orders.dtsx` se ejecuta al final porque `FactSales` depende de las dimensiones ya cargadas.

---

## Prueba incremental

La prueba principal se realiza insertando un nuevo transportista en `NorthWindOLTP.dbo.Shippers`.

Luego el Job `NorthWind` ejecuta el ETL y el dato aparece en:

```text
NorthWindDW.dbo.DimShipper
```

Script de prueba:

```text
Scripts/TESTS/03_Test_Incremental_Shipper.sql
```

Flujo de prueba:

```text
INSERT en NorthWindOLTP.dbo.Shippers
    ↓
Job NorthWind
    ↓
staging.Shipper
    ↓
NorthWindDW.dbo.DimShipper
```

Consulta de ejemplo en OLTP:

```sql
SELECT TOP (1000)
    ShipperID,
    CompanyName,
    Phone,
    [rowversion]
FROM NorthWindOLTP.dbo.Shippers
ORDER BY ShipperID;
```

Consulta de ejemplo en DW:

```sql
SELECT TOP (1000)
    ShipperSK,
    ShipperID,
    CompanyName,
    Phone
FROM NorthWindDW.dbo.DimShipper
ORDER BY ShipperID;
```

---

## Scripts SQL

Los scripts completos se encuentran en:

```text
Scripts/OLTP/01_NorthWindOLTP_SchemaAndData.sql
Scripts/DW/02_NorthWindDW_SchemaAndData.sql
Scripts/TESTS/03_Test_Incremental_Shipper.sql
```

Los scripts incluyen estructura y datos para poder reconstruir las bases principales.

### Scripts incluidos

| Archivo | Descripción |
|---|---|
| `01_NorthWindOLTP_SchemaAndData.sql` | Script completo de la base operacional `NorthWindOLTP` |
| `02_NorthWindDW_SchemaAndData.sql` | Script completo del Data Warehouse `NorthWindDW` |
| `03_Test_Incremental_Shipper.sql` | Script de prueba incremental usando `Shippers` |

---

## Proyecto DACPAC

Se incluyen proyectos DACPAC para versionar y desplegar la estructura de las bases de datos.

Ubicación:

```text
VisualStudio/DACPAC/NorthWindOLTP_DatabaseProject
VisualStudio/DACPAC/NorthWindDW_DatabaseProject
```

Archivos `.dacpac` generados:

```text
VisualStudio/DACPAC/Output/NorthWindOLTP_DatabaseProject.dacpac
VisualStudio/DACPAC/Output/NorthWindDW_DatabaseProject.dacpac
```

El DACPAC se utiliza para empaquetar la estructura de la base de datos, incluyendo tablas, procedimientos, relaciones, vistas y demás objetos compatibles.

---

## Instrucciones de despliegue

### 1. Restaurar o crear bases desde scripts

Ejecutar en SQL Server Management Studio:

```text
Scripts/OLTP/01_NorthWindOLTP_SchemaAndData.sql
Scripts/DW/02_NorthWindDW_SchemaAndData.sql
```

Esto crea o reconstruye las bases:

```text
NorthWindOLTP
NorthWindDW
```

---

### 2. Abrir proyecto SSIS

Abrir en Visual Studio:

```text
VisualStudio/NorthWindETL/NorthWindETL.sln
```

Verificar los administradores de conexión:

```text
localhost.NorthWindOLTP
localhost.NorthWindDW
```

Si el servidor no se llama `localhost`, actualizar las conexiones al nombre correspondiente del servidor SQL.

---

### 3. Crear SSISDB

En SQL Server Management Studio:

```text
Catálogos de Integration Services
→ Crear catálogo
→ SSISDB
```

Crear carpeta:

```text
ETL
```

---

### 4. Desplegar proyecto SSIS

Desde Visual Studio:

```text
Clic derecho en NorthWindETL
→ Implementar
→ SSIS en SQL Server
→ /SSISDB/ETL/NorthWindETL
```

También se puede usar el archivo:

```text
VisualStudio/SSIS_Output/NorthWindETL.ispac
```

---

### 5. Habilitar SQL Server Agent

En caso de que SQL Server Agent esté deshabilitado, ejecutar:

```sql
USE master;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;
GO
```

Luego iniciar el servicio SQL Server Agent desde SSMS.

---

### 6. Crear Job en SQL Server Agent

Crear un Job llamado:

```text
NorthWind
```

Agregar pasos de tipo:

```text
Paquete de SQL Server Integration Services
```

Usar paquetes desde:

```text
Catálogo SSIS
/SSISDB/ETL/NorthWindETL
```

Orden de pasos:

```text
1. Customer.dtsx
2. Employee.dtsx
3. Product.dtsx
4. Shipper.dtsx
5. ShipLocation.dtsx
6. Orders.dtsx
```

En los pasos 1 al 5:

```text
Acción en caso de éxito: Ir al siguiente paso
Acción en caso de error: Salir del trabajo e informar del error
```

En el último paso:

```text
Acción en caso de éxito: Salir del trabajo e informar del éxito
Acción en caso de error: Salir del trabajo e informar del error
```

---

### 7. Crear programación del Job

Crear una programación para el Job `NorthWind`.

Configuración sugerida:

```text
Nombre: Every 1 minute
Tipo de programación: Periódica
Habilitado: Sí
Frecuencia: Diaria
Ocurre cada: 1 minuto
Sin fecha de finalización
```

---

### 8. Ejecutar prueba incremental

Ejecutar:

```text
Scripts/TESTS/03_Test_Incremental_Shipper.sql
```

Después ejecutar el Job manualmente o esperar la programación automática.

---

## Estructura del repositorio

```text
BI_Northwind
│
├── README.md
├── .gitignore
│
├── Docs
│   ├── Diagramas
│   ├── Capturas
│   └── Evidencias
│
├── Scripts
│   ├── OLTP
│   │   └── 01_NorthWindOLTP_SchemaAndData.sql
│   ├── DW
│   │   └── 02_NorthWindDW_SchemaAndData.sql
│   └── TESTS
│       └── 03_Test_Incremental_Shipper.sql
│
├── VisualStudio
│   ├── NorthWindETL
│   ├── SSIS_Output
│   │   └── NorthWindETL.ispac
│   └── DACPAC
│       ├── NorthWindOLTP_DatabaseProject
│       ├── NorthWindDW_DatabaseProject
│       └── Output
│           ├── NorthWindOLTP_DatabaseProject.dacpac
│           └── NorthWindDW_DatabaseProject.dacpac
│
└── Northwind
```

---

## Tecnologías utilizadas

- SQL Server
- SQL Server Management Studio
- Visual Studio
- SQL Server Integration Services
- SQL Server Agent
- DACPAC
- GitHub

---

## Convenciones utilizadas

Se utilizaron nombres descriptivos para facilitar la comprensión del flujo:

- Bases de datos:
  - `NorthWindOLTP`
  - `NorthWindDW`

- Esquema de carga intermedia:
  - `staging`

- Tabla de control:
  - `PackageConfig`

- Procedimientos de extracción:
  - `Get...ChangesByRowVersion`

- Procedimientos de sincronización:
  - `DW_Sync...FromStaging`

- Paquetes SSIS:
  - `Customer.dtsx`
  - `Employee.dtsx`
  - `Product.dtsx`
  - `Shipper.dtsx`
  - `ShipLocation.dtsx`
  - `Orders.dtsx`

---

## Resultado esperado

Al finalizar el despliegue, el proyecto permite:

- Mantener una base OLTP normalizada.
- Cargar información hacia un Data Warehouse analítico.
- Ejecutar ETL incremental mediante `rowversion`.
- Automatizar la carga con SQL Server Agent.
- Evidenciar los cambios desde OLTP hacia DW.
- Versionar scripts, proyectos SSIS y proyectos DACPAC en GitHub.

---

## Evidencias sugeridas

Guardar capturas en:

```text
Docs/Capturas
Docs/Evidencias
```

Capturas recomendadas:

- Proyecto SSIS en Visual Studio.
- Paquetes SSIS ejecutados correctamente.
- Proyecto desplegado en `SSISDB`.
- Job `NorthWind` en SQL Server Agent.
- Historial del Job con pasos exitosos.
- Registro insertado en `NorthWindOLTP`.
- Registro cargado en `NorthWindDW`.

---

## Autores

Proyecto desarrollado como práctica de Business Intelligence, Data Warehouse y ETL incremental sobre SQL Server.

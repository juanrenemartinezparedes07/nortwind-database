[README.md](https://github.com/user-attachments/files/27406451/README.md)
# Northwind Database — OLTP y Data Warehouse

Proyecto desarrollado para el Diplomado de Base de Datos.  
Implementación de un modelo transaccional (OLTP) y un modelo analítico (Data Warehouse) basados en la base de datos Northwind, usando SQL Server.

---

## Dominio del negocio

**Ventas y Distribución** — Sistema que gestiona el ciclo completo de ventas de una empresa distribuidora: clientes, empleados, productos, pedidos y envíos.
Enfocándonos en el ciclo comercial de una empresa distribuidora esto incluye la gestión de clientes el control de inventario con la tabla de productos el procesamiento de pedidos y la logística de envios
---

## Estructura del repositorio

```
nortwind-database/
│
├── 01_OLTP_Create.sql        # Creación de BD y tablas OLTP (esquema ventas)
├── 02_OLTP_SeedData_v2.sql   # Datos de prueba (8 tablas, 200+ registros)
├── 03_DW_Create.sql          # Creación del Data Warehouse (modelo estrella)
├── 04_DW_ETL.sql             # Proceso ETL: carga de OLTP a DW
├── NorthwindOLTP.dacpac      # Paquete DACPAC del proyecto
└── README.md                 # Documentación del proyecto
```

---

## Modelo OLTP — NorthwindOLTP

Base de datos transaccional normalizada hasta **3FN** con esquema `ventas`.

### Tablas

| Tabla | Descripción | Registros |
|---|---|---|
| `ventas.Categoria` | Categorías de productos | 8 |
| `ventas.Proveedor` | Proveedores de productos | 10 |
| `ventas.Producto` | Catálogo de productos | 25 |
| `ventas.Empleado` | Empleados con jerarquía | 9 |
| `ventas.Cliente` | Clientes de la empresa | 40 |
| `ventas.Transportista` | Empresas de envío | 5 |
| `ventas.Pedido` | Pedidos de venta | 25 |
| `ventas.DetallePedido` | Líneas de cada pedido | 50 |

### Reglas de negocio

- Un pedido pertenece a un solo cliente y es gestionado por un solo empleado
- Un pedido puede tener múltiples productos (DetallePedido)
- El precio en DetallePedido es histórico (puede diferir del precio actual)
- El descuento va de 0 a 1 (0% a 100%)
- Un empleado puede reportar a otro empleado (jerarquía recursiva)

---

## Data Warehouse — NorthwindDW

Modelo dimensional **estrella** con esquema `dw`, orientado a análisis de ventas.

### Tabla de hechos

**`dw.FactVentas`** — Granularidad: una fila por línea de detalle de pedido

| Métrica | Descripción |
|---|---|
| `Cantidad` | Unidades vendidas |
| `PrecioUnitario` | Precio al momento de la venta |
| `Descuento` | Porcentaje de descuento aplicado |
| `MontoNeto` | PrecioUnitario × Cantidad × (1 - Descuento) |
| `Flete` | Costo de envío del pedido |

### Dimensiones

El modelo dimensional se complementa con las siguientes dimensiones clave producto que permite analizar las ventas por articulo,tiempo que agrupa los pedidos por fecha, cliente para segmentar la información por comprador y empleado.

| Dimensión | Atributos clave |
|---|---|
| `dw.DimTiempo` | Año, Trimestre, Mes, Semana, Día |
| `dw.DimCliente` | Empresa, Ciudad, País, Región |
| `dw.DimProducto` | Nombre, Categoría, Proveedor, Precio |
| `dw.DimEmpleado` | Nombre completo, Cargo, País |
| `dw.DimTransportista` | Empresa, Teléfono |

---

## Instrucciones de despliegue

### Requisitos

- SQL Server 2017 o superior																					 (Para la base de datos)
- SQL Server Management Studio (SSMS)															(Para ejecutar los scripts de creación de tablas y administrar la base de datos)                                 
- Visual Studio con SSDT (para el proyecto DACPAC)     (Para crear el proyecto de base de datos y generar el archivo DACPAC)

### Pasos

**1. Crear el modelo OLTP**
```sql
-- Ejecutar en SSMS:
01_OLTP_Create.sql       -- Crea la BD NorthwindOLTP y todas las tablas
02_OLTP_SeedData_v2.sql  -- Inserta los datos de prueba
```

**2. Crear el Data Warehouse**
```sql
-- Ejecutar en SSMS (después del paso 1):
03_DW_Create.sql  -- Crea la BD NorthwindDW con modelo estrella
04_DW_ETL.sql     -- Ejecuta el ETL y carga los datos analíticos
```

**3. Desplegar con DACPAC**
```
1. Abrir SSMS
2. Clic derecho en "Bases de datos" → "Implementar aplicación de capa de datos"
3. Seleccionar NorthwindOLTP.dacpac
4. Seguir el asistente
```

---

## Consultas analíticas de ejemplo

```sql
-- Ventas totales por trimestre
SELECT t.Anio, t.NombreTrimestre, SUM(f.MontoNeto) AS VentasNetas
FROM dw.FactVentas f
JOIN dw.DimTiempo t ON f.DateKey = t.DateKey
GROUP BY t.Anio, t.Trimestre, t.NombreTrimestre
ORDER BY t.Anio, t.Trimestre;

-- Top 5 productos más vendidos
SELECT TOP 5 p.ProductName, p.CategoryName, SUM(f.MontoNeto) AS VentasNetas
FROM dw.FactVentas f
JOIN dw.DimProducto p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.CategoryName
ORDER BY VentasNetas DESC;

-- Ventas por país del cliente
SELECT c.Country, SUM(f.MontoNeto) AS VentasNetas
FROM dw.FactVentas f
JOIN dw.DimCliente c ON f.CustomerKey = c.CustomerKey
GROUP BY c.Country
ORDER BY VentasNetas DESC;
```

---

## Tecnologías utilizadas

- **SQL Server 2017+** — Motor de base de datos
- **SSMS** — Administración y ejecución de scripts
- **Visual Studio 2026 + SSDT** — Proyecto DACPAC
- **GitHub** — Control de versiones

---

*Diplomado Base de Datos — 2026*

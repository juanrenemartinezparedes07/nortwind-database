-- ============================================================
--  PROYECTO: Northwind Data Warehouse
--  ARCHIVO : 04_DW_ETL.sql
--  DESC    : Proceso ETL — carga desde NorthwindOLTP a NorthwindDW
--            Ejecutar DESPUÉS de 03_DW_Create.sql
-- ============================================================

USE NorthwindDW;
GO

-- ============================================================
-- ETL 1: DimTiempo
-- Genera una fila por cada fecha que aparece en los pedidos
-- ============================================================
INSERT INTO dw.DimTiempo (
    DateKey, FullDate, Anio, Trimestre, NombreTrimestre,
    Mes, NombreMes, Semana, DiaSemana, NombreDia, EsFinDeSemana
)
SELECT DISTINCT
    CONVERT(INT, FORMAT(p.OrderDate, 'yyyyMMdd'))   AS DateKey,
    p.OrderDate                                      AS FullDate,
    YEAR(p.OrderDate)                                AS Anio,
    DATEPART(QUARTER, p.OrderDate)                   AS Trimestre,
    'Q' + CAST(DATEPART(QUARTER, p.OrderDate) AS NVARCHAR(1)) AS NombreTrimestre,
    MONTH(p.OrderDate)                               AS Mes,
    DATENAME(MONTH, p.OrderDate)                     AS NombreMes,
    DATEPART(WEEK, p.OrderDate)                      AS Semana,
    DATEPART(WEEKDAY, p.OrderDate)                   AS DiaSemana,
    DATENAME(WEEKDAY, p.OrderDate)                   AS NombreDia,
    CASE WHEN DATEPART(WEEKDAY, p.OrderDate) IN (1,7) THEN 1 ELSE 0 END AS EsFinDeSemana
FROM NorthwindOLTP.ventas.Pedido p
WHERE p.OrderDate IS NOT NULL;

PRINT '>> DimTiempo cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- ETL 2: DimCliente
-- ============================================================
INSERT INTO dw.DimCliente (CustomerID, CompanyName, ContactName, City, Country, Region)
SELECT
    c.CustomerID,
    c.CompanyName,
    c.ContactName,
    c.City,
    c.Country,
    c.Region
FROM NorthwindOLTP.ventas.Cliente c;

PRINT '>> DimCliente cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- ETL 3: DimProducto (desnormalizado: une Producto + Categoria + Proveedor)
-- ============================================================
INSERT INTO dw.DimProducto (ProductID, ProductName, CategoryName, SupplierName, SupplierCountry, UnitPrice, Discontinued)
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.CompanyName    AS SupplierName,
    s.Country        AS SupplierCountry,
    p.UnitPrice,
    p.Discontinued
FROM NorthwindOLTP.ventas.Producto p
LEFT JOIN NorthwindOLTP.ventas.Categoria c ON p.CategoryID = c.CategoryID
LEFT JOIN NorthwindOLTP.ventas.Proveedor s ON p.SupplierID = s.SupplierID;

PRINT '>> DimProducto cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- ETL 4: DimEmpleado
-- ============================================================
INSERT INTO dw.DimEmpleado (EmployeeID, FullName, Title, City, Country)
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    e.Title,
    e.City,
    e.Country
FROM NorthwindOLTP.ventas.Empleado e;

PRINT '>> DimEmpleado cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- ETL 5: DimTransportista
-- ============================================================
INSERT INTO dw.DimTransportista (ShipperID, CompanyName, Phone)
SELECT
    t.ShipperID,
    t.CompanyName,
    t.Phone
FROM NorthwindOLTP.ventas.Transportista t;

PRINT '>> DimTransportista cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- ETL 6: FactVentas (tabla de hechos)
-- Une DetallePedido con todas las dimensiones
-- ============================================================
INSERT INTO dw.FactVentas (
    OrderID, DateKey, CustomerKey, ProductKey,
    EmployeeKey, ShipperKey,
    Cantidad, PrecioUnitario, Descuento, MontoNeto, Flete
)
SELECT
    p.OrderID,
    CONVERT(INT, FORMAT(p.OrderDate, 'yyyyMMdd'))   AS DateKey,
    dc.CustomerKey,
    dp.ProductKey,
    de.EmployeeKey,
    dt2.ShipperKey,
    dp2.Quantity                                     AS Cantidad,
    dp2.UnitPrice                                    AS PrecioUnitario,
    dp2.Discount                                     AS Descuento,
    CAST(dp2.UnitPrice * dp2.Quantity * (1 - dp2.Discount) AS MONEY) AS MontoNeto,
    p.Freight                                        AS Flete
FROM NorthwindOLTP.ventas.Pedido         p
JOIN NorthwindOLTP.ventas.DetallePedido  dp2 ON p.OrderID      = dp2.OrderID
JOIN dw.DimCliente                       dc  ON p.CustomerID   = dc.CustomerID
JOIN dw.DimProducto                      dp  ON dp2.ProductID  = dp.ProductID
JOIN dw.DimEmpleado                      de  ON p.EmployeeID   = de.EmployeeID
JOIN dw.DimTransportista                 dt2 ON p.ShipVia      = dt2.ShipperID
JOIN dw.DimTiempo                        ti  ON CONVERT(INT, FORMAT(p.OrderDate,'yyyyMMdd')) = ti.DateKey;

PRINT '>> FactVentas cargada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' filas';
GO

-- ============================================================
-- VALIDACIÓN DEL DW
-- ============================================================
PRINT '=== VALIDACION DW ===';
SELECT 'DimTiempo'       AS Tabla, COUNT(*) AS Filas FROM dw.DimTiempo
UNION ALL SELECT 'DimCliente',      COUNT(*) FROM dw.DimCliente
UNION ALL SELECT 'DimProducto',     COUNT(*) FROM dw.DimProducto
UNION ALL SELECT 'DimEmpleado',     COUNT(*) FROM dw.DimEmpleado
UNION ALL SELECT 'DimTransportista',COUNT(*) FROM dw.DimTransportista
UNION ALL SELECT 'FactVentas',      COUNT(*) FROM dw.FactVentas;
GO

-- ============================================================
-- CONSULTAS ANALÍTICAS DE EJEMPLO (métricas del negocio)
-- ============================================================

-- Métrica 1: Ventas totales por año y trimestre
PRINT '--- Ventas por trimestre ---';
SELECT
    t.Anio,
    t.NombreTrimestre,
    COUNT(DISTINCT f.OrderID)       AS TotalPedidos,
    SUM(f.Cantidad)                 AS UnidadesVendidas,
    SUM(f.MontoNeto)                AS VentasNetas,
    AVG(f.Descuento) * 100          AS DescuentoPromedio_Pct
FROM dw.FactVentas f
JOIN dw.DimTiempo  t ON f.DateKey = t.DateKey
GROUP BY t.Anio, t.Trimestre, t.NombreTrimestre
ORDER BY t.Anio, t.Trimestre;
GO

-- Métrica 2: Top 5 productos más vendidos (por monto)
PRINT '--- Top 5 productos por ventas ---';
SELECT TOP 5
    p.ProductName,
    p.CategoryName,
    SUM(f.Cantidad)    AS UnidadesVendidas,
    SUM(f.MontoNeto)   AS VentasNetas
FROM dw.FactVentas  f
JOIN dw.DimProducto p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.CategoryName
ORDER BY VentasNetas DESC;
GO

-- Métrica 3: Ventas por país del cliente
PRINT '--- Ventas por país ---';
SELECT
    c.Country,
    COUNT(DISTINCT f.OrderID) AS TotalPedidos,
    SUM(f.MontoNeto)          AS VentasNetas
FROM dw.FactVentas f
JOIN dw.DimCliente c ON f.CustomerKey = c.CustomerKey
GROUP BY c.Country
ORDER BY VentasNetas DESC;
GO

-- Métrica 4: Performance de empleados
PRINT '--- Ventas por empleado ---';
SELECT
    e.FullName,
    e.Title,
    COUNT(DISTINCT f.OrderID) AS PedidosGestionados,
    SUM(f.MontoNeto)          AS VentasTotales
FROM dw.FactVentas  f
JOIN dw.DimEmpleado e ON f.EmployeeKey = e.EmployeeKey
GROUP BY e.FullName, e.Title
ORDER BY VentasTotales DESC;
GO

PRINT '>> ETL completado. NorthwindDW listo para análisis.';
GO

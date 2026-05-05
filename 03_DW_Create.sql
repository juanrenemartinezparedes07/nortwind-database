-- ============================================================
--  PROYECTO: Northwind Data Warehouse
--  ARCHIVO : 03_DW_Create.sql
--  DESC    : Creación del DW con modelo estrella
--            Ejecutar DESPUÉS de 01 y 02 (OLTP debe existir)
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NorthwindDW')
BEGIN
    ALTER DATABASE NorthwindDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NorthwindDW;
END
GO

CREATE DATABASE NorthwindDW
    COLLATE Modern_Spanish_CI_AS;
GO

USE NorthwindDW;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

-- ============================================================
-- DIMENSIONES
-- ============================================================

-- ------------------------------------------------------------
-- DimTiempo — descompone la fecha en atributos analíticos
-- ------------------------------------------------------------
CREATE TABLE dw.DimTiempo (
    DateKey       INT          NOT NULL,   -- YYYYMMDD como clave surrogate
    FullDate      DATE         NOT NULL,
    Anio          SMALLINT     NOT NULL,
    Trimestre     TINYINT      NOT NULL,   -- 1-4
    NombreTrimestre NVARCHAR(6) NOT NULL,  -- Q1..Q4
    Mes           TINYINT      NOT NULL,   -- 1-12
    NombreMes     NVARCHAR(20) NOT NULL,
    Semana        TINYINT      NOT NULL,   -- 1-53
    DiaSemana     TINYINT      NOT NULL,   -- 1=Lun .. 7=Dom
    NombreDia     NVARCHAR(12) NOT NULL,
    EsFinDeSemana BIT          NOT NULL,
    CONSTRAINT PK_DimTiempo PRIMARY KEY (DateKey)
);
GO

-- ------------------------------------------------------------
-- DimCliente
-- ------------------------------------------------------------
CREATE TABLE dw.DimCliente (
    CustomerKey   INT           NOT NULL IDENTITY(1,1),
    CustomerID    NCHAR(5)      NOT NULL,
    CompanyName   NVARCHAR(100) NOT NULL,
    ContactName   NVARCHAR(100) NULL,
    City          NVARCHAR(50)  NULL,
    Country       NVARCHAR(50)  NULL,
    Region        NVARCHAR(50)  NULL,
    CONSTRAINT PK_DimCliente PRIMARY KEY (CustomerKey)
);
GO

-- ------------------------------------------------------------
-- DimProducto  (desnormalizado: incluye categoría y proveedor)
-- ------------------------------------------------------------
CREATE TABLE dw.DimProducto (
    ProductKey      INT           NOT NULL IDENTITY(1,1),
    ProductID       INT           NOT NULL,
    ProductName     NVARCHAR(100) NOT NULL,
    CategoryName    NVARCHAR(50)  NULL,
    SupplierName    NVARCHAR(100) NULL,
    SupplierCountry NVARCHAR(50)  NULL,
    UnitPrice       MONEY         NOT NULL,
    Discontinued    BIT           NOT NULL,
    CONSTRAINT PK_DimProducto PRIMARY KEY (ProductKey)
);
GO

-- ------------------------------------------------------------
-- DimEmpleado
-- ------------------------------------------------------------
CREATE TABLE dw.DimEmpleado (
    EmployeeKey  INT           NOT NULL IDENTITY(1,1),
    EmployeeID   INT           NOT NULL,
    FullName     NVARCHAR(100) NOT NULL,
    Title        NVARCHAR(50)  NULL,
    City         NVARCHAR(50)  NULL,
    Country      NVARCHAR(50)  NULL,
    CONSTRAINT PK_DimEmpleado PRIMARY KEY (EmployeeKey)
);
GO

-- ------------------------------------------------------------
-- DimTransportista
-- ------------------------------------------------------------
CREATE TABLE dw.DimTransportista (
    ShipperKey  INT          NOT NULL IDENTITY(1,1),
    ShipperID   INT          NOT NULL,
    CompanyName NVARCHAR(50) NOT NULL,
    Phone       NVARCHAR(30) NULL,
    CONSTRAINT PK_DimTransportista PRIMARY KEY (ShipperKey)
);
GO

-- ============================================================
-- TABLA DE HECHOS — FactVentas
-- Granularidad: una fila por línea de detalle de pedido
-- ============================================================
CREATE TABLE dw.FactVentas (
    OrderKey       INT     NOT NULL IDENTITY(1,1),
    OrderID        INT     NOT NULL,   -- clave de negocio (degenerate dimension)
    DateKey        INT     NOT NULL,
    CustomerKey    INT     NOT NULL,
    ProductKey     INT     NOT NULL,
    EmployeeKey    INT     NOT NULL,
    ShipperKey     INT     NOT NULL,

    -- MÉTRICAS
    Cantidad       SMALLINT NOT NULL,
    PrecioUnitario MONEY    NOT NULL,
    Descuento      REAL     NOT NULL,
    MontoNeto      MONEY    NOT NULL,  -- calculado: PrecioUnitario * Cantidad * (1 - Descuento)
    Flete          MONEY    NOT NULL,

    CONSTRAINT PK_FactVentas    PRIMARY KEY (OrderKey),
    CONSTRAINT FK_Fact_Tiempo   FOREIGN KEY (DateKey)     REFERENCES dw.DimTiempo (DateKey),
    CONSTRAINT FK_Fact_Cliente  FOREIGN KEY (CustomerKey) REFERENCES dw.DimCliente (CustomerKey),
    CONSTRAINT FK_Fact_Producto FOREIGN KEY (ProductKey)  REFERENCES dw.DimProducto (ProductKey),
    CONSTRAINT FK_Fact_Empleado FOREIGN KEY (EmployeeKey) REFERENCES dw.DimEmpleado (EmployeeKey),
    CONSTRAINT FK_Fact_Shipper  FOREIGN KEY (ShipperKey)  REFERENCES dw.DimTransportista (ShipperKey)
);
GO

-- Índices para consultas analíticas frecuentes
CREATE INDEX IX_Fact_Date     ON dw.FactVentas (DateKey);
CREATE INDEX IX_Fact_Customer ON dw.FactVentas (CustomerKey);
CREATE INDEX IX_Fact_Product  ON dw.FactVentas (ProductKey);
CREATE INDEX IX_Fact_Employee ON dw.FactVentas (EmployeeKey);
GO

PRINT '>> NorthwindDW creado correctamente.';
PRINT '>> Tablas: DimTiempo, DimCliente, DimProducto, DimEmpleado, DimTransportista, FactVentas';
GO

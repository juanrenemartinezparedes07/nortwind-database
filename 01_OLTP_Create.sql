-- ============================================================
--  PROYECTO: Northwind OLTP
--  ARCHIVO : 01_OLTP_Create.sql
--  AUTOR   : Diplomado Base de Datos
--  FECHA   : 2025
--  DESC    : Creación de base de datos OLTP normalizada (3FN)
--            Dominio: Ventas y Distribución
-- ============================================================

-- ============================================================
-- PASO 1: Crear la base de datos
-- ============================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NorthwindOLTP')
BEGIN
    ALTER DATABASE NorthwindOLTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NorthwindOLTP;
END
GO

CREATE DATABASE NorthwindOLTP
    COLLATE Modern_Spanish_CI_AS;
GO

USE NorthwindOLTP;
GO

-- ============================================================
-- PASO 2: Crear esquema de trabajo
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ventas')
    EXEC('CREATE SCHEMA ventas');
GO

-- ============================================================
-- PASO 3: Crear tablas (orden respeta integridad referencial)
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 CATEGORIA
-- ------------------------------------------------------------
CREATE TABLE ventas.Categoria (
    CategoryID   INT           NOT NULL IDENTITY(1,1),
    CategoryName NVARCHAR(50)  NOT NULL,
    Description  NVARCHAR(500) NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categoria_Name UNIQUE (CategoryName)
);
GO

-- ------------------------------------------------------------
-- 3.2 PROVEEDOR
-- ------------------------------------------------------------
CREATE TABLE ventas.Proveedor (
    SupplierID   INT           NOT NULL IDENTITY(1,1),
    CompanyName  NVARCHAR(100) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50)  NULL,
    Address      NVARCHAR(200) NULL,
    City         NVARCHAR(50)  NULL,
    Country      NVARCHAR(50)  NULL,
    Phone        NVARCHAR(30)  NULL,
    Fax          NVARCHAR(30)  NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (SupplierID)
);
GO

-- ------------------------------------------------------------
-- 3.3 PRODUCTO
-- ------------------------------------------------------------
CREATE TABLE ventas.Producto (
    ProductID       INT            NOT NULL IDENTITY(1,1),
    ProductName     NVARCHAR(100)  NOT NULL,
    SupplierID      INT            NULL,
    CategoryID      INT            NULL,
    QuantityPerUnit NVARCHAR(50)   NULL,
    UnitPrice       MONEY          NOT NULL CONSTRAINT DF_Producto_UnitPrice DEFAULT (0),
    UnitsInStock    SMALLINT       NOT NULL CONSTRAINT DF_Producto_Stock DEFAULT (0),
    UnitsOnOrder    SMALLINT       NOT NULL CONSTRAINT DF_Producto_OnOrder DEFAULT (0),
    ReorderLevel    SMALLINT       NOT NULL CONSTRAINT DF_Producto_ReorderLevel DEFAULT (0),
    Discontinued    BIT            NOT NULL CONSTRAINT DF_Producto_Discontinued DEFAULT (0),
    CONSTRAINT PK_Producto      PRIMARY KEY (ProductID),
    CONSTRAINT FK_Producto_Proveedor  FOREIGN KEY (SupplierID) REFERENCES ventas.Proveedor (SupplierID),
    CONSTRAINT FK_Producto_Categoria  FOREIGN KEY (CategoryID) REFERENCES ventas.Categoria (CategoryID),
    CONSTRAINT CK_Producto_UnitPrice  CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Producto_Stock      CHECK (UnitsInStock >= 0),
    CONSTRAINT CK_Producto_OnOrder    CHECK (UnitsOnOrder >= 0)
);
GO

-- ------------------------------------------------------------
-- 3.4 EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE ventas.Empleado (
    EmployeeID  INT           NOT NULL IDENTITY(1,1),
    LastName    NVARCHAR(50)  NOT NULL,
    FirstName   NVARCHAR(50)  NOT NULL,
    Title       NVARCHAR(50)  NULL,
    BirthDate   DATE          NULL,
    HireDate    DATE          NULL,
    Address     NVARCHAR(200) NULL,
    City        NVARCHAR(50)  NULL,
    Country     NVARCHAR(50)  NULL,
    ReportsTo   INT           NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (EmployeeID),
    CONSTRAINT FK_Empleado_Jefe FOREIGN KEY (ReportsTo) REFERENCES ventas.Empleado (EmployeeID)
);
GO

-- ------------------------------------------------------------
-- 3.5 CLIENTE
-- ------------------------------------------------------------
CREATE TABLE ventas.Cliente (
    CustomerID   NCHAR(5)      NOT NULL,
    CompanyName  NVARCHAR(100) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(50)  NULL,
    Address      NVARCHAR(200) NULL,
    City         NVARCHAR(50)  NULL,
    Region       NVARCHAR(50)  NULL,
    PostalCode   NVARCHAR(20)  NULL,
    Country      NVARCHAR(50)  NULL,
    Phone        NVARCHAR(30)  NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (CustomerID)
);
GO

-- ------------------------------------------------------------
-- 3.6 TRANSPORTISTA
-- ------------------------------------------------------------
CREATE TABLE ventas.Transportista (
    ShipperID   INT          NOT NULL IDENTITY(1,1),
    CompanyName NVARCHAR(50) NOT NULL,
    Phone       NVARCHAR(30) NULL,
    CONSTRAINT PK_Transportista PRIMARY KEY (ShipperID)
);
GO

-- ------------------------------------------------------------
-- 3.7 PEDIDO
-- ------------------------------------------------------------
CREATE TABLE ventas.Pedido (
    OrderID        INT           NOT NULL IDENTITY(1,1),
    CustomerID     NCHAR(5)      NOT NULL,
    EmployeeID     INT           NOT NULL,
    OrderDate      DATE          NOT NULL CONSTRAINT DF_Pedido_OrderDate DEFAULT (GETDATE()),
    RequiredDate   DATE          NULL,
    ShippedDate    DATE          NULL,
    ShipVia        INT           NULL,
    Freight        MONEY         NOT NULL CONSTRAINT DF_Pedido_Freight DEFAULT (0),
    ShipName       NVARCHAR(100) NULL,
    ShipAddress    NVARCHAR(200) NULL,
    ShipCity       NVARCHAR(50)  NULL,
    ShipCountry    NVARCHAR(50)  NULL,
    CONSTRAINT PK_Pedido           PRIMARY KEY (OrderID),
    CONSTRAINT FK_Pedido_Cliente   FOREIGN KEY (CustomerID)  REFERENCES ventas.Cliente (CustomerID),
    CONSTRAINT FK_Pedido_Empleado  FOREIGN KEY (EmployeeID)  REFERENCES ventas.Empleado (EmployeeID),
    CONSTRAINT FK_Pedido_Shipper   FOREIGN KEY (ShipVia)     REFERENCES ventas.Transportista (ShipperID),
    CONSTRAINT CK_Pedido_Freight   CHECK (Freight >= 0),
    CONSTRAINT CK_Pedido_Fechas    CHECK (ShippedDate IS NULL OR ShippedDate >= OrderDate)
);
GO

-- ------------------------------------------------------------
-- 3.8 DETALLE_PEDIDO
-- ------------------------------------------------------------
CREATE TABLE ventas.DetallePedido (
    OrderID     INT      NOT NULL,
    ProductID   INT      NOT NULL,
    UnitPrice   MONEY    NOT NULL,
    Quantity    SMALLINT NOT NULL CONSTRAINT DF_Detalle_Qty DEFAULT (1),
    Discount    REAL     NOT NULL CONSTRAINT DF_Detalle_Disc DEFAULT (0),
    CONSTRAINT PK_DetallePedido   PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT FK_Detalle_Pedido  FOREIGN KEY (OrderID)   REFERENCES ventas.Pedido (OrderID),
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (ProductID) REFERENCES ventas.Producto (ProductID),
    CONSTRAINT CK_Detalle_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_Detalle_Quantity  CHECK (Quantity > 0),
    CONSTRAINT CK_Detalle_Discount  CHECK (Discount BETWEEN 0 AND 1)
);
GO

-- ============================================================
-- PASO 4: Índices adicionales (rendimiento en consultas clave)
-- ============================================================
CREATE INDEX IX_Producto_Categoria ON ventas.Producto (CategoryID);
CREATE INDEX IX_Producto_Proveedor ON ventas.Producto (SupplierID);
CREATE INDEX IX_Pedido_Cliente     ON ventas.Pedido    (CustomerID);
CREATE INDEX IX_Pedido_Empleado    ON ventas.Pedido    (EmployeeID);
CREATE INDEX IX_Pedido_Fecha       ON ventas.Pedido    (OrderDate);
CREATE INDEX IX_Detalle_Producto   ON ventas.DetallePedido (ProductID);
GO

PRINT '>> Base de datos NorthwindOLTP creada correctamente.';
PRINT '>> Tablas: Categoria, Proveedor, Producto, Empleado, Cliente, Transportista, Pedido, DetallePedido';
GO

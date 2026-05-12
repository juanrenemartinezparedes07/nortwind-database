# Northwind Database — OLTP & Data Warehouse

Project developed for the Database Diploma.
Implementation of a transactional model (OLTP) and an analytical model (Data Warehouse) based on the Northwind database provided in class, using SQL Server.

---

## Business Domain

**Sales & Distribution** — System that manages the complete sales cycle of a distribution company: customers, employees, products, orders and shipments.

---

## Repository Structure

```
nortwind-database/
│
├── 01_OLTP_Create.sql          # OLTP database creation (English, RowVersion)
├── 02_OLTP_SeedData.sql        # Data loaded from original Northwind
├── 03_DW_Create.sql            # Data Warehouse creation (star schema)
├── 04_DW_ETL.sql               # Initial ETL load
├── 05_DW_ETL_Incremental.sql   # Incremental ETL with RowVersion (Stored Procedure)
├── NorthwindOLTP.dacpac        # DACPAC package
└── README.md                   # Project documentation
```

---

## OLTP Model — NorthwindOLTP

Transactional database normalized to **3NF** based on original Northwind.
All tables include **RowVersion** for incremental ETL detection.

### Tables

| Table | Description | Records |
|---|---|---|
| `dbo.Categories` | Product categories | 8 |
| `dbo.Suppliers` | Product suppliers | 29 |
| `dbo.Products` | Product catalog | 77 |
| `dbo.Employees` | Employees with hierarchy | 9 |
| `dbo.Customers` | Company customers | 91 |
| `dbo.Shippers` | Shipping companies | 3 |
| `dbo.Orders` | Sales orders | 830+ |
| `dbo.OrderDetails` | Order line items | 2155+ |
| `dbo.ETL_Control` | RowVersion tracking for ETL | - |

### Business Rules

- One order belongs to one customer and is managed by one employee
- One order can have multiple products (OrderDetails)
- UnitPrice in OrderDetails is historical (may differ from current price)
- Discount ranges from 0 to 1 (0% to 100%)
- An employee can report to another employee (recursive hierarchy)
- **RowVersion** in every table allows automatic change detection for ETL

### Normalization — 3NF Applied

- **1NF** → Atomic data, no repeating groups
- **2NF** → All attributes depend on the complete primary key
- **3NF** → No transitive dependencies (Categories separate from Products, Suppliers separate from Products)

---

## Data Warehouse — NorthwindDW

Dimensional **star schema** model oriented to sales analysis.

### Star Schema

```
                    DimDate
                       ↑
        DimEmployee ←  FactOrders  → DimCustomer
                       ↓
                    DimProduct
                       ↓
                    DimShipper
```

### Fact Table

**`dbo.FactOrders`** — Granularity: one row per order line item

| Metric | Description |
|---|---|
| `Quantity` | Units sold |
| `UnitPrice` | Price at time of sale |
| `Discount` | Discount percentage applied |
| `ExtendedPrice` | UnitPrice × Quantity × (1 - Discount) |
| `Freight` | Shipping cost |

### Dimensions

| Dimension | Key Attributes |
|---|---|
| `dbo.DimDate` | Year, Quarter, Month, Week, Day |
| `dbo.DimCustomer` | Company, City, Country, Region |
| `dbo.DimProduct` | Name, Category, Supplier, Price (denormalized) |
| `dbo.DimEmployee` | Full Name, Title, Country, HireDate |
| `dbo.DimShipper` | Company, Phone |

---

## ETL Process — Incremental with RowVersion

### How it works

```
NorthwindOLTP  →  ETL (RowVersion)  →  NorthwindDW
  (source)          (process)           (destination)
```

| Step | ETL Action |
|---|---|
| **Extract** | Reads new records from NorthwindOLTP using RowVersion |
| **Transform** | Calculates ExtendedPrice, denormalizes DimProduct, generates DateKey |
| **Load** | Inserts only NEW records into NorthwindDW dimensions and FactOrders |

### RowVersion Logic

Every table in the OLTP has a `rowversion` column that automatically updates when a record changes. The ETL:

1. Reads `LastRowVersion` from `ETL_Control` table
2. Only processes records where `rowversion > LastRowVersion`
3. Updates `LastRowVersion` after each load
4. **Result: No duplicates, only new data loaded**

### Running the incremental ETL

```sql
USE NorthwindDW;
EXEC dbo.usp_ETL_LoadIncrementalDW;
```

---

## Deployment Instructions

### Requirements

- SQL Server 2017 or higher
- SQL Server Management Studio (SSMS)
- Visual Studio 2022+ with SSDT (for DACPAC project)
- Original Northwind database restored

### Steps

**1. Restore original Northwind**
```
Open SSMS → Right click Databases → Restore Database
Select Northwind.bak → OK
```

**2. Create OLTP**
```sql
-- Run in SSMS:
01_OLTP_Create.sql    -- Creates NorthwindOLTP with RowVersion
02_OLTP_SeedData.sql  -- Loads data from original Northwind
```

**3. Create Data Warehouse**
```sql
-- Run in SSMS (after step 2):
03_DW_Create.sql          -- Creates NorthwindDW star schema
04_DW_ETL.sql             -- Initial data load
05_DW_ETL_Incremental.sql -- Creates incremental ETL stored procedure
```

**4. Deploy with DACPAC**
```
1. Open SSMS
2. Right click Databases → Deploy Data-tier Application
3. Select NorthwindOLTP.dacpac
4. Follow the wizard
```

---

## Analytical Queries

```sql
-- Sales by Year and Quarter
SELECT d.Year, d.QuarterName,
       COUNT(DISTINCT f.OrderID) AS TotalOrders,
       SUM(f.ExtendedPrice)      AS TotalSales
FROM dbo.FactOrders f
JOIN dbo.DimDate    d ON f.OrderDateKey = d.DateKey
GROUP BY d.Year, d.Quarter, d.QuarterName
ORDER BY d.Year, d.Quarter;

-- Top 5 Products
SELECT TOP 5 p.ProductName, p.CategoryName,
             SUM(f.ExtendedPrice) AS TotalSales
FROM dbo.FactOrders f
JOIN dbo.DimProduct p ON f.ProductSK = p.ProductSK
GROUP BY p.ProductName, p.CategoryName
ORDER BY TotalSales DESC;

-- Sales by Country
SELECT c.Country, SUM(f.ExtendedPrice) AS TotalSales
FROM dbo.FactOrders  f
JOIN dbo.DimCustomer c ON f.CustomerSK = c.CustomerSK
GROUP BY c.Country
ORDER BY TotalSales DESC;

-- Employee Performance
SELECT e.FullName, e.Title,
       COUNT(DISTINCT f.OrderID) AS OrdersHandled,
       SUM(f.ExtendedPrice)      AS TotalSales
FROM dbo.FactOrders  f
JOIN dbo.DimEmployee e ON f.EmployeeSK = e.EmployeeSK
GROUP BY e.FullName, e.Title
ORDER BY TotalSales DESC;
```

---

## Technologies Used

- **SQL Server 2017+** — Database engine
- **SSMS** — Administration and script execution
- **Visual Studio 2026 + SSDT** — DACPAC project
- **GitHub** — Version control

---

## GitHub Repository

```
https://github.com/juanrenemartinezparedes07/nortwind-database
```

---

*Database Diploma — 2026*

-- ============================================================
--  PROYECTO: Northwind OLTP
--  ARCHIVO : 02_OLTP_SeedData_v2.sql
--  DESC    : Datos de prueba - VERSION CORREGIDA
--            Ejecutar DESPUÉS de 01_OLTP_Create.sql
-- ============================================================

USE NorthwindOLTP;
GO

-- Limpiar datos anteriores (si el script se ejecutó antes parcialmente)
DELETE FROM ventas.DetallePedido;
DELETE FROM ventas.Pedido;
DELETE FROM ventas.Cliente;
DELETE FROM ventas.Empleado;
DELETE FROM ventas.Producto;
DELETE FROM ventas.Proveedor;
DELETE FROM ventas.Categoria;
DELETE FROM ventas.Transportista;
GO

-- ============================================================
-- 1. CATEGORIAS (8 registros)
-- ============================================================
SET IDENTITY_INSERT ventas.Categoria ON;
INSERT INTO ventas.Categoria (CategoryID, CategoryName, Description) VALUES
(1, 'Beverages',       'Soft drinks, coffees, teas, beers, and ales'),
(2, 'Condiments',      'Sweet and savory sauces, relishes, spreads, and seasonings'),
(3, 'Confections',     'Desserts, candies, and sweet breads'),
(4, 'Dairy Products',  'Cheeses'),
(5, 'Grains/Cereals',  'Breads, crackers, pasta, and cereal'),
(6, 'Meat/Poultry',    'Prepared meats'),
(7, 'Produce',         'Dried fruit and bean curd'),
(8, 'Seafood',         'Seaweed and fish');
SET IDENTITY_INSERT ventas.Categoria OFF;
GO

-- ============================================================
-- 2. PROVEEDORES (10 registros)
-- ============================================================
SET IDENTITY_INSERT ventas.Proveedor ON;
INSERT INTO ventas.Proveedor (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Country, Phone, Fax) VALUES
(1,  'Exotic Liquids',              'Charlotte Cooper',  'Purchasing Manager',    '49 Gilbert St.',             'London',     'UK',        '(171) 555-2222', NULL),
(2,  'New Orleans Cajun Delights',  'Shelley Burke',     'Order Administrator',   'P.O. Box 78934',             'New Orleans','USA',       '(100) 555-4822', NULL),
(3,  'Grandma Kelly''s Homestead',  'Regina Murphy',     'Sales Representative',  '707 Oxford Rd.',             'Ann Arbor',  'USA',       '(313) 555-5735', '(313) 555-3349'),
(4,  'Tokyo Traders',               'Yoshi Nagase',      'Marketing Manager',     '9-8 Sekimai Musashino-shi',  'Tokyo',      'Japan',     '(03) 3555-5011', NULL),
(5,  'Cooperativa de Quesos',       'Antonio del Valle', 'Export Administrator',  'Calle del Rosal 4',          'Oviedo',     'Spain',     '(98) 598 76 54', NULL),
(6,  'Mayumi''s',                   'Mayumi Ohno',       'Marketing Representative','92 Setsuko Chuo-ku',       'Osaka',      'Japan',     '(06) 431-7877',  NULL),
(7,  'Pavlova, Ltd.',               'Ian Devling',       'Marketing Manager',     '74 Rose St. Moonie Ponds',   'Melbourne',  'Australia', '(03) 444-2343',  '(03) 444-6588'),
(8,  'Specialty Biscuits, Ltd.',    'Peter Wilson',      'Sales Representative',  '29 King''s Way',             'Manchester', 'UK',        '(161) 555-4448', NULL),
(9,  'PB Knäckebröd AB',            'Lars Peterson',     'Sales Agent',           'Kaloadagatan 13',            'Göteborg',   'Sweden',    '031-987 65 43',  '031-987 65 91'),
(10, 'Refrescos Americanas LTDA',   'Carlos Diaz',       'Marketing Manager',     'Av. das Americanas 12.890',  'Sao Paulo',  'Brazil',    '(11) 555 4640',  NULL);
SET IDENTITY_INSERT ventas.Proveedor OFF;
GO

-- ============================================================
-- 3. PRODUCTOS (25 registros)
-- ============================================================
SET IDENTITY_INSERT ventas.Producto ON;
INSERT INTO ventas.Producto (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued) VALUES
(1,  'Chai',                           1,  1, '10 boxes x 20 bags',   18.00,  39,  0,  10, 0),
(2,  'Chang',                          1,  1, '24 - 12 oz bottles',   19.00,  17,  40, 25, 0),
(3,  'Aniseed Syrup',                  1,  2, '12 - 550 ml bottles',  10.00,  13,  70, 25, 0),
(4,  'Chef Anton Cajun Seasoning',     2,  2, '48 - 6 oz jars',       22.00,  53,  0,  0,  0),
(5,  'Chef Anton Gumbo Mix',           2,  2, '36 boxes',             21.35,  0,   0,  0,  1),
(6,  'Grandma Boysenberry Spread',     3,  2, '12 - 8 oz jars',       25.00,  120, 0,  25, 0),
(7,  'Uncle Bob Organic Dried Pears',  3,  7, '12 - 1 lb pkgs.',      30.00,  15,  0,  10, 0),
(8,  'Northwoods Cranberry Sauce',     3,  2, '12 - 12 oz jars',      40.00,  6,   0,  0,  0),
(9,  'Mishi Kobe Niku',                4,  6, '18 - 500 g pkgs.',     97.00,  29,  0,  0,  1),
(10, 'Ikura',                          4,  8, '12 - 200 ml jars',     31.00,  31,  0,  0,  0),
(11, 'Queso Cabrales',                 5,  4, '1 kg pkg.',            21.00,  22,  30, 30, 0),
(12, 'Queso Manchego La Pastora',      5,  4, '10 - 500 g pkgs.',     38.00,  86,  0,  0,  0),
(13, 'Konbu',                          6,  8, '2 kg box',              6.00,  24,  0,  5,  0),
(14, 'Tofu',                           6,  7, '40 - 100 g pkgs.',     23.25,  35,  0,  0,  0),
(15, 'Genen Shouyu',                   6,  2, '24 - 250 ml bottles',  15.50,  39,  0,  5,  0),
(16, 'Pavlova',                        7,  3, '32 - 500 g boxes',     17.45,  29,  0,  10, 0),
(17, 'Alice Mutton',                   7,  6, '20 - 1 kg tins',       39.00,  0,   0,  0,  1),
(18, 'Carnarvon Tigers',               7,  8, '16 kg pkg.',           62.50,  42,  0,  0,  0),
(19, 'Teatime Chocolate Biscuits',     8,  3, '10 boxes x 12 pieces',  9.20,  25,  0,  5,  0),
(20, 'Sir Rodney Marmalade',           8,  3, '30 gift boxes',        81.00,  40,  0,  0,  0),
(21, 'Sir Rodney Scones',              8,  3, '24 pkgs. x 4 pieces',  10.00,  3,   40, 5,  0),
(22, 'Gustaf Knackebrod',              9,  5, '24 - 500 g pkgs.',     21.00,  104, 0,  25, 0),
(23, 'Tunnbrod',                       9,  5, '12 - 250 g pkgs.',      9.00,  61,  0,  25, 0),
(24, 'Guarana Fantastica',             10, 1, '12 - 355 ml cans',      4.50,  20,  0,  0,  1),
(25, 'NuNuCa Nuss-Nougat-Creme',      10, 3, '20 - 450 g glasses',   14.00,  76,  0,  30, 0);
SET IDENTITY_INSERT ventas.Producto OFF;
GO

-- ============================================================
-- 4. EMPLEADOS (9 registros con jerarquía)
-- ============================================================
-- Primero insertar el jefe (EmployeeID=1, ReportsTo=NULL)
SET IDENTITY_INSERT ventas.Empleado ON;
INSERT INTO ventas.Empleado (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo) VALUES
(1, 'Fuller',    'Andrew',   'Vice President, Sales',      '1952-02-19', '1992-08-14', '908 W. Capital Way',   'Tacoma',   'USA', NULL);

-- Luego los que reportan a Andrew (ReportsTo=1)
INSERT INTO ventas.Empleado (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo) VALUES
(2, 'Davolio',   'Nancy',    'Sales Representative',       '1968-12-08', '1992-05-01', '507 - 20th Ave. E.',   'Seattle',  'USA', 1),
(3, 'Leverling', 'Janet',    'Sales Representative',       '1963-08-30', '1992-04-01', '722 Moss Bay Blvd.',   'Kirkland', 'USA', 1),
(4, 'Peacock',   'Margaret', 'Sales Representative',       '1958-09-19', '1993-05-03', '4110 Old Redmond Rd.', 'Redmond',  'USA', 1),
(5, 'Buchanan',  'Steven',   'Sales Manager',              '1955-03-04', '1993-10-17', '14 Garrett Hill',      'London',   'UK',  1),
(8, 'Callahan',  'Laura',    'Inside Sales Coordinator',   '1958-01-09', '1994-03-05', '4726 - 11th Ave. N.E.','Seattle',  'USA', 1);

-- Los que reportan a Steven Buchanan (ReportsTo=5)
INSERT INTO ventas.Empleado (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Country, ReportsTo) VALUES
(6, 'Suyama',    'Michael',  'Sales Representative',       '1963-07-02', '1993-10-17', 'Coventry House',       'London',   'UK',  5),
(7, 'King',      'Robert',   'Sales Representative',       '1960-05-29', '1994-01-02', 'Edgeham Hollow',       'London',   'UK',  5),
(9, 'Dodsworth', 'Anne',     'Sales Representative',       '1966-01-27', '1994-11-15', '7 Houndstooth Rd.',    'London',   'UK',  5);
SET IDENTITY_INSERT ventas.Empleado OFF;
GO

-- ============================================================
-- 5. CLIENTES (42 registros - TODOS los que usan los pedidos)
-- ============================================================
INSERT INTO ventas.Cliente (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone) VALUES
('ALFKI', 'Alfreds Futterkiste',           'Maria Anders',        'Sales Representative',  'Obere Str. 57',              'Berlin',       NULL,  '12209',    'Germany',    '030-0074321'),
('ANATR', 'Ana Trujillo Emparedados',      'Ana Trujillo',        'Owner',                 'Avda. de la Constitucion',   'Mexico D.F.',  NULL,  '05021',    'Mexico',     '(5) 555-4729'),
('ANTON', 'Antonio Moreno Taqueria',       'Antonio Moreno',      'Owner',                 'Mataderos 2312',             'Mexico D.F.',  NULL,  '05023',    'Mexico',     '(5) 555-3932'),
('AROUT', 'Around the Horn',               'Thomas Hardy',        'Sales Representative',  '120 Hanover Sq.',            'London',       NULL,  'WA1 1DP',  'UK',         '(171) 555-7788'),
('BERGS', 'Berglunds snabbkop',            'Christina Berglund',  'Order Administrator',   'Berguvsvagen 8',             'Lulea',        NULL,  'S-958 22', 'Sweden',     '0921-12 34 65'),
('BLAUS', 'Blauer See Delikatessen',       'Hanna Moos',          'Sales Representative',  'Forsterstr. 57',             'Mannheim',     NULL,  '68306',    'Germany',    '0621-08460'),
('BLONP', 'Blondesddsl pere et fils',      'Frederique Citeaux',  'Marketing Manager',     '24, place Kleber',           'Strasbourg',   NULL,  '67000',    'France',     '88.60.15.31'),
('BOLID', 'Bolido Comidas preparadas',     'Martin Sommer',       'Owner',                 'C/ Araquil, 67',             'Madrid',       NULL,  '28023',    'Spain',      '(91) 555 22 82'),
('BONAP', 'Bon app',                       'Laurence Lebihan',    'Owner',                 '12, rue des Bouchers',       'Marseille',    NULL,  '13008',    'France',     '91.24.45.40'),
('BOTTM', 'Bottom-Dollar Markets',         'Elizabeth Lincoln',   'Accounting Manager',    '23 Tsawassen Blvd.',         'Tsawassen',    'BC',  'T2F 8M4',  'Canada',     '(604) 555-4729'),
('BSBEV', 'Bs Beverages',                  'Victoria Ashworth',   'Sales Representative',  'Fauntleroy Circus',          'London',       NULL,  'EC2 5NT',  'UK',         '(171) 555-1212'),
('CACTU', 'Cactus Comidas para llevar',    'Patricio Simpson',    'Sales Agent',           'Cerrito 333',                'Buenos Aires', NULL,  '1010',     'Argentina',  '(1) 135-5555'),
('CENTC', 'Centro comercial Moctezuma',    'Francisco Chang',     'Marketing Manager',     'Sierras de Granada 9993',    'Mexico D.F.',  NULL,  '05022',    'Mexico',     '(5) 555-3392'),
('CHOPS', 'Chop-suey Chinese',             'Yang Wang',           'Owner',                 'Hauptstr. 29',               'Bern',         NULL,  '3012',     'Switzerland','0452-076545'),
('COMMI', 'Comercio Mineiro',              'Pedro Afonso',        'Sales Associate',       'Av. dos Lusíadas, 23',       'Sao Paulo',    'SP',  '05432-043','Brazil',     '(11) 555-7647'),
('CONSH', 'Consolidated Holdings',         'Elizabeth Brown',     'Sales Representative',  'Berkeley Gardens 12 Brewery','London',       NULL,  'WX1 6LT',  'UK',         '(171) 555-2282'),
('DRACD', 'Drachenblut Delikatessen',      'Sven Ottlieb',        'Order Administrator',   'Walserweg 21',               'Aachen',       NULL,  '52066',    'Germany',    '0241-039123'),
('DUMON', 'Du monde entier',               'Janine Labrune',      'Owner',                 '67, rue des Cinquante Otages','Nantes',      NULL,  '44000',    'France',     '40.67.88.88'),
('EASTC', 'Eastern Connection',            'Ann Devon',           'Sales Agent',           '35 King George',             'London',       NULL,  'WX3 6FW',  'UK',         '(171) 555-0297'),
('ERNSH', 'Ernst Handel',                  'Roland Mendel',       'Sales Manager',         'Kirchgasse 6',               'Graz',         NULL,  '8010',     'Austria',    '7675-3425'),
('FAMIA', 'Familia Arquibaldo',            'Aria Cruz',           'Marketing Assistant',   'Rua Oros, 92',               'Sao Paulo',    'SP',  '05442-030','Brazil',     '(11) 555-9857'),
('FISSA', 'FISSA Fabrica Salchichas',      'Diego Roel',          'Accounting Manager',    'C/ Moralzarzal, 86',         'Madrid',       NULL,  '28034',    'Spain',      '(91) 555 94 44'),
('FOLIG', 'Folies gourmandes',             'Martine Rance',       'Assistant Sales Agent', '184, chaussee de Tournai',   'Lille',        NULL,  '59000',    'France',     '20.16.10.16'),
('FOLKO', 'Folk och fa HB',               'Maria Larsson',       'Owner',                 'Akergatan 24',               'Bracke',       NULL,  'S-844 67', 'Sweden',     '0695-34 67 21'),
('FRANK', 'Frankenversand',                'Peter Franken',       'Marketing Manager',     'Berliner Platz 43',          'Munchen',      NULL,  '80805',    'Germany',    '089-0877310'),
('GROSR', 'GROSELLA-Restaurante',          'Manuel Pereira',      'Owner',                 '5a Ave. Los Palos Grandes',  'Caracas',      'DF',  '1081',     'Venezuela',  '(2) 283-2951'),
('HANAR', 'Hanari Carnes',                 'Mario Pontes',        'Accounting Manager',    'Rua do Paco, 67',            'Rio de Janeiro','RJ', '05454-876','Brazil',     '(21) 555-0091'),
('HILAA', 'HILARION-Abastos',              'Carlos Hernandez',    'Sales Representative',  'Carrera 22 con Ave. Carlos Soublette','San Cristobal',NULL,'5022','Venezuela', '(5) 555-1340'),
('OTTIK', 'Ottilies Kaseladen',            'Henriette Pfalzheim', 'Owner',                 'Mehrheimerstr. 369',         'Koln',         NULL,  '50739',    'Germany',    '0221-0644327'),
('QUEDE', 'Que Delicia',                   'Bernardo Batista',    'Accounting Manager',    'Rua da Panificadora, 12',    'Rio de Janeiro','RJ', '02389-673','Brazil',     '(21) 555-4252'),
('RATTC', 'Rattlesnake Canyon Grocery',    'Paula Wilson',        'Assistant Sales Agent', '2817 Milton Dr.',            'Albuquerque',  'NM',  '87110',    'USA',        '(505) 555-5939'),
('RICSU', 'Richter Supermarkt',            'Michael Holz',        'Sales Manager',         'Grenzacherweg 237',          'Geneve',       NULL,  '1203',     'Switzerland','0897-034214'),
('SPLIR', 'Split Rail Beer and Ale',       'Art Braunschweiger',  'Sales Manager',         'P.O. Box 555',               'Lander',       'WY',  '82520',    'USA',        '(307) 555-4680'),
('SUPRD', 'Supremes delices',              'Pascale Cartrain',    'Accounting Manager',    'Boulevard Tirou, 255',       'Charleroi',    NULL,  'B-6000',   'Belgium',    '(071) 23 67 22 20'),
('TOMSP', 'Toms Spezialitaten',            'Karin Josephs',       'Marketing Manager',     'Luisenstr. 48',              'Munster',      NULL,  '44087',    'Germany',    '0251-031259'),
('VICTE', 'Victuailles en stock',          'Mary Saveley',        'Sales Agent',           '2, rue du Commerce',         'Lyon',         NULL,  '69004',    'France',     '78.32.54.86'),
('VINET', 'Vins et alcools Chevalier',     'Paul Henriot',        'Accounting Manager',    '59 rue de l''Abbaye',        'Reims',        NULL,  '51100',    'France',     '26.47.15.10'),
('WARTH', 'Wartian Herkku',                'Pirkko Koskitalo',    'Accounting Manager',    'Torikatu 38',                'Oulu',         NULL,  '90110',    'Finland',    '981-443655'),
('WELLI', 'Wellington Importadora',        'Paula Parente',       'Sales Manager',         'Rua do Mercado, 12',         'Resende',      'SP',  '08737-363','Brazil',     '(14) 555-8122'),
('WHITC', 'White Clover Markets',          'Karl Jablonski',      'Owner',                 '305 - 14th Ave. S. Suite 3B','Seattle',      'WA',  '98128',    'USA',        '(206) 555-4112');
GO

-- ============================================================
-- 6. TRANSPORTISTAS (5 registros)
-- ============================================================
SET IDENTITY_INSERT ventas.Transportista ON;
INSERT INTO ventas.Transportista (ShipperID, CompanyName, Phone) VALUES
(1, 'Speedy Express',   '(503) 555-9831'),
(2, 'United Package',   '(503) 555-3199'),
(3, 'Federal Shipping', '(503) 555-9931'),
(4, 'Alliance Shippers','1-800-222-0451'),
(5, 'UPS',              '(503) 555-0152');
SET IDENTITY_INSERT ventas.Transportista OFF;
GO

-- ============================================================
-- 7. PEDIDOS (25 registros)
-- ============================================================
SET IDENTITY_INSERT ventas.Pedido ON;
INSERT INTO ventas.Pedido (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipCountry) VALUES
(10248, 'VINET', 5, '2024-07-04', '2024-08-01', '2024-07-16', 3,  32.38, 'Vins et alcools Chevalier','59 rue de lAbbaye',   'Reims',          'France'),
(10249, 'TOMSP', 6, '2024-07-05', '2024-08-16', '2024-07-10', 1,  11.61, 'Toms Spezialitaten',       'Luisenstr. 48',       'Munster',        'Germany'),
(10250, 'HANAR', 4, '2024-07-08', '2024-08-05', '2024-07-12', 2,  65.83, 'Hanari Carnes',            'Rua do Paco, 67',     'Rio de Janeiro', 'Brazil'),
(10251, 'VICTE', 3, '2024-07-08', '2024-08-05', '2024-07-15', 1,  41.34, 'Victuailles en stock',     '2, rue du Commerce',  'Lyon',           'France'),
(10252, 'SUPRD', 4, '2024-07-09', '2024-08-06', '2024-07-11', 2,  51.30, 'Supremes delices',         'Boulevard Tirou, 255','Charleroi',      'Belgium'),
(10253, 'HANAR', 3, '2024-07-10', '2024-07-24', '2024-07-16', 2,  58.17, 'Hanari Carnes',            'Rua do Paco, 67',     'Rio de Janeiro', 'Brazil'),
(10254, 'CHOPS', 5, '2024-07-11', '2024-08-08', '2024-07-23', 2,  22.98, 'Chop-suey Chinese',        'Hauptstr. 31',        'Bern',           'Switzerland'),
(10255, 'RICSU', 9, '2024-07-12', '2024-08-09', '2024-07-15', 3, 148.33, 'Richter Supermarkt',       'Starenweg 5',         'Geneve',         'Switzerland'),
(10256, 'WELLI', 3, '2024-07-15', '2024-08-12', '2024-07-17', 2,  13.97, 'Wellington Importadora',   'Rua do Mercado, 12',  'Resende',        'Brazil'),
(10257, 'HILAA', 4, '2024-07-16', '2024-08-13', '2024-07-22', 3,  81.91, 'HILARION-Abastos',         'Carrera 22',          'San Cristobal',  'Venezuela'),
(10258, 'ERNSH', 1, '2024-07-17', '2024-08-14', '2024-07-23', 1, 140.51, 'Ernst Handel',             'Kirchgasse 6',        'Graz',           'Austria'),
(10259, 'CENTC', 4, '2024-07-18', '2024-08-15', '2024-07-25', 3,   3.25, 'Centro comercial Moctezuma','Sierras de Granada', 'Mexico D.F.',    'Mexico'),
(10260, 'OTTIK', 4, '2024-07-19', '2024-08-16', '2024-07-29', 1,  55.09, 'Ottilies Kaseladen',       'Mehrheimerstr. 369',  'Koln',           'Germany'),
(10261, 'QUEDE', 4, '2024-07-19', '2024-08-16', '2024-07-30', 2,   3.05, 'Que Delicia',              'Rua da Panificadora', 'Rio de Janeiro', 'Brazil'),
(10262, 'RATTC', 8, '2024-07-22', '2024-08-19', '2024-07-25', 3,  48.29, 'Rattlesnake Canyon Grocery','2817 Milton Dr.',    'Albuquerque',    'USA'),
(10263, 'ERNSH', 9, '2024-07-23', '2024-08-20', '2024-07-31', 3, 146.06, 'Ernst Handel',             'Kirchgasse 6',        'Graz',           'Austria'),
(10264, 'FOLKO', 6, '2024-07-24', '2024-08-21', '2024-08-23', 3,   3.67, 'Folk och fa HB',           'Akergatan 24',        'Bracke',         'Sweden'),
(10265, 'BLONP', 2, '2024-07-25', '2024-08-22', '2024-08-12', 1,  55.28, 'Blondel pere et fils',     '24, place Kleber',    'Strasbourg',     'France'),
(10266, 'WARTH', 3, '2024-07-26', '2024-09-06', '2024-07-31', 3,  25.73, 'Wartian Herkku',           'Torikatu 38',         'Oulu',           'Finland'),
(10267, 'FRANK', 4, '2024-07-29', '2024-08-26', '2024-08-06', 1, 208.58, 'Frankenversand',           'Berliner Platz 43',   'Munchen',        'Germany'),
(10268, 'GROSR', 8, '2024-07-30', '2024-08-27', '2024-08-02', 3,  66.29, 'GROSELLA-Restaurante',     '5a Ave. Los Palos Grandes','Caracas',   'Venezuela'),
(10269, 'WHITC', 5, '2024-07-31', '2024-08-14', '2024-08-09', 1,   4.56, 'White Clover Markets',     '1029 - 12th Ave. S.', 'Seattle',        'USA'),
(10270, 'WARTH', 1, '2024-08-01', '2024-08-29', '2024-08-02', 1, 136.54, 'Wartian Herkku',           'Torikatu 38',         'Oulu',           'Finland'),
(10271, 'SPLIR', 6, '2024-08-01', '2024-08-29', '2024-08-30', 2,   4.54, 'Split Rail Beer and Ale',  'P.O. Box 555',        'Lander',         'USA'),
(10272, 'RATTC', 6, '2024-08-02', '2024-08-30', '2024-08-06', 2,  98.03, 'Rattlesnake Canyon Grocery','2817 Milton Dr.',    'Albuquerque',    'USA');
SET IDENTITY_INSERT ventas.Pedido OFF;
GO

-- ============================================================
-- 8. DETALLE_PEDIDO (50 registros)
--    Solo ProductIDs que existen (1-25)
-- ============================================================
INSERT INTO ventas.DetallePedido (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES
(10248, 11, 14.00, 12, 0.00),
(10248,  1, 18.00, 10, 0.00),
(10248, 13,  6.00,  5, 0.00),
(10249, 14, 23.25,  9, 0.00),
(10249, 18, 62.50, 40, 0.00),
(10250, 20, 81.00, 10, 0.00),
(10250, 18, 62.50, 35, 0.15),
(10250, 16, 17.45, 15, 0.15),
(10251,  2, 19.00,  6, 0.05),
(10251,  6, 25.00, 15, 0.05),
(10251, 19,  9.20, 20, 0.00),
(10252, 20, 81.00, 40, 0.05),
(10252,  3, 10.00, 25, 0.05),
(10252, 22, 21.00, 40, 0.00),
(10253,  6, 25.00, 20, 0.00),
(10253, 14, 23.25, 42, 0.00),
(10253, 21, 10.00, 40, 0.00),
(10254, 24,  4.50, 15, 0.15),
(10254, 23,  9.00, 21, 0.15),
(10254,  7, 30.00, 21, 0.00),
(10255,  2, 19.00, 20, 0.00),
(10255, 16, 17.45, 35, 0.00),
(10255, 22, 21.00, 25, 0.00),
(10256, 18, 62.50, 15, 0.00),
(10256, 11, 21.00, 12, 0.00),
(10257,  6, 25.00, 25, 0.00),
(10257, 14, 23.25,  6, 0.00),
(10257, 25, 14.00, 15, 0.00),
(10258,  2, 19.00, 50, 0.20),
(10258,  5, 21.35, 65, 0.20),
(10259, 21, 10.00, 10, 0.00),
(10259,  3, 10.00,  1, 0.00),
(10260, 20, 81.00, 16, 0.25),
(10260, 19,  9.20, 50, 0.00),
(10261, 21, 10.00, 20, 0.00),
(10261, 22, 21.00, 20, 0.00),
(10262,  5, 21.35, 12, 0.20),
(10262,  7, 30.00, 15, 0.00),
(10263, 16, 17.45, 60, 0.25),
(10263, 24,  4.50, 28, 0.00),
(10264,  2, 19.00, 35, 0.00),
(10264, 20, 81.00, 25, 0.15),
(10265, 17, 39.00, 30, 0.00),
(10265, 25, 14.00, 20, 0.00),
(10266, 12, 38.00, 12, 0.05),
(10267, 20, 81.00, 50, 0.00),
(10267, 18, 62.50, 70, 0.15),
(10268, 10, 31.00, 10, 0.00),
(10268, 25, 14.00,  4, 0.00),
(10269,  3, 10.00, 60, 0.05);
GO

-- ============================================================
-- 9. VALIDACIÓN FINAL
-- ============================================================
PRINT '=== VALIDACION DE DATOS INSERTADOS ===';
SELECT 'Categoria'      AS Tabla, COUNT(*) AS Registros FROM ventas.Categoria
UNION ALL SELECT 'Proveedor',     COUNT(*) FROM ventas.Proveedor
UNION ALL SELECT 'Producto',      COUNT(*) FROM ventas.Producto
UNION ALL SELECT 'Empleado',      COUNT(*) FROM ventas.Empleado
UNION ALL SELECT 'Cliente',       COUNT(*) FROM ventas.Cliente
UNION ALL SELECT 'Transportista', COUNT(*) FROM ventas.Transportista
UNION ALL SELECT 'Pedido',        COUNT(*) FROM ventas.Pedido
UNION ALL SELECT 'DetallePedido', COUNT(*) FROM ventas.DetallePedido;

PRINT '=== VALIDACION INTEGRIDAD REFERENCIAL (todos deben ser 0) ===';
SELECT 'Pedidos sin Cliente'   AS Verificacion, COUNT(*) AS Total
FROM ventas.Pedido p LEFT JOIN ventas.Cliente c ON p.CustomerID = c.CustomerID WHERE c.CustomerID IS NULL
UNION ALL
SELECT 'Pedidos sin Empleado', COUNT(*)
FROM ventas.Pedido p LEFT JOIN ventas.Empleado e ON p.EmployeeID = e.EmployeeID WHERE e.EmployeeID IS NULL
UNION ALL
SELECT 'Detalles sin Pedido',  COUNT(*)
FROM ventas.DetallePedido d LEFT JOIN ventas.Pedido p ON d.OrderID = p.OrderID WHERE p.OrderID IS NULL
UNION ALL
SELECT 'Detalles sin Producto',COUNT(*)
FROM ventas.DetallePedido d LEFT JOIN ventas.Producto pr ON d.ProductID = pr.ProductID WHERE pr.ProductID IS NULL;

PRINT '>> Script 02 v2 ejecutado correctamente. Datos de prueba cargados sin errores.';
GO

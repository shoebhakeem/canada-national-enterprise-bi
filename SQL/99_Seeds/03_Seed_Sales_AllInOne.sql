USE CorpCore_OLTP;
GO

/* ============================================================
   SALES SEED - ALL IN ONE (Products + Services + Orders + Lines)
   ============================================================ */

/* 1) Products (no duplicates by ProductName) */
INSERT INTO oltp.Products (ProductName, ProductType, UnitPrice)
SELECT v.ProductName, v.ProductType, v.UnitPrice
FROM (VALUES
 ('Network Router','Hardware',450.00),
 ('Firewall Appliance','Hardware',900.00),
 ('Server Rack','Hardware',1200.00),
 ('Managed Switch','Hardware',700.00),
 ('Access Point','Hardware',300.00),
 ('Laptop Pro','Hardware',1500.00),
 ('Desktop Workstation','Hardware',1800.00),
 ('Storage NAS','Hardware',2200.00),
 ('Backup Device','Hardware',850.00),
 ('VPN Gateway','Hardware',650.00),
 ('CRM License','Software',50.00),
 ('ERP License','Software',120.00),
 ('Security Suite','Software',70.00),
 ('Office Productivity','Software',40.00),
 ('Analytics Platform','Software',90.00)
) v(ProductName, ProductType, UnitPrice)
WHERE NOT EXISTS (
    SELECT 1 FROM oltp.Products p WHERE p.ProductName = v.ProductName
);
GO

/* 2) Services (no duplicates by ServiceName) */
INSERT INTO oltp.ServiceCatalog (ServiceName, ServiceType, BaseRate)
SELECT v.ServiceName, v.ServiceType, v.BaseRate
FROM (VALUES
 ('Hardware Installation','Installation',200.00),
 ('Software Implementation','Implementation',1500.00),
 ('System Integration','Implementation',2200.00),
 ('Network Setup','Installation',800.00),
 ('Emergency Repair','Repair',300.00),
 ('Preventive Maintenance','Repair',180.00),
 ('IT Outsourcing','Outsourcing',120.00),
 ('Cloud Migration','Implementation',2500.00),
 ('System Audit','Consulting',900.00),
 ('Performance Optimization','Consulting',1100.00)
) v(ServiceName, ServiceType, BaseRate)
WHERE NOT EXISTS (
    SELECT 1 FROM oltp.ServiceCatalog s WHERE s.ServiceName = v.ServiceName
);
GO

/* 3) Ensure SalesOrders = 200 (top-up only) */
DECLARE @NeedOrders INT = 200 - (SELECT COUNT(*) FROM oltp.SalesOrders);

IF @NeedOrders > 0
BEGIN
    ;WITH N AS (
        SELECT TOP (@NeedOrders) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        FROM sys.objects
    )
    INSERT INTO oltp.SalesOrders (OrderNumber, CustomerID, OrderDate, SalesRepID, CityID, Status)
    SELECT
        CONCAT('SO-', RIGHT('000000' + CAST((SELECT ISNULL(MAX(SalesOrderID),0) FROM oltp.SalesOrders) + rn AS VARCHAR(6)),6)),
        (SELECT TOP 1 CustomerID FROM oltp.Customers ORDER BY NEWID()),
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, CAST(GETDATE() AS DATE)),
        (SELECT TOP 1 EmployeeID FROM oltp.Employees ORDER BY NEWID()),
        (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID()),
        'Closed'
    FROM N;
END
GO

/* 4) Ensure SalesOrderLines ≈ 1000 (top-up only; valid CK_SOL_LineType) */
DECLARE @NeedLines INT = 1000 - (SELECT COUNT(*) FROM oltp.SalesOrderLines);

IF @NeedLines > 0
BEGIN
    ;WITH N AS (
        SELECT TOP (@NeedLines) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.objects a CROSS JOIN sys.objects b
    ),
    Gen AS (
        SELECT
            (SELECT TOP 1 SalesOrderID FROM oltp.SalesOrders ORDER BY NEWID()) AS SalesOrderID,
            CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 1 ELSE 0 END AS IsProduct,
            CAST(ABS(CHECKSUM(NEWID())) % 5 + 1 AS DECIMAL(18,2)) AS Qty
        FROM N
    )
    INSERT INTO oltp.SalesOrderLines (SalesOrderID, LineType, ProductID, ServiceID, Quantity, UnitPrice)
    SELECT
        Gen.SalesOrderID,
        CASE WHEN Gen.IsProduct = 1 THEN 'Product' ELSE 'Service' END AS LineType,
        CASE WHEN Gen.IsProduct = 1 THEN (SELECT TOP 1 ProductID FROM oltp.Products ORDER BY NEWID()) ELSE NULL END AS ProductID,
        CASE WHEN Gen.IsProduct = 0 THEN (SELECT TOP 1 ServiceID FROM oltp.ServiceCatalog ORDER BY NEWID()) ELSE NULL END AS ServiceID,
        Gen.Qty AS Quantity,
        CASE
            WHEN Gen.IsProduct = 1 THEN (SELECT TOP 1 UnitPrice FROM oltp.Products ORDER BY NEWID())
            ELSE (SELECT TOP 1 BaseRate FROM oltp.ServiceCatalog ORDER BY NEWID())
        END AS UnitPrice
    FROM Gen;
END
GO

/* 5) Validation */
SELECT
 (SELECT COUNT(*) FROM oltp.Products)        AS Products,
 (SELECT COUNT(*) FROM oltp.ServiceCatalog)  AS Services,
 (SELECT COUNT(*) FROM oltp.SalesOrders)     AS Orders,
 (SELECT COUNT(*) FROM oltp.SalesOrderLines) AS OrderLines;
GO

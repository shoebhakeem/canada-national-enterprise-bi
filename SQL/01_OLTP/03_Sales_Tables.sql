USE CorpCore_OLTP;
GO

/* Products */
IF OBJECT_ID('oltp.Products','U') IS NOT NULL DROP TABLE oltp.Products;
GO
CREATE TABLE oltp.Products (
    ProductID     INT IDENTITY(1,1) PRIMARY KEY,
    ProductName   NVARCHAR(200) NOT NULL,
    ProductType   NVARCHAR(30)  NOT NULL, -- Hardware/Software
    UnitPrice     DECIMAL(18,2) NOT NULL,
    IsActive      BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT(1)
);
GO

/* Service Catalog */
IF OBJECT_ID('oltp.ServiceCatalog','U') IS NOT NULL DROP TABLE oltp.ServiceCatalog;
GO
CREATE TABLE oltp.ServiceCatalog (
    ServiceID     INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName   NVARCHAR(200) NOT NULL,
    ServiceType   NVARCHAR(40)  NOT NULL, -- Installation/Implementation/Repair/Outsourcing
    BaseRate      DECIMAL(18,2) NOT NULL, -- could be hourly or fixed base
    IsActive      BIT NOT NULL CONSTRAINT DF_ServiceCatalog_IsActive DEFAULT(1)
);
GO

/* Sales Orders (header) */
IF OBJECT_ID('oltp.SalesOrders','U') IS NOT NULL DROP TABLE oltp.SalesOrders;
GO
CREATE TABLE oltp.SalesOrders (
    SalesOrderID   INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber    NVARCHAR(30) NOT NULL UNIQUE, -- SO-000001
    CustomerID     INT NOT NULL,
    OrderDate      DATE NOT NULL,
    SalesRepID     INT NULL, -- EmployeeID (sales)
    CityID         INT NOT NULL, -- order city / customer city
    Status         NVARCHAR(20) NOT NULL, -- Open/Closed/Cancelled
    CONSTRAINT FK_SalesOrders_Customer FOREIGN KEY (CustomerID) REFERENCES oltp.Customers(CustomerID),
    CONSTRAINT FK_SalesOrders_SalesRep FOREIGN KEY (SalesRepID) REFERENCES oltp.Employees(EmployeeID),
    CONSTRAINT FK_SalesOrders_City     FOREIGN KEY (CityID)     REFERENCES oltp.Cities(CityID)
);
GO

/* Sales Order Lines (details) */
IF OBJECT_ID('oltp.SalesOrderLines','U') IS NOT NULL DROP TABLE oltp.SalesOrderLines;
GO
CREATE TABLE oltp.SalesOrderLines (
    SalesOrderLineID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID     INT NOT NULL,
    LineType         NVARCHAR(20) NOT NULL, -- Product/Service
    ProductID        INT NULL,
    ServiceID        INT NULL,
    Quantity         DECIMAL(18,2) NOT NULL,
    UnitPrice        DECIMAL(18,2) NOT NULL,
    LineAmount       AS (Quantity * UnitPrice) PERSISTED,
    CONSTRAINT FK_SOL_Order   FOREIGN KEY (SalesOrderID) REFERENCES oltp.SalesOrders(SalesOrderID),
    CONSTRAINT FK_SOL_Product FOREIGN KEY (ProductID)    REFERENCES oltp.Products(ProductID),
    CONSTRAINT FK_SOL_Service FOREIGN KEY (ServiceID)    REFERENCES oltp.ServiceCatalog(ServiceID),
    CONSTRAINT CK_SOL_LineType CHECK (
        (LineType='Product' AND ProductID IS NOT NULL AND ServiceID IS NULL)
        OR
        (LineType='Service' AND ServiceID IS NOT NULL AND ProductID IS NULL)
    )
);
GO

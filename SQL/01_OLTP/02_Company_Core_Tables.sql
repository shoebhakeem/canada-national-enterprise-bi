USE CorpCore_OLTP;
GO

-- 1) Departments
IF OBJECT_ID('oltp.Departments','U') IS NOT NULL DROP TABLE oltp.Departments;
GO
CREATE TABLE oltp.Departments (
    DepartmentID   INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    IsActive       BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT(1)
);
GO

-- 2) Roles
IF OBJECT_ID('oltp.Roles','U') IS NOT NULL DROP TABLE oltp.Roles;
GO
CREATE TABLE oltp.Roles (
    RoleID     INT IDENTITY(1,1) PRIMARY KEY,
    RoleName   NVARCHAR(120) NOT NULL UNIQUE,
    JobFamily  NVARCHAR(80)  NULL,  -- e.g., Sales, Ops, Finance, PMO
    IsActive   BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT(1)
);
GO

-- 3) Employees (assigned to City)
IF OBJECT_ID('oltp.Employees','U') IS NOT NULL DROP TABLE oltp.Employees;
GO
CREATE TABLE oltp.Employees (
    EmployeeID     INT IDENTITY(1000,1) PRIMARY KEY,
    EmployeeCode   NVARCHAR(20) NOT NULL UNIQUE, -- e.g., EMP-1000
    FirstName      NVARCHAR(80) NOT NULL,
    LastName       NVARCHAR(80) NOT NULL,
    DepartmentID   INT NOT NULL,
    RoleID         INT NOT NULL,
    CityID         INT NOT NULL,
    HireDate       DATE NOT NULL,
    EmploymentType NVARCHAR(30) NOT NULL, -- Permanent/Contractor
    Status         NVARCHAR(20) NOT NULL, -- Active/OnLeave/Exited
    Email          NVARCHAR(200) NULL,
    CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentID) REFERENCES oltp.Departments(DepartmentID),
    CONSTRAINT FK_Employees_Role       FOREIGN KEY (RoleID)       REFERENCES oltp.Roles(RoleID),
    CONSTRAINT FK_Employees_City       FOREIGN KEY (CityID)       REFERENCES oltp.Cities(CityID)
);
GO

-- 4) Customers (assigned to City)
IF OBJECT_ID('oltp.Customers','U') IS NOT NULL DROP TABLE oltp.Customers;
GO
CREATE TABLE oltp.Customers (
    CustomerID    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName  NVARCHAR(200) NOT NULL,
    Industry      NVARCHAR(80)  NULL,  -- Telecom, Retail, Gov, etc.
    Segment       NVARCHAR(50)  NULL,  -- SMB/Enterprise/Public
    CityID        INT NOT NULL,
    IsActive      BIT NOT NULL CONSTRAINT DF_Customers_IsActive DEFAULT(1),
    CONSTRAINT FK_Customers_City FOREIGN KEY (CityID) REFERENCES oltp.Cities(CityID)
);
GO

-- 5) Vendors (assigned to City)
IF OBJECT_ID('oltp.Vendors','U') IS NOT NULL DROP TABLE oltp.Vendors;
GO
CREATE TABLE oltp.Vendors (
    VendorID     INT IDENTITY(1,1) PRIMARY KEY,
    VendorName   NVARCHAR(200) NOT NULL,
    Category     NVARCHAR(80)  NULL, -- Hardware Supplier, Subcontractor, etc.
    CityID       INT NOT NULL,
    IsActive     BIT NOT NULL CONSTRAINT DF_Vendors_IsActive DEFAULT(1),
    CONSTRAINT FK_Vendors_City FOREIGN KEY (CityID) REFERENCES oltp.Cities(CityID)
);
GO
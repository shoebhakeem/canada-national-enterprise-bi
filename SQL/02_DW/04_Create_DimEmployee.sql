USE CorpCore_DW;
GO

IF OBJECT_ID('dbo.DimEmployee', 'U') IS NOT NULL
    DROP TABLE dbo.DimEmployee;
GO

CREATE TABLE dbo.DimEmployee
(
    EmployeeKey       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeID        INT               NOT NULL,
    EmployeeCode      NVARCHAR(50)      NULL,
    FirstName         NVARCHAR(100)     NOT NULL,
    LastName          NVARCHAR(100)     NOT NULL,
    EmployeeFullName  NVARCHAR(201)     NOT NULL,
    DepartmentID      INT               NULL,
    RoleID            INT               NULL,
    CityID            INT               NULL,
    HireDate          DATE              NULL,
    EmploymentType    NVARCHAR(50)      NULL,
    Status            NVARCHAR(50)      NULL,
    Email             NVARCHAR(255)     NULL,
    IsActive          BIT               NOT NULL DEFAULT 1,
    CreatedDate       DATETIME2         NOT NULL DEFAULT SYSDATETIME(),
    ModifiedDate      DATETIME2         NULL
);
GO

ALTER TABLE dbo.DimEmployee
ADD CONSTRAINT UQ_DimEmployee_EmployeeID UNIQUE (EmployeeID);
GO

CREATE INDEX IX_DimEmployee_FullName
    ON dbo.DimEmployee(EmployeeFullName);
GO

CREATE INDEX IX_DimEmployee_DepartmentID
    ON dbo.DimEmployee(DepartmentID);
GO

CREATE INDEX IX_DimEmployee_RoleID
    ON dbo.DimEmployee(RoleID);
GO

CREATE INDEX IX_DimEmployee_CityID
    ON dbo.DimEmployee(CityID);
GO

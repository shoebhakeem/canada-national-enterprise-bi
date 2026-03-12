USE CorpCore_DW;
GO

SET NOCOUNT ON;

TRUNCATE TABLE dbo.DimEmployee;
GO

INSERT INTO dbo.DimEmployee
(
    EmployeeID,
    EmployeeCode,
    FirstName,
    LastName,
    EmployeeFullName,
    DepartmentID,
    RoleID,
    CityID,
    HireDate,
    EmploymentType,
    Status,
    Email,
    IsActive,
    CreatedDate,
    ModifiedDate
)
SELECT
    e.EmployeeID,
    e.EmployeeCode,
    e.FirstName,
    e.LastName,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeFullName,
    e.DepartmentID,
    e.RoleID,
    e.CityID,
    e.HireDate,
    e.EmploymentType,
    e.Status,
    e.Email,
    CASE 
        WHEN UPPER(LTRIM(RTRIM(e.Status))) IN ('INACTIVE', 'RESIGNED', 'TERMINATED')
            THEN 0
        ELSE 1
    END AS IsActive,
    SYSDATETIME(),
    NULL
FROM CorpCore_OLTP.oltp.Employees e;
GO

USE CorpCore_OLTP;
GO

/* 1) Departments */
INSERT INTO oltp.Departments (DepartmentName)
SELECT v.DepartmentName
FROM (VALUES
 ('Sales'),
 ('Operations'),
 ('Finance'),
 ('HR'),
 ('Procurement'),
 ('PMO')
) v(DepartmentName)
WHERE NOT EXISTS (
  SELECT 1 FROM oltp.Departments d WHERE d.DepartmentName = v.DepartmentName
);
GO

/* 2) Roles */
INSERT INTO oltp.Roles (RoleName, JobFamily)
SELECT v.RoleName, v.JobFamily
FROM (VALUES
 ('Account Executive','Sales'),
 ('Sales Manager','Sales'),
 ('Project Manager','PMO'),
 ('Business Analyst','PMO'),
 ('BI Developer','PMO'),
 ('Field Technician','Operations'),
 ('Service Delivery Lead','Operations'),
 ('Procurement Specialist','Procurement'),
 ('Finance Analyst','Finance'),
 ('Accountant','Finance'),
 ('HR Specialist','HR'),
 ('Operations Manager','Operations')
) v(RoleName, JobFamily)
WHERE NOT EXISTS (
  SELECT 1 FROM oltp.Roles r WHERE r.RoleName = v.RoleName
);
GO

/* Helper: pick some CityIDs (random-ish) */
;WITH CitySample AS (
    SELECT TOP (30) CityID
    FROM oltp.Cities
    ORDER BY NEWID()
)
SELECT * FROM CitySample;

GO


/**********************************************UPDATE**********************************************/

 USE CorpCore_OLTP;
GO

-- If the failed insert created 0 employees, this is safe.
-- If some employees exist, this avoids duplicates by EmployeeCode.
DECLARE @HQCityID INT = 22;

WITH Dept AS (
    SELECT DepartmentID, DepartmentName FROM oltp.Departments
),
RoleMap AS (
    SELECT RoleID, RoleName FROM oltp.Roles
),
EmpSeed AS (
    SELECT *
    FROM (VALUES
    ('EMP-0001','Ayaan','Khan','Sales','Account Executive', @HQCityID),
    ('EMP-0002','Zara','Patel','Sales','Sales Manager',      @HQCityID),
    ('EMP-0003','Omar','Singh','PMO','Project Manager',      @HQCityID),
    ('EMP-0004','Noah','Smith','PMO','Business Analyst',     @HQCityID),
    ('EMP-0005','Liam','Brown','PMO','BI Developer',         @HQCityID),

    ('EMP-0006','Maya','Lee','Operations','Field Technician', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0007','Ayaan','Smith','Operations','Service Delivery Lead', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0008','Zara','Brown','Operations','Operations Manager', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0009','Omar','Patel','Finance','Finance Analyst',  (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0010','Noah','Khan','Finance','Accountant',        (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),

    ('EMP-0011','Liam','Singh','HR','HR Specialist',         (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0012','Maya','Patel','Procurement','Procurement Specialist', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0013','Ayaan','Lee','Sales','Account Executive',   (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0014','Zara','Smith','PMO','Project Manager',      (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0015','Omar','Brown','PMO','BI Developer',         (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),

    ('EMP-0016','Noah','Lee','Operations','Field Technician', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0017','Liam','Patel','Operations','Field Technician', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0018','Maya','Khan','Sales','Sales Manager',       (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0019','Ayaan','Patel','Finance','Finance Analyst', (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID())),
    ('EMP-0020','Zara','Singh','PMO','Business Analyst',     (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID()))
    ) AS v(EmployeeCode, FirstName, LastName, DepartmentName, RoleName, CityID)
)
INSERT INTO oltp.Employees
(EmployeeCode, FirstName, LastName, DepartmentID, RoleID, CityID, HireDate, EmploymentType, Status, Email)
SELECT
    e.EmployeeCode,
    e.FirstName,
    e.LastName,
    d.DepartmentID,
    r.RoleID,
    e.CityID,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1500, CAST(GETDATE() AS DATE)) AS HireDate,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Permanent' ELSE 'Contractor' END AS EmploymentType,
    'Active' AS Status,
    CONCAT(LOWER(e.FirstName), '.', LOWER(e.LastName), '@mshsolutions.ca') AS Email
FROM EmpSeed e
JOIN Dept d     ON d.DepartmentName = e.DepartmentName
JOIN RoleMap r  ON r.RoleName = e.RoleName
WHERE NOT EXISTS (
    SELECT 1 FROM oltp.Employees ex WHERE ex.EmployeeCode = e.EmployeeCode
);
GO

SELECT COUNT(*) AS Employees FROM oltp.Employees;
GO

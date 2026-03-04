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
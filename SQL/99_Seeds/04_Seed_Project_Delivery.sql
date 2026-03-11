USE CorpCore_OLTP;
GO

/* 1) SLA Definitions */
INSERT INTO oltp.SLA_Definitions (SLAName, TargetValue, UnitOfMeasure, AppliesTo)
SELECT v.SLAName, v.TargetValue, v.UnitOfMeasure, v.AppliesTo
FROM (VALUES
 ('Project Completion Timeliness', 95.00, 'Percent', 'Project'),
 ('Milestone Adherence', 90.00, 'Percent', 'Milestone'),
 ('Issue Resolution Time', 48.00, 'Hours', 'Project'),
 ('Implementation Lead Time', 30.00, 'Days', 'Project')
) v(SLAName, TargetValue, UnitOfMeasure, AppliesTo)
WHERE NOT EXISTS (
    SELECT 1 FROM oltp.SLA_Definitions s WHERE s.SLAName = v.SLAName
);
GO

/* 2) Projects (fixed 15 rows, deterministic) */
INSERT INTO oltp.Projects
(ProjectCode, ProjectName, CustomerID, CityID, ProjectType, StartDate, EndDate, ProjectStatus, ContractValue)
SELECT
    CONCAT('PRJ-', RIGHT('0000' + CAST(n.rn AS VARCHAR(4)),4)),
    CONCAT(
        CASE (n.rn % 4)
            WHEN 1 THEN 'ERP'
            WHEN 2 THEN 'Network'
            WHEN 3 THEN 'Cloud'
            ELSE 'Security'
        END,
        ' ',
        CASE ((n.rn + 1) % 4)
            WHEN 1 THEN 'Implementation'
            WHEN 2 THEN 'Upgrade'
            WHEN 3 THEN 'Rollout'
            ELSE 'Deployment'
        END
    ),
    (SELECT TOP 1 CustomerID FROM oltp.Customers ORDER BY NEWID()),
    (SELECT TOP 1 CityID FROM oltp.Cities ORDER BY NEWID()),
    CASE (n.rn % 4)
        WHEN 1 THEN 'Implementation'
        WHEN 2 THEN 'Outsourcing'
        WHEN 3 THEN 'Upgrade'
        ELSE 'Maintenance'
    END,
    DATEADD(DAY, -(n.rn * 10), CAST(GETDATE() AS DATE)),
    DATEADD(DAY, (n.rn * 15), CAST(GETDATE() AS DATE)),
    CASE (n.rn % 4)
        WHEN 1 THEN 'Planned'
        WHEN 2 THEN 'Active'
        WHEN 3 THEN 'Closed'
        ELSE 'On Hold'
    END,
    CAST((n.rn * 5000) + 10000 AS DECIMAL(18,2))
FROM (
    SELECT TOP (15) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects
) n
WHERE NOT EXISTS (
    SELECT 1
    FROM oltp.Projects p
    WHERE p.ProjectCode = CONCAT('PRJ-', RIGHT('0000' + CAST(n.rn AS VARCHAR(4)),4))
);
GO

/* 3) Project Milestones (3 per project) */
INSERT INTO oltp.ProjectMilestones
(ProjectID, MilestoneName, PlannedDate, ActualDate, MilestoneStatus)
SELECT
    p.ProjectID,
    m.MilestoneName,
    DATEADD(DAY, m.DayOffset, p.StartDate),
    CASE
        WHEN p.ProjectStatus = 'Closed' THEN DATEADD(DAY, m.DayOffset + 2, p.StartDate)
        WHEN p.ProjectStatus = 'Active' AND m.DayOffset < 60 THEN DATEADD(DAY, m.DayOffset + 1, p.StartDate)
        ELSE NULL
    END,
    CASE
        WHEN p.ProjectStatus = 'Closed' THEN 'Completed'
        WHEN p.ProjectStatus = 'Active' AND m.DayOffset < 60 THEN 'Completed'
        ELSE 'Pending'
    END
FROM oltp.Projects p
CROSS JOIN (VALUES
    ('Kickoff', 7),
    ('Build Complete', 45),
    ('Go Live', 90)
) m(MilestoneName, DayOffset)
WHERE NOT EXISTS (
    SELECT 1
    FROM oltp.ProjectMilestones pm
    WHERE pm.ProjectID = p.ProjectID
      AND pm.MilestoneName = m.MilestoneName
);
GO

/* 4) Project Assignments (2 per project) */
INSERT INTO oltp.ProjectAssignments
(ProjectID, EmployeeID, AssignmentRole, AllocationPercent, StartDate, EndDate)
SELECT
    p.ProjectID,
    e.EmployeeID,
    CASE ((p.ProjectID + e.EmployeeID) % 4)
        WHEN 1 THEN 'PM'
        WHEN 2 THEN 'BA'
        WHEN 3 THEN 'Developer'
        ELSE 'Technician'
    END,
    CAST(50.00 AS DECIMAL(5,2)),
    p.StartDate,
    NULL
FROM oltp.Projects p
CROSS APPLY (
    SELECT TOP 2 EmployeeID
    FROM oltp.Employees
    ORDER BY NEWID()
) e
WHERE NOT EXISTS (
    SELECT 1
    FROM oltp.ProjectAssignments pa
    WHERE pa.ProjectID = p.ProjectID
      AND pa.EmployeeID = e.EmployeeID
);
GO

/* 5) Timesheets (300 rows) */
;WITH N AS (
    SELECT TOP (300) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO oltp.Timesheets
(EmployeeID, ProjectID, WorkDate, HoursWorked, WorkType)
SELECT
    (SELECT TOP 1 EmployeeID FROM oltp.Employees ORDER BY NEWID()),
    (SELECT TOP 1 ProjectID FROM oltp.Projects ORDER BY NEWID()),
    DATEADD(DAY, -(n.rn % 120), CAST(GETDATE() AS DATE)),
    CAST(((n.rn % 8) + 1) AS DECIMAL(5,2)),
    CASE (n.rn % 4)
        WHEN 1 THEN 'Analysis'
        WHEN 2 THEN 'Development'
        WHEN 3 THEN 'Implementation'
        ELSE 'Support'
    END
FROM N
WHERE EXISTS (SELECT 1 FROM oltp.Projects);
GO

/* 6) SLA Results */
INSERT INTO oltp.SLA_Results
(ProjectID, SLAID, MeasurementDate, ActualValue, ComplianceStatus)
SELECT
    p.ProjectID,
    s.SLAID,
    CAST(GETDATE() AS DATE),
    CASE
        WHEN s.UnitOfMeasure = 'Percent' THEN CAST(85 + (p.ProjectID % 15) AS DECIMAL(10,2))
        WHEN s.UnitOfMeasure = 'Hours' THEN CAST(24 + (p.ProjectID % 30) AS DECIMAL(10,2))
        WHEN s.UnitOfMeasure = 'Days' THEN CAST(10 + (p.ProjectID % 20) AS DECIMAL(10,2))
        ELSE CAST(0 AS DECIMAL(10,2))
    END,
    CASE
        WHEN s.UnitOfMeasure = 'Percent' AND (85 + (p.ProjectID % 15)) >= s.TargetValue THEN 'Met'
        WHEN s.UnitOfMeasure = 'Hours'   AND (24 + (p.ProjectID % 30)) <= s.TargetValue THEN 'Met'
        WHEN s.UnitOfMeasure = 'Days'    AND (10 + (p.ProjectID % 20)) <= s.TargetValue THEN 'Met'
        ELSE 'Breached'
    END
FROM oltp.Projects p
CROSS JOIN oltp.SLA_Definitions s
WHERE NOT EXISTS (
    SELECT 1
    FROM oltp.SLA_Results r
    WHERE r.ProjectID = p.ProjectID
      AND r.SLAID = s.SLAID
);
GO

/* Validation */
SELECT
 (SELECT COUNT(*) FROM oltp.Projects)            AS Projects,
 (SELECT COUNT(*) FROM oltp.ProjectMilestones)   AS ProjectMilestones,
 (SELECT COUNT(*) FROM oltp.ProjectAssignments)  AS ProjectAssignments,
 (SELECT COUNT(*) FROM oltp.Timesheets)          AS Timesheets,
 (SELECT COUNT(*) FROM oltp.SLA_Definitions)     AS SLA_Definitions,
 (SELECT COUNT(*) FROM oltp.SLA_Results)         AS SLA_Results;
GO

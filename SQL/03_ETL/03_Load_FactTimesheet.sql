USE CorpCore_DW;
GO

SET NOCOUNT ON;

TRUNCATE TABLE dbo.FactTimesheet;
GO

INSERT INTO dbo.FactTimesheet
(
    TimesheetID,
    TimesheetDateKey,
    ProjectKey,
    EmployeeKey,
    HoursWorked,
    BillableHours,
    NonBillableHours,
    EntryDescription,
    CreatedDate
)
SELECT
    t.TimesheetID,
    CAST(CONVERT(CHAR(8), t.WorkDate, 112) AS INT) AS TimesheetDateKey,
    dp.ProjectKey,
    de.EmployeeKey,
    CAST(t.HoursWorked AS DECIMAL(10,2)) AS HoursWorked,
    CAST(
        CASE
            WHEN UPPER(LTRIM(RTRIM(t.WorkType))) = 'BILLABLE' THEN t.HoursWorked
            ELSE 0
        END AS DECIMAL(10,2)
    ) AS BillableHours,
    CAST(
        CASE
            WHEN UPPER(LTRIM(RTRIM(t.WorkType))) = 'BILLABLE' THEN 0
            ELSE t.HoursWorked
        END AS DECIMAL(10,2)
    ) AS NonBillableHours,
    t.WorkType AS EntryDescription,
    SYSDATETIME()
FROM CorpCore_OLTP.oltp.Timesheets t
INNER JOIN dbo.DimProject dp
    ON t.ProjectID = dp.ProjectID
INNER JOIN dbo.DimEmployee de
    ON t.EmployeeID = de.EmployeeID
INNER JOIN dbo.DimDate dd
    ON dd.[Date] = t.WorkDate;
GO

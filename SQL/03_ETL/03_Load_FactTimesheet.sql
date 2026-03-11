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
    EmployeeID,
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
    t.EmployeeID,
    CAST(t.HoursWorked AS DECIMAL(10,2)) AS HoursWorked,
    CAST(
        CASE 
            WHEN UPPER(LTRIM(RTRIM(t.WorkType))) = 'BILLABLE' THEN t.HoursWorked
            ELSE 0
        END
        AS DECIMAL(10,2)
    ) AS BillableHours,
    CAST(
        CASE 
            WHEN UPPER(LTRIM(RTRIM(t.WorkType))) = 'BILLABLE' THEN 0
            ELSE t.HoursWorked
        END
        AS DECIMAL(10,2)
    ) AS NonBillableHours,
    t.WorkType AS EntryDescription,
    SYSDATETIME() AS CreatedDate
FROM CorpCore_OLTP.oltp.Timesheets t
INNER JOIN dbo.DimProject dp
    ON t.ProjectID = dp.ProjectID
INNER JOIN dbo.DimDate dd
    ON dd.[Date] = t.WorkDate;
GO

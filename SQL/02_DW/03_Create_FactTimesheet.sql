USE CorpCore_DW;
GO

IF OBJECT_ID('dbo.FactTimesheet', 'U') IS NOT NULL
    DROP TABLE dbo.FactTimesheet;
GO

CREATE TABLE dbo.FactTimesheet
(
    TimesheetFactKey     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TimesheetID          INT                  NOT NULL,   -- OLTP transaction key
    TimesheetDateKey     INT                  NOT NULL,
    ProjectKey           INT                  NOT NULL,
    EmployeeID           INT                  NOT NULL,   -- temporary until DimEmployee is added
    HoursWorked          DECIMAL(10,2)        NOT NULL,
    BillableHours        DECIMAL(10,2)        NULL,
    NonBillableHours     DECIMAL(10,2)        NULL,
    EntryDescription     NVARCHAR(500)        NULL,
    CreatedDate          DATETIME2            NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE UNIQUE INDEX IX_FactTimesheet_TimesheetID
    ON dbo.FactTimesheet(TimesheetID);
GO

CREATE INDEX IX_FactTimesheet_DateKey
    ON dbo.FactTimesheet(TimesheetDateKey);
GO

CREATE INDEX IX_FactTimesheet_ProjectKey
    ON dbo.FactTimesheet(ProjectKey);
GO

CREATE INDEX IX_FactTimesheet_EmployeeID
    ON dbo.FactTimesheet(EmployeeID);
GO

ALTER TABLE dbo.FactTimesheet
ADD CONSTRAINT FK_FactTimesheet_DimDate
FOREIGN KEY (TimesheetDateKey) REFERENCES dbo.DimDate(DateKey);
GO

ALTER TABLE dbo.FactTimesheet
ADD CONSTRAINT FK_FactTimesheet_DimProject
FOREIGN KEY (ProjectKey) REFERENCES dbo.DimProject(ProjectKey);
GO

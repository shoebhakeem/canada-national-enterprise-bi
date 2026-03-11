USE CorpCore_OLTP;
GO

/* Projects */
IF OBJECT_ID('oltp.Projects','U') IS NOT NULL DROP TABLE oltp.Projects;
GO
CREATE TABLE oltp.Projects (
    ProjectID        INT IDENTITY(1,1) PRIMARY KEY,
    ProjectCode      NVARCHAR(30) NOT NULL UNIQUE,   -- PRJ-0001
    ProjectName      NVARCHAR(200) NOT NULL,
    CustomerID       INT NOT NULL,
    CityID           INT NOT NULL,
    ProjectType      NVARCHAR(40) NOT NULL,          -- Implementation / Outsourcing / Upgrade / Maintenance
    StartDate        DATE NOT NULL,
    EndDate          DATE NULL,
    ProjectStatus    NVARCHAR(20) NOT NULL,          -- Planned / Active / Closed / On Hold
    ContractValue    DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Projects_Customer FOREIGN KEY (CustomerID) REFERENCES oltp.Customers(CustomerID),
    CONSTRAINT FK_Projects_City     FOREIGN KEY (CityID) REFERENCES oltp.Cities(CityID)
);
GO

/* Project Milestones */
IF OBJECT_ID('oltp.ProjectMilestones','U') IS NOT NULL DROP TABLE oltp.ProjectMilestones;
GO
CREATE TABLE oltp.ProjectMilestones (
    MilestoneID        INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID          INT NOT NULL,
    MilestoneName      NVARCHAR(150) NOT NULL,
    PlannedDate        DATE NOT NULL,
    ActualDate         DATE NULL,
    MilestoneStatus    NVARCHAR(20) NOT NULL,   -- Pending / Completed / Delayed
    CONSTRAINT FK_ProjectMilestones_Project FOREIGN KEY (ProjectID) REFERENCES oltp.Projects(ProjectID)
);
GO

/* Project Assignments */
IF OBJECT_ID('oltp.ProjectAssignments','U') IS NOT NULL DROP TABLE oltp.ProjectAssignments;
GO
CREATE TABLE oltp.ProjectAssignments (
    AssignmentID       INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID          INT NOT NULL,
    EmployeeID         INT NOT NULL,
    AssignmentRole     NVARCHAR(100) NOT NULL,   -- PM / BA / Developer / Technician
    AllocationPercent  DECIMAL(5,2) NOT NULL,    -- e.g. 50.00
    StartDate          DATE NOT NULL,
    EndDate            DATE NULL,
    CONSTRAINT FK_ProjectAssignments_Project  FOREIGN KEY (ProjectID) REFERENCES oltp.Projects(ProjectID),
    CONSTRAINT FK_ProjectAssignments_Employee FOREIGN KEY (EmployeeID) REFERENCES oltp.Employees(EmployeeID)
);
GO

/* Timesheets */
IF OBJECT_ID('oltp.Timesheets','U') IS NOT NULL DROP TABLE oltp.Timesheets;
GO
CREATE TABLE oltp.Timesheets (
    TimesheetID        INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID         INT NOT NULL,
    ProjectID          INT NOT NULL,
    WorkDate           DATE NOT NULL,
    HoursWorked        DECIMAL(5,2) NOT NULL,
    WorkType           NVARCHAR(50) NOT NULL,   -- Analysis / Development / Implementation / Support
    CONSTRAINT FK_Timesheets_Employee FOREIGN KEY (EmployeeID) REFERENCES oltp.Employees(EmployeeID),
    CONSTRAINT FK_Timesheets_Project  FOREIGN KEY (ProjectID) REFERENCES oltp.Projects(ProjectID)
);
GO

/* SLA Definitions */
IF OBJECT_ID('oltp.SLA_Definitions','U') IS NOT NULL DROP TABLE oltp.SLA_Definitions;
GO
CREATE TABLE oltp.SLA_Definitions (
    SLAID             INT IDENTITY(1,1) PRIMARY KEY,
    SLAName           NVARCHAR(150) NOT NULL,
    TargetValue       DECIMAL(10,2) NOT NULL,
    UnitOfMeasure     NVARCHAR(30) NOT NULL,    -- Hours / Days / Percent
    AppliesTo         NVARCHAR(50) NOT NULL     -- Project / Milestone / Support
);
GO

/* SLA Results */
IF OBJECT_ID('oltp.SLA_Results','U') IS NOT NULL DROP TABLE oltp.SLA_Results;
GO
CREATE TABLE oltp.SLA_Results (
    SLAResultID       INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID         INT NOT NULL,
    SLAID             INT NOT NULL,
    MeasurementDate   DATE NOT NULL,
    ActualValue       DECIMAL(10,2) NOT NULL,
    ComplianceStatus  NVARCHAR(20) NOT NULL,   -- Met / Breached
    CONSTRAINT FK_SLAResults_Project FOREIGN KEY (ProjectID) REFERENCES oltp.Projects(ProjectID),
    CONSTRAINT FK_SLAResults_SLA     FOREIGN KEY (SLAID) REFERENCES oltp.SLA_Definitions(SLAID)
);
GO

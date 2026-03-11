USE CorpCore_DW;
GO

SET NOCOUNT ON;

TRUNCATE TABLE dbo.DimProject;
GO

INSERT INTO dbo.DimProject
(
    ProjectID,
    ProjectCode,
    ProjectName,
    ProjectType,
    CustomerID,
    BranchID,
    StartDate,
    EndDate,
    ProjectStatus,
    IsActive,
    CreatedDate,
    ModifiedDate
)
SELECT
    p.ProjectID,
    p.ProjectCode,
    p.ProjectName,
    p.ProjectType,
    p.CustomerID,
    NULL AS BranchID,
    p.StartDate,
    p.EndDate,
    p.ProjectStatus,
    CASE
        WHEN p.ProjectStatus IN ('Completed', 'Cancelled', 'Closed') THEN 0
        ELSE 1
    END AS IsActive,
    SYSDATETIME() AS CreatedDate,
    NULL AS ModifiedDate
FROM CorpCore_OLTP.oltp.Projects p;
GO

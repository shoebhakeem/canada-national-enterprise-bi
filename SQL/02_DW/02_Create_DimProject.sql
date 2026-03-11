USE CorpCore_DW;
GO

IF OBJECT_ID('dbo.DimProject', 'U') IS NOT NULL
    DROP TABLE dbo.DimProject;
GO

CREATE TABLE dbo.DimProject
(
    ProjectKey           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectID            INT               NOT NULL,   -- OLTP business key
    ProjectCode          NVARCHAR(50)      NULL,
    ProjectName          NVARCHAR(200)     NOT NULL,
    ProjectType          NVARCHAR(100)     NULL,
    CustomerID           INT               NULL,
    BranchID             INT               NULL,
    StartDate            DATE              NULL,
    EndDate              DATE              NULL,
    ProjectStatus        NVARCHAR(50)      NULL,
    IsActive             BIT               NOT NULL DEFAULT 1,
    CreatedDate          DATETIME2         NOT NULL DEFAULT SYSDATETIME(),
    ModifiedDate         DATETIME2         NULL
);
GO

ALTER TABLE dbo.DimProject
ADD CONSTRAINT UQ_DimProject_ProjectID UNIQUE (ProjectID);
GO

CREATE INDEX IX_DimProject_ProjectName
    ON dbo.DimProject(ProjectName);
GO

CREATE INDEX IX_DimProject_ProjectType
    ON dbo.DimProject(ProjectType);
GO

CREATE INDEX IX_DimProject_ProjectStatus
    ON dbo.DimProject(ProjectStatus);
GO

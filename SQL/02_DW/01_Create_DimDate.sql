USE CorpCore_DW;
GO

IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate
(
    DateKey              INT            NOT NULL PRIMARY KEY,   -- YYYYMMDD
    [Date]               DATE           NOT NULL,
    DayNumberOfMonth     TINYINT        NOT NULL,
    DayName              NVARCHAR(20)   NOT NULL,
    DayOfWeekNumber      TINYINT        NOT NULL,               -- 1=Sunday ... 7=Saturday
    DayOfYearNumber      SMALLINT       NOT NULL,
    WeekOfYearNumber     TINYINT        NOT NULL,
    MonthNumber          TINYINT        NOT NULL,
    MonthName            NVARCHAR(20)   NOT NULL,
    QuarterNumber        TINYINT        NOT NULL,
    QuarterName          NVARCHAR(10)   NOT NULL,               -- Q1, Q2...
    YearNumber           SMALLINT       NOT NULL,
    YearMonth            CHAR(7)        NOT NULL,               -- YYYY-MM
    MonthYearLabel       CHAR(8)        NOT NULL,               -- MMM YYYY
    IsWeekend            BIT            NOT NULL,
    IsMonthStart         BIT            NOT NULL,
    IsMonthEnd           BIT            NOT NULL,
    IsQuarterStart       BIT            NOT NULL,
    IsQuarterEnd         BIT            NOT NULL,
    IsYearStart          BIT            NOT NULL,
    IsYearEnd            BIT            NOT NULL
);
GO

CREATE UNIQUE INDEX IX_DimDate_Date
    ON dbo.DimDate([Date]);
GO

CREATE INDEX IX_DimDate_YearMonth
    ON dbo.DimDate(YearNumber, MonthNumber);
GO

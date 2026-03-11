USE CorpCore_DW;
GO

SET NOCOUNT ON;

DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate   DATE = '2030-12-31';

IF @StartDate > @EndDate
BEGIN
    THROW 50001, 'Start date cannot be greater than end date.', 1;
END;

;WITH DateSeries AS
(
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM DateSeries
    WHERE [Date] < @EndDate
)
INSERT INTO dbo.DimDate
(
    DateKey,
    [Date],
    DayNumberOfMonth,
    DayName,
    DayOfWeekNumber,
    DayOfYearNumber,
    WeekOfYearNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    QuarterName,
    YearNumber,
    YearMonth,
    MonthYearLabel,
    IsWeekend,
    IsMonthStart,
    IsMonthEnd,
    IsQuarterStart,
    IsQuarterEnd,
    IsYearStart,
    IsYearEnd
)
SELECT
    CAST(CONVERT(CHAR(8), [Date], 112) AS INT)                                     AS DateKey,
    [Date]                                                                          AS [Date],
    DATEPART(DAY, [Date])                                                           AS DayNumberOfMonth,
    DATENAME(WEEKDAY, [Date])                                                       AS DayName,
    DATEPART(WEEKDAY, [Date])                                                       AS DayOfWeekNumber,
    DATEPART(DAYOFYEAR, [Date])                                                     AS DayOfYearNumber,
    DATEPART(ISO_WEEK, [Date])                                                      AS WeekOfYearNumber,
    DATEPART(MONTH, [Date])                                                         AS MonthNumber,
    DATENAME(MONTH, [Date])                                                         AS MonthName,
    DATEPART(QUARTER, [Date])                                                       AS QuarterNumber,
    CONCAT('Q', DATEPART(QUARTER, [Date]))                                          AS QuarterName,
    DATEPART(YEAR, [Date])                                                          AS YearNumber,
    CONVERT(CHAR(7), [Date], 126)                                                   AS YearMonth,
    CONCAT(LEFT(DATENAME(MONTH, [Date]), 3), ' ', DATEPART(YEAR, [Date]))          AS MonthYearLabel,
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (1, 7) THEN 1 ELSE 0 END                AS IsWeekend,
    CASE WHEN [Date] = DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) THEN 1 ELSE 0 END AS IsMonthStart,
    CASE WHEN [Date] = EOMONTH([Date]) THEN 1 ELSE 0 END                            AS IsMonthEnd,
    CASE WHEN [Date] = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [Date]), 0) THEN 1 ELSE 0 END AS IsQuarterStart,
    CASE WHEN [Date] = DATEADD(DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, [Date]) + 1, 0)) THEN 1 ELSE 0 END AS IsQuarterEnd,
    CASE WHEN [Date] = DATEFROMPARTS(YEAR([Date]), 1, 1) THEN 1 ELSE 0 END         AS IsYearStart,
    CASE WHEN [Date] = DATEFROMPARTS(YEAR([Date]), 12, 31) THEN 1 ELSE 0 END       AS IsYearEnd
FROM DateSeries
OPTION (MAXRECURSION 0);
GO

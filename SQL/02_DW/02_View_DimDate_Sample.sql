USE CorpCore_DW;
GO

SELECT TOP 20 *
FROM dbo.DimDate
ORDER BY [Date];

SELECT TOP 20 *
FROM dbo.DimDate
ORDER BY [Date] DESC;

SELECT 
    MIN([Date]) AS MinDate,
    MAX([Date]) AS MaxDate,
    COUNT(*)    AS TotalRows
FROM dbo.DimDate;
GO

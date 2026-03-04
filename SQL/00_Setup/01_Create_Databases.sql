-- =============================================
-- Canada National Enterprise BI
-- Database & Schema Setup
-- =============================================

-- Create OLTP Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CorpCore_OLTP')
BEGIN
    CREATE DATABASE CorpCore_OLTP;
END
GO

-- Create DW Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CorpCore_DW')
BEGIN
    CREATE DATABASE CorpCore_DW;
END
GO

-- Create OLTP Schema
USE CorpCore_OLTP;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'oltp')
BEGIN
    EXEC('CREATE SCHEMA oltp');
END
GO

-- Create DW Schemas
USE CorpCore_DW;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC('CREATE SCHEMA dw');
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sec')
BEGIN
    EXEC('CREATE SCHEMA sec');
END
GO
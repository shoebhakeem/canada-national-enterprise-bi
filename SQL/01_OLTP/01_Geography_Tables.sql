USE CorpCore_OLTP;
GO

IF OBJECT_ID('oltp.Branches','U') IS NOT NULL DROP TABLE oltp.Branches;
IF OBJECT_ID('oltp.Cities','U')   IS NOT NULL DROP TABLE oltp.Cities;
IF OBJECT_ID('oltp.Provinces','U') IS NOT NULL DROP TABLE oltp.Provinces;
GO

CREATE TABLE oltp.Provinces (
    ProvinceID   INT         NOT NULL PRIMARY KEY,
    ProvinceCode NVARCHAR(2) NOT NULL UNIQUE,
    ProvinceName NVARCHAR(100) NOT NULL,
    IsActive     BIT NOT NULL CONSTRAINT DF_Provinces_IsActive DEFAULT(1)
);

CREATE TABLE oltp.Cities (
    CityID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CityName     NVARCHAR(150) NOT NULL,
    ProvinceID   INT NOT NULL,
    IsMajorCity  BIT NOT NULL CONSTRAINT DF_Cities_IsMajorCity DEFAULT(1),
    IsActive     BIT NOT NULL CONSTRAINT DF_Cities_IsActive DEFAULT(1),
    CONSTRAINT FK_Cities_Province FOREIGN KEY (ProvinceID)
        REFERENCES oltp.Provinces(ProvinceID)
);

CREATE TABLE oltp.Branches (
    BranchID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    BranchName   NVARCHAR(150) NOT NULL,
    CityID       INT NOT NULL,
    OpeningDate  DATE NULL,
    IsActive     BIT NOT NULL CONSTRAINT DF_Branches_IsActive DEFAULT(1),
    CONSTRAINT FK_Branches_City FOREIGN KEY (CityID)
        REFERENCES oltp.Cities(CityID)
);
GO
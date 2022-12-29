CREATE TABLE [Stock History] (
[CompanyID] int primary key,
[Stock Value] MONEY,
[Date] DATE
)

CREATE TABLE [Companies] (
[CompanyID] int primary key,
[Company Name] NVARCHAR,
Country NVARCHAR,
CategoryID int
)

CREATE TABLE [Category] (
CategoryID int primary key,
[Category Name] NVARCHAR
)


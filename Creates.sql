--CREATE TABLE [Stock History] (
--[CompanyID] int primary key,
--[Stock Value] MONEY,
--[Date] DATE
--)
----------------to bedzie w inicie

CREATE table Transactions(
TranslactionID int primary key,
CompanyID int,
UserID int,
[Date] Date,
Volumes int,

)

CREATE table Buy(
[BuyingPrice] MONEY,
TranslactionID int primary key,

)

CREATE table Sell(
[SellingPrice] MONEY,
TranslactionID int primary key,
)
-------------------------------------------------do dziedziczenia

CREATE TABLE [Companies] (
[CompanyID] nvarchar(5) primary key,
[Company Name] NVARCHAR,
Country NVARCHAR,
CategoryID int
)

CREATE TABLE [Category] (
CategoryID int primary key,
[Category Name] NVARCHAR
)
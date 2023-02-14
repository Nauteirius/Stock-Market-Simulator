IF OBJECT_ID('BuyOrders') IS NOT NULL
	DROP TABLE BuyOrders

CREATE TABLE BuyOrders(
	OrderID INT IDENTITY(1, 1) PRIMARY KEY,
	BuyerID NVARCHAR(11),
	Symbol NVARCHAR(4),
	Amount INT,
	MoneySpent MONEY,
	TotalDeposit MONEY,
	MaxPrice MONEY
)

IF OBJECT_ID('SellOrders') IS NOT NULL
	DROP TABLE SellOrders

CREATE TABLE SellOrders(
	OrderID INT IDENTITY(1, 1) PRIMARY KEY,
	SellerID NVARCHAR(11),
	Symbol NVARCHAR(4),
	Amount INT,
	Price MONEY
)

IF OBJECT_ID('Users') IS NOT NULL
	DROP TABLE Users

CREATE TABLE Users(
	UserID NVARCHAR(11) PRIMARY KEY,
	Balance MONEY,
	Sex NVARCHAR(1),
	BirthDay DATE
)

IF OBJECT_ID('Passwords') IS NOT NULL
	DROP TABLE Passwords

CREATE TABLE Passwords(
	UserID NVARCHAR(11) PRIMARY KEY
,
	[Password] NVARCHAR(MAX)
)

IF OBJECT_ID('UserStocks') IS NOT NULL
	DROP TABLE UserStocks

CREATE TABLE UserStocks(
	UserID NVARCHAR(11),
	Symbol NVARCHAR(4),
	Amount INT,
	PRIMARY KEY(UserID, Symbol)
)

IF OBJECT_ID('Symbols') IS NOT NULL
	DROP TABLE Symbols

CREATE TABLE Symbols(
	Symbol NVARCHAR(4) PRIMARY KEY,
)

IF OBJECT_ID('StockHistory') IS NOT NULL
	DROP TABLE StockHistory

CREATE TABLE StockHistory(
	[Date] DATE,
	Symbol NVARCHAR(4),
	[Open] MONEY,
	[High] MONEY,
	[Low] MONEY,
	[Close] MONEY,
	Volume INT,
	PRIMARY KEY([Date], Symbol)
)
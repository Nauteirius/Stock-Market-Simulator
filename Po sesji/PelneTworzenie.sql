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
GO

IF OBJECT_ID('TransactionsHistory') IS NOT NULL
	DROP TABLE TransactionsHistory

CREATE TABLE TransactionsHistory(
	TransactionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Date] DATE NOT NULL,
	SellerID NVARCHAR(11) NOT NULL,
	BuyerID NVARCHAR(11) NOT NULL,
	Symbol NVARCHAR(4) NOT NULL,
	Amount INT NOT NULL,
	SellPrice MONEY NOT NULL,
	BuyerMaxPrice MONEY NOT NULL
)
GO

--Funkcje

IF OBJECT_ID('hasEnoughMoney') IS NOT NULL
	DROP FUNCTION hasEnoughMoney
GO

CREATE FUNCTION hasEnoughMoney(
	@userID NVARCHAR(11),
	@money MONEY
)
RETURNS BIT
AS
BEGIN
	DECLARE @returnBit BIT

	IF @money > (select Balance from Users where UserId=@userID)
		SET @returnBit = 0
	ELSE
		SET @returnBit = 1

	RETURN @returnBit
END
GO

IF OBJECT_ID('hasEnoughStockActions') IS NOT NULL
	DROP FUNCTION hasEnoughStockActions
GO

CREATE FUNCTION hasEnoughStockActions(
	@userID NVARCHAR(11),
	@symbol NVARCHAR(4),
	@amount INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @returnBit BIT
	IF NOT EXISTS (SELECT * FROM UserStocks WHERE UserID=@userID AND Symbol=@symbol)
		SET @returnBit = 0
	ELSE IF (SELECT Amount FROM UserStocks WHERE UserID=@userID AND Symbol=@symbol) < @amount
		SET @returnBit = 0
	ELSE
		SET @returnBit = 1

	RETURN @returnBit
END
GO

--Procedury

IF OBJECT_ID('addStocksToUser') IS NOT NULL
	DROP PROCEDURE addStocksToUser
GO

CREATE PROCEDURE addStocksToUser(
	@userID NVARCHAR(11),
	@symbol NVARCHAR(4),
	@amount INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM UserStocks WHERE UserID = @userID AND Symbol = @symbol)
	BEGIN
		INSERT INTO UserStocks
		VALUES (@userID, @symbol, @amount)
	END
	ELSE
	BEGIN
		UPDATE UserStocks
		SET Amount = Amount + @amount
		WHERE UserID = @userID AND Symbol = @symbol
	END
END
GO

IF OBJECT_ID('removeStocksFromUser') IS NOT NULL
	DROP PROCEDURE removeStocksFromUser
GO

CREATE PROCEDURE removeStocksFromUser(
	@userID NVARCHAR(11),
	@symbol NVARCHAR(4),
	@amount INT
)
AS
BEGIN
	IF EXISTS (SELECT * FROM UserStocks WHERE UserID=@userID AND Symbol=@symbol)
	BEGIN
		IF (SELECT Amount FROM UserStocks WHERE UserID=@userID AND Symbol=@symbol) >= @amount
		BEGIN
			UPDATE UserStocks
			SET Amount = Amount - @amount
			WHERE UserID=@userID AND Symbol=@symbol
		END
		ELSE
			PRINT 'Podany u¿ytkownik o ID: ' + @userID + ' posiada mniej akcji ' + @symbol + ' ni¿ ' + CONVERT(VARCHAR, @amount)
	END
	ELSE
		PRINT 'Podany u¿ytkownik o ID: ' + @userID + ' nie posiada akcji ' + @symbol 
END
GO

IF OBJECT_ID('Buy') IS NOT NULL
	DROP PROCEDURE Buy
GO

CREATE PROCEDURE Buy(
	@buyerID NVARCHAR(11),
	@symbol NVARCHAR(4),
	@amount INT,
	@maxPrice MONEY
)
AS
BEGIN
	DECLARE @moneyToDeposit MONEY
	SET @moneyToDeposit = @amount * @maxPrice

	IF dbo.hasEnoughMoney(@buyerID, @moneyToDeposit) = 0
	BEGIN
		PRINT 'U¿ytkownik ' + @buyerID + ' nie posiada wystarczaj¹cej iloœci pieniêdzy by wykonaæ kupno przy tych danych'
		RETURN
	END

	UPDATE Users
	SET Balance = Balance - @moneyToDeposit
	WHERE UserID = @buyerID

	DECLARE @sellID INT
	DECLARE @sellerID NVARCHAR(11)
	DECLARE @amountInSell INT
	DECLARE @sellPrice MONEY

	DECLARE matchingSellOrders CURSOR FOR
	SELECT OrderID, SellerID, Amount, Price FROM SellOrders 
	WHERE Symbol=@symbol AND Price <= @maxPrice
	ORDER BY Price DESC

	OPEN matchingSellOrders

	FETCH NEXT FROM matchingSellOrders INTO @sellID, @sellerID, @amountInSell, @sellPrice

	WHILE @@FETCH_STATUS = 0 AND @amount != 0
	BEGIN
		IF @amount > @amountInSell
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amountInSell, @sellPrice, @maxPrice)

			SET @amount = @amount - @amountInSell
			SET @amountInSell = 0
		END
		ELSE IF @amount < @amountInSell
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amount, @sellPrice, @maxPrice)

			SET @amountInSell = @amountInSell - @amount
			SET @amount = 0
		END
		ELSE
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amount, @sellPrice, @maxPrice)
			
			SET @amount = 0
			SET @amountInSell = 0
		END

		UPDATE SellOrders
		SET Amount = @amountInSell
		WHERE OrderID = @sellID

		FETCH NEXT FROM matchingSellOrders INTO @sellID, @sellerID, @amountInSell, @sellPrice
	END
	
	CLOSE matchingSellOrders
	DEALLOCATE matchingSellOrders

	IF @amount != 0
	BEGIN
		INSERT INTO BuyOrders
		VALUES (@buyerID, @symbol, @amount, 0, 0, @maxPrice)
	END
END
GO

IF OBJECT_ID('sell') IS NOT NULL
	DROP PROCEDURE sell
GO

CREATE PROCEDURE sell(
	@sellerID NVARCHAR(11),
	@symbol NVARCHAR(4),
	@amount INT,
	@sellPrice MONEY
)
AS
BEGIN
	IF dbo.hasEnoughStockActions(@sellerID, @symbol, @amount) = 0
	BEGIN
		PRINT 'U¿ytkownik ' + @sellerID + ' nie posiada wystarczaj¹cej iloœci akcji ' + @symbol 
		RETURN
	END
	ELSE
	BEGIN
		UPDATE UserStocks
		SET Amount = Amount - @amount
		WHERE UserID=@sellerID AND Symbol=@symbol
	END

	DECLARE @buyID INT
	DECLARE @buyerID NVARCHAR(11)
	DECLARE @amountInBuy INT
	DECLARE @buyerMaxPrice MONEY

	DECLARE matchingBuyOrders CURSOR FOR
	SELECT OrderID, BuyerID, Amount, MaxPrice FROM BuyOrders 
	WHERE Symbol=@symbol AND @sellPrice <= MaxPrice

	OPEN matchingBuyOrders

	FETCH NEXT FROM matchingBuyOrders INTO @buyID, @buyerID, @amountInBuy, @buyerMaxPrice

	WHILE @@FETCH_STATUS = 0 AND @amount != 0
	BEGIN
		IF @amount > @amountInBuy
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amountInBuy, @sellPrice, @buyerMaxPrice)

			SET @amount = @amount - @amountInBuy
			SET @amountInBuy = 0
		END
		ELSE IF @amount < @amountInBuy
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amount, @sellPrice, @buyerMaxPrice)

			SET @amountInBuy = @amountInBuy - @amount
			SET @amount = 0
		END
		ELSE
		BEGIN
			INSERT INTO TransactionsHistory
			VALUES (GETDATE(), @sellerID, @buyerID, @symbol, @amount, @sellPrice, @buyerMaxPrice)
			
			SET @amount = 0
			SET @amountInBuy = 0
		END

		UPDATE BuyOrders
		SET Amount = @amountInBuy
		WHERE OrderID = @buyID

		FETCH NEXT FROM matchingBuyOrders INTO @buyID, @buyerID, @amountInBuy, @buyerMaxPrice
	END
	
	CLOSE matchingBuyOrders
	DEALLOCATE matchingBuyOrders

	IF @amount != 0
	BEGIN
		INSERT INTO SellOrders
		VALUES (@sellerID, @symbol, @amount, @sellPrice)
	END
END
GO

--TWORZENIE TRIGGERÓW

IF OBJECT_ID('ReturnRestFromDepositedMoney') IS NOT NULL
	DROP TRIGGER ReturnRestFromDepositedMoney
GO

CREATE TRIGGER ReturnRestFromDepositedMoney
ON TransactionsHistory
AFTER INSERT
AS
BEGIN
	DECLARE @buyerID NVARCHAR(11), @amount INT, @sellPrice MONEY, @buyerMaxPrice MONEY

	SELECT @buyerID = BuyerID, @amount = Amount,
		@sellPrice = SellPrice, @buyerMaxPrice = BuyerMaxPrice
	FROM inserted

	UPDATE Users
	SET Balance = Balance + (@amount * (@buyerMaxPrice-@sellPrice))
	WHERE UserID = @buyerID
END
GO

IF OBJECT_ID('TransferSaleMoney') IS NOT NULL
	DROP TRIGGER TransferSaleMoney
GO

CREATE TRIGGER TransferSaleMoney
ON TransactionsHistory
AFTER INSERT
AS
BEGIN
	DECLARE @sellerID NVARCHAR(11), @amount INT, @sellPrice MONEY

	SELECT @sellerID = SellerID, @amount = Amount, @sellPrice = SellPrice
	FROM inserted

	UPDATE Users
	SET Balance = Balance + (@amount * @sellPrice)
	WHERE UserID = @sellerID
END
GO

IF OBJECT_ID('UpdateStockHistory') IS NOT NULL
	DROP TRIGGER UpdateStockHistory
GO

CREATE TRIGGER UpdateStockHistory
ON TransactionsHistory
AFTER INSERT
AS
BEGIN
	DECLARE @date DATE, @symbol NVARCHAR(4), @sellPrice MONEY

	SELECT @date = [Date], @symbol = Symbol, @sellPrice = SellPrice FROM inserted

	IF EXISTS( SELECT * FROM StockHistory WHERE [Date] = @date AND Symbol = @symbol )
	BEGIN
		DECLARE @low MONEY, @high MONEY

		SELECT @low = [Low], @high = [High] FROM StockHistory
		WHERE [Date] = @date AND Symbol = @symbol
		
		IF @low > @sellPrice
			SET @low = @sellPrice

		IF @high < @sellPrice
			SET @high = @sellPrice

		UPDATE StockHistory
		SET [Low] = @low, [High] = @high
		WHERE [Date] = @date AND Symbol = @symbol
	END
	ELSE
	BEGIN
		INSERT INTO StockHistory
		VALUES (@date, @symbol, @sellPrice, @sellPrice, @sellPrice, @sellPrice, 0)
	END
END
GO

IF OBJECT_ID('TransferSymbols') IS NOT NULL
	DROP TRIGGER TransferSymbols
GO

CREATE TRIGGER TransferSymbols
ON TransactionsHistory
AFTER INSERT
AS
BEGIN
	DECLARE @buyerID NVARCHAR(11), @symbol NVARCHAR(4), @amount INT

	SELECT @buyerID = BuyerID, @symbol = Symbol, @amount = Amount
	FROM inserted

	EXECUTE dbo.addStocksToUser @buyerID, @symbol, @amount
END
GO
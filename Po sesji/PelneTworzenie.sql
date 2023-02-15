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

--TWORZENIE TRIGGERÓW

IF OBJECT_ID('transferRestOfDepositedMoneyAfterFullBuy') IS NOT NULL
	DROP TRIGGER transferRestOfDepositedMoneyAfterFullBuy
GO

CREATE TRIGGER transferRestOfDepositedMoneyAfterFullBuy
ON BuyOrders
FOR UPDATE
AS
BEGIN
	DECLARE @newAmount INT, @moneySpent MONEY, @moneyDeposited MONEY, @buyerID NVARCHAR(11), @buyID INT
	SELECT @newAmount = Amount, @moneySpent = MoneySpent, @moneyDeposited = TotalDeposit, @buyerID = BuyerID, @buyID = OrderID FROM inserted

	IF @newAmount = 0
	BEGIN
		UPDATE Users
		SET Balance = Balance + (@moneyDeposited - @moneySpent)
		WHERE UserID = @buyerID

		DELETE BuyOrders
		WHERE OrderID = @buyID
	END
END
GO

IF OBJECT_ID('transferMoneyAfterSaleAndDeleteEmptyOffers') IS NOT NULL
	DROP TRIGGER transferMoneyAfterSaleAndDeleteEmptyOffers
GO

CREATE TRIGGER transferMoneyAfterSaleAndDeleteEmptyOffers
ON SellOrders
FOR UPDATE
AS
BEGIN
	DECLARE @OldAmount INT, @NewAmount INT, @sellerID NVARCHAR(11), @price MONEY, @sellID INT

    SELECT @OldAmount = Amount FROM deleted
    SELECT @NewAmount = Amount FROM inserted
	SELECT @price = Price FROM inserted
	SELECT @sellerID = SellerID FROM inserted
	SELECT @sellID = OrderID FROM inserted

	UPDATE Users
	SET Balance = Balance + ((@OldAmount-@NewAmount) * @price)
	WHERE UserID = @sellerID

	IF @NewAmount = 0
		DELETE SellOrders
		WHERE OrderID = @sellID
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
	drop procedure Buy
GO

Create procedure Buy
(
	@buyerid nvarchar(11),
	@symbol nvarchar(4),
	@amount int,
	@max_price money
)
as
begin
	if @max_price * @amount > (select Balance from Users where UserId=@buyerid)
	begin
		print('nie da sie')
		return
	end
	declare @money_spent money
	set @money_spent = 0 
	declare @frozen money
	set @frozen = @max_price * @amount

	update Users
	set Balance = Balance - @frozen
	where UserID = @buyerid

	DECLARE @amountInSell INT
	DECLARE @priceInSell MONEY
	DECLARE @sellID INT

	while 0<1
	begin
		if (select count(*) from sellOrders where Symbol=@symbol and Price<=@max_price) = 0
		begin
			insert into BuyOrders(BuyerID, Symbol, Amount, MoneySpent, TotalDeposit)
			values (@buyerid, @symbol, @amount, @money_spent, @frozen)
			break
		end

		SELECT @sellID=OrderID, @amountInSell=Amount, @priceInSell=Price FROM SellOrders WHERE Symbol=@symbol and Price<=@max_price

		if @amount > (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
		begin
			set @amount = @amount - (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amountInSell

			delete from SellOrders where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)	
		end
		else if @amount < (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
		begin
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amount

			update SellOrders
			set Amount = Amount - @amount
			where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)

			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			break
		end
		else
		begin
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amount

			delete from SellOrders where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			break
		end
	end
end
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
	IF NOT EXISTS (SELECT * FROM UserStocks WHERE UserID=@sellerID AND Symbol=@symbol)
	BEGIN
		PRINT 'U¿ytkownik ' + @sellerID + ' nie posiada akcji ' + @symbol 
		BREAK
	END

	IF (SELECT Amount FROM UserStocks WHERE UserID=@sellerID AND Symbol=@symbol) < @amount
	BEGIN
		PRINT 'U¿ytkownik ' + @sellerID + ' posiada mniej akcji ' + @symbol + ' ni¿ ' + CONVERT(VARCHAR, @amount)
		BREAK
	END
	ELSE
	BEGIN
		UPDATE UserStocks
		SET Amount = Amount - @amount
		WHERE UserID=@sellerID AND Symbol=@symbol
	END

	DECLARE @buyID INT
	DECLARE @amountInBuy INT

	DECLARE matchingBuyOrders CURSOR FOR
	SELECT OrderID, Amount FROM BuyOrders 
	WHERE Symbol=@symbol AND @sellPrice <= MaxPrice

	OPEN matchingBuyOrders

	FETCH NEXT FROM matchingBuyOrders INTO @buyID, @amountInBuy

	WHILE @@FETCH_STATUS = 0 AND @amount != 0
	BEGIN
		IF @amount > @amountInBuy
		BEGIN
			SET @amount = @amount - @amountInBuy
			SET @amountInBuy = 0
		END
		ELSE IF @amount < @amountInBuy
		BEGIN
			SET @amountInBuy = @amountInBuy - @amount
			SET @amount = 0
		END
		ELSE
		BEGIN
			SET @amount = 0
			SET @amountInBuy = 0
		END

		UPDATE BuyOrders
		SET Amount = @amountInBuy
		WHERE OrderID = @buyID

		FETCH NEXT FROM matchingBuyOrders INTO @buyID, @amountInBuy
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
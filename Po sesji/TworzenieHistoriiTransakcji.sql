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
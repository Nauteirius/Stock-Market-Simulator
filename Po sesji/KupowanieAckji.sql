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

CREATE PROCEDURE buy(
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
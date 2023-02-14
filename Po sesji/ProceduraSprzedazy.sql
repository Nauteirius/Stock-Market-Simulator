/*create procedure @idsprzedawcy,  @symbol, @ilosc sprzedajemy(trigger),@cena_sprzedajemy,
czy posiada akcje ^ posiada akcje w wystarczjacej ilosci
...


if(liczba akcji = ilosc akcji:
	nie ma juz tej akcji
else:
	update liczba akcji-ilosc

while(
select from BuyOrders top 1 buyorder where symbol=@symbol and max_price<=@cena_sprzedajemy
ilosc>@ilosc
break
..
ilosc<@ilosc
...
ilosc=ilosc
break
)
if(@ilosc>0):
	insert sellorders*/

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
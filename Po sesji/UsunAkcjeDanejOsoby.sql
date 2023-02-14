/*
Dostaje @userID, @symbol, @amount

Sprawdzam czy istnieje wpis z @userID oraz @symbol
	Jeœli TAK: sprawdzam czy Amount >= @amount
		Jeœli TAK: Dokonuje odjêcia
		Jeœli NIE: Mówi, ¿e iloœæ akcji do usuniêcie przekracza posiadan¹ iloœæ
	Jeœli NIE: Wypisuje, ¿e u¿ytkownik nie posiada danej akcji
*/
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
/*create procedure addOwnershipofStocks
@idtejosoby
@symbol
@amounth

if(select @idtejosoby where simbol - simobs is null)
insert into ownedsimbol
@idtejosoby, @symbol, @amounth
else
update owned simbol
where id-@idtejosoby and symbol=@symbol
amounth=amouth+@amouth*/
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
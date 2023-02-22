CREATE TRIGGER DeleteEmptyUserStock
ON UserStocks
FOR UPDATE
AS
BEGIN
	DECLARE @userID NVARCHAR(11), @symbol NVARCHAR(4), @amount INT

	SELECT @userID = UserID, @symbol = Symbol, @amount = Amount FROM inserted

	IF @amount = 0
		DELETE FROM UserStocks
		WHERE UserID = @userID AND Symbol = @symbol
END
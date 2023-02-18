CREATE PROCEDURE DepositMoney(
	@userID NVARCHAR(11),
	@money MONEY
)
AS
BEGIN
	IF dbo.HasUser(@userID) = 1
		PRINT 'Nie istnieje taki użytkownik'
	ELSE
	BEGIN
		UPDATE Users
		SET Balance = Balance + @money
		WHERE UserID = @userID
	END
END
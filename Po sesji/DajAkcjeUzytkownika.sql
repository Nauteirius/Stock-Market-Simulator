CREATE FUNCTION GetSpecificUserStocks(
	@userID NVARCHAR(11)
)
RETURNS TABLE
AS
RETURN
	SELECT * FROM UserStocks
	WHERE UserID = @userID
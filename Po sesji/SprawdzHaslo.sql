CREATE FUNCTION CheckPassword(
	@password nvarchar(MAX)
)
RETURNS bit
AS
BEGIN
	DECLARE @return_bit AS bit
	
	IF @password like '%[0-9]%' and @password like '%[A-Z]%' and @password like '%[a-z]%' and @password like '%[!@#$%a^&*()-_+=.,;:"`~]%' and len(@password) >= 8 --co z '
		SET @return_bit = 1
	ELSE
		SET @return_bit = 0

	RETURN @return_bit
END
GO
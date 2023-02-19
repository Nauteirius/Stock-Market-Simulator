CREATE FUNCTION ReadBirthDay(
	@pesel nvarchar(11)
)
RETURNS date
AS
BEGIN
	DECLARE @return_date AS date

	DECLARE @birthYear AS int
	SET @birthYear = SUBSTRING(@pesel, 1, 2)
	DECLARE @birthMounth AS int
	SET @birthMounth = SUBSTRING(@pesel, 3, 2)
	DECLARE @birthDay AS int
	SET @birthDay = SUBSTRING(@pesel, 5, 2)

	IF @birthMounth>20
		BEGIN
			SET @birthMounth = @birthMounth-20;
			SET @birthYear = @birthYear+2000;
		END
	ELSE
		SET @birthYear = @birthYear + 1900
		
	SET @return_date = DATEFROMPARTS(@birthYear, @birthMounth, @birthDay)

	RETURN @return_date
END
GO
CREATE FUNCTION ReadSex(
	@pesel nvarchar(11)
)
RETURNS nvarchar(1)
AS
BEGIN
	DECLARE @return_sex AS nvarchar(1)

	DECLARE @sexNumber AS int
	SET @sexNumber = SUBSTRING(@pesel, 10, 1)
		
	IF (@sexNumber % 2) = 0
		SET @return_sex = 'W'
	ELSE
		SET @return_sex = 'M'

	RETURN @return_sex
END
GO
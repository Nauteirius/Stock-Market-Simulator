CREATE FUNCTION CheckPesel(
	@pesel nvarchar(11)
)
RETURNS bit
AS
BEGIN
	DECLARE @return_bit AS bit
	--DECLARE @digit AS int
	DECLARE @control_sum AS int
	SET @control_sum = 0

	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 1, 1)*1)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 2, 1)*3)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 3, 1)*7)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 4, 1)*9)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 5, 1)*1)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 6, 1)*3)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 7, 1)*7)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 8, 1)*9)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 9, 1)*1)
	SET @control_sum = @control_sum + (SUBSTRING(@pesel, 10, 1)*3)

	IF (10-(@control_sum % 10)) = SUBSTRING(@pesel, 11, 1)
		SET @return_bit = 1
	ELSE
		SET @return_bit = 0

	RETURN @return_bit
END
GO
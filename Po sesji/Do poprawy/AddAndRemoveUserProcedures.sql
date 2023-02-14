CREATE PROCEDURE dodaj_uzytkownika(
	@pesel nvarchar(11),
	@password nvarchar(60)
)
AS
BEGIN
	IF dbo.check_correctness_of_pesel(@pesel) = 1
		BEGIN
			INSERT INTO Users
			VALUES (@pesel, @password)
		END
	ELSE
		PRINT 'Pesel jest niepoprawny. Sprawdz czy dobrze zostal przepisany'
END
GO

CREATE PROCEDURE usun_uzytkownika(
	@pesel nvarchar(11)
)
AS
BEGIN
	IF EXISTS(SELECT * FROM Users WHERE [User ID]=@pesel)
		DELETE FROM Users WHERE [User ID]=@pesel
	ELSE
		PRINT 'Nie ma takiego pesulu w bazie zarejestrowanych. Sprawdz czy pesel jest dobrze przepisany'
END
GO
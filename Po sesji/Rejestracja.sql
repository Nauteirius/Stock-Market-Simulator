CREATE PROCEDURE [dbo].[Register](
	@pesel nvarchar(11), @password nvarchar(MAX)
)
AS
BEGIN
	IF dbo.CheckPesel(@pesel) = 1 and dbo.CheckPassword(@password) = 1
	BEGIN
		INSERT INTO Users (UserID, Balance, Sex, BirthDay)
		VALUES (@pesel, 0, dbo.ReadSex(@pesel), dbo.ReadBirthDay(@pesel))
	
		INSERT INTO Passwords (UserID, Password)
		VALUES (@pesel, @password)
	END
	ELSE
		PRINT 'Cos nie tak z danymi'
END
GO
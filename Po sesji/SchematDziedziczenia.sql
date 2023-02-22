CREATE TABLE RegisteredUsers(
	UserID NVARCHAR(11),
	Password NVARCHAR(MAX)
)
GO

CREATE TABLE DeletedUsers(
	UserID NVARCHAR(11),
	DeletionDate DATE
)
GO

CREATE TRIGGER MigrateRegisteredUserToDeletedUser
ON RegisteredUsers
FOR DELETE
AS
BEGIN
	DECLARE @userID NVARCHAR(11)

	SELECT @userID = UserID FROM deleted

	INSERT INTO DeletedUsers
	VALUES(@userID, GETDATE())
END
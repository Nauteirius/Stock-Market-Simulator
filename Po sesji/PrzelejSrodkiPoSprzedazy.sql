DROP TRIGGER transferMoneyAfterSaleAndDeleteEmptyOffers
GO

CREATE TRIGGER transferMoneyAfterSaleAndDeleteEmptyOffers
ON SellOrders
FOR UPDATE
AS
BEGIN
	DECLARE @OldAmount INT, @NewAmount INT, @sellerID NVARCHAR(11), @price MONEY, @sellID INT

    SELECT @OldAmount = Amount FROM deleted
    SELECT @NewAmount = Amount FROM inserted
	SELECT @price = Price FROM inserted
	SELECT @sellerID = SellerID FROM inserted
	SELECT @sellID = OrderID FROM inserted

	UPDATE Users
	SET Balance = Balance + ((@OldAmount-@NewAmount) * @price)
	WHERE UserID = @sellerID

	IF @NewAmount = 0
		DELETE SellOrders
		WHERE OrderID = @sellID
END
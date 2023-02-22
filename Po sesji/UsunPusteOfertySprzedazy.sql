CREATE TRIGGER DeleteEmptySellOrder
ON SellOrders
FOR UPDATE
AS
BEGIN
	DECLARE @sellID INT, @amount INT

	SELECT @sellID = OrderID, @amount = Amount FROM inserted

	IF @amount = 0
		DELETE FROM SellOrders
		WHERE OrderID = @sellID
END
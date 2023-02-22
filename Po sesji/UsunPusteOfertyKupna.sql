CREATE TRIGGER DeleteEmptyBuyOrder
ON BuyOrders
FOR UPDATE
AS
BEGIN
	DECLARE @buyID INT, @amount INT

	SELECT @buyID = OrderID, @amount = Amount FROM inserted

	IF @amount = 0
		DELETE FROM BuyOrders
		WHERE OrderID = @buyID
END
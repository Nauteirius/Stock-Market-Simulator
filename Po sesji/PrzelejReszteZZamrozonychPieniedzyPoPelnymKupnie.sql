CREATE TRIGGER transferRestOfDepositedMoneyAfterFullBuy
ON BuyOrders
FOR UPDATE
AS
BEGIN
	DECLARE @newAmount INT, @moneySpent MONEY, @moneyDeposited MONEY, @buyerID NVARCHAR(11), @buyID INT
	SELECT @newAmount = Amount, @moneySpent = MoneySpent, @moneyDeposited = TotalDeposit, @buyerID = BuyerID, @buyID = OrderID FROM inserted

	IF @newAmount = 0
	BEGIN
		UPDATE Users
		SET Balance = Balance + (@moneyDeposited - @moneySpent)
		WHERE UserID = @buyerID

		DELETE BuyOrders
		WHERE OrderID = @buyID
	END
END
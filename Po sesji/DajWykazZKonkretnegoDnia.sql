CREATE FUNCTION GetStockMarketInSpecificDate(
	@date DATE
)
RETURNS TABLE
AS
RETURN
	SELECT * FROM StockHistory
	WHERE [Date] = @date
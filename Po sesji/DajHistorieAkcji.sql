CREATE FUNCTION GetSpecificStockHistory(
	@symbol NVARCHAR(4)
)
RETURNS TABLE
AS
RETURN
	SELECT * FROM StockHistory
	WHERE Symbol = @symbol
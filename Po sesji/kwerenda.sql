drop procedure Buy
GO
Create procedure Buy
(
	@buyerid nvarchar(11),
	@symbol nvarchar(4),
	@amount int,
	@max_price money
)
as
begin
	if @max_price * @amount > (select Balance from Users where UserId=@buyerid)
	begin
		print('nie da sie')
		return
	end
	declare @money_spent money
	set @money_spent = 0
	-- @amouth * @max_price >= budzet
	-- sumujemy ydane pieniadze na zakup akcji - kosztzlecenia
	--jak szystko zostalo kupione to byudzeto dodajemy artosc budzet-lpszy zlecenia 
	-- dla zamrozonych
	-- przenies srodki zamrozone


	--szukamy wszystkich ofert sprzedazy
	--declare @minSellOrder table(id int, amount int, price money)

	--insert into @minSellOrder
	--values (0, 0, 
	declare @frozen money
	set @frozen = @max_price * @amount

	update Users
	set Balance = Balance - @frozen
	where UserID = @buyerid

	DECLARE @amountInSell INT
	DECLARE @priceInSell MONEY
	DECLARE @sellID INT

	while 0<1
	begin
		--insert into @minSellOrder
		--select top 1 OrderID, Amount, Price 
		--from sellOrders 
		--where Symbol=@symbol and Price<=@max_price 
		--order by Price ASC
	
		

		if (select count(*) from sellOrders where Symbol=@symbol and Price<=@max_price) = 0
		begin
			insert into BuyOrders(BuyerID, Symbol, Amount, MoneySpent, TotalDeposit)
			values (@buyerid, @symbol, @amount, @money_spent, @frozen)
			break
		end

		SELECT @sellID=OrderID, @amountInSell=Amount, @priceInSell=Price FROM SellOrders WHERE Symbol=@symbol and Price<=@max_price

		if @amount > (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
		begin
			set @amount = @amount - (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amountInSell

			delete from SellOrders where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)	
		end
		else if @amount < (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
		begin
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amount

			update SellOrders
			set Amount = Amount - @amount
			where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)

			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			break
		end
		else
		begin
			EXECUTE dbo.addStocksToUser @buyerid, @symbol, @amount

			delete from SellOrders where OrderID = (select top 1 OrderID from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			set @money_spent = @money_spent + (select top 1 Price from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC) * (select top 1 Amount from sellOrders where Symbol=@symbol and Price<=@max_price order by Price ASC)
			break
		end
	end

	--@za
	--@amount Amount
	--@amount -= Amouth
	--delete
	--Usuamy ierz z sell orders
	--update Amouth=Amounth - @amouth
	--Amouth, @amounth
end

--szuka najmniejszej kupuje until kupilo szystkie zlecone V skonczyla sie akcja  tej cenie
	--jesli to pirsze transakcja zakonczyla sie sukcesem
	-- jesli to drugie repeat, jesli nie ma akcji <=max_price to tez sie zakonczeniem i dodaje reszte do buyorders
	
	--
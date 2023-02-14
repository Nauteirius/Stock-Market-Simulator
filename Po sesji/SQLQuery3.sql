drop table BuyOrders
create table BuyOrders(
	OrderID int identity(1, 1) primary key not null,
	BuyerID nchar(11)  not null, --foreign key references Users(UserID)
	Symbol nchar(4)  not null, --foreign key references Symbols(Symbol)
	Amount int not null,
	MoneySpent money not null,
	TotalDeposit money not null
)
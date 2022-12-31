/*
CREATE TABLE Users (
[User ID] nvarchar(11) primary key, --PESEL
Sex nvarchar(1),
Age int,
Balance money,
)

--if cyfra%2=1 -> 0 else 1 Sex check
-- z peselu wyciagnac date urodzenia i sprawdzic ie pelnych lat od tego czasu oplynelo


CREATE table Logins(
[UserID] int primary key,
Password nvarchar(30),
)
*/
CREATE PROCEDURE Register @pesel nvarchar(11), @password nvarchar(30)
AS
INSERT INTO Users ([User ID],Balance)
VALUES (@pesel,0); 
INSERT INTO Logins ([Password])
VALUES (@password); 
GO;

CREATE PROCEDURE [Deposit Money] @cash money, @pesel nvarchar(11)
AS
Update Users Set balance= balance + @money Where [User ID]=@pesel
GO;

CREATE PROCEDURE [Buy Stocks] @quantity int, @pesel nvarchar(11), @simb [nvarchar](10)
AS
Update Users Set balance= balance + @quantity*([Get Stock Price](@simb)) Where [User ID]=@pesel
Update [Stock History] Set Volumes = Volumes - @quantity where [Simbol] = @simb and [Date] between @TODAY and '2022-12-30'
GO;


CREATE FUNCTION [Get Stock Price]
    (
	    @simbol AS [nvarchar](10)
    )
RETURNS Money
AS
BEGIN
	RETURN Select [high] from [Stock Current] where [Simbol] = @simbol
END;





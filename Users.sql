CREATE TABLE Users (
[UserID] int primary key, --PESEL
Sex nvarchar(1),
Age int,
)

--if cyfra%2=1 -> 0 else 1 Sex check
-- z peselu wyciagnac date urodzenia i sprawdzic ie pelnych lat od tego czasu oplynelo


CREATE table Logins(
[UserID] int primary key,
Password nvarchar(30),
)

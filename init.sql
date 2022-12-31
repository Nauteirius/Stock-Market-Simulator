-- drop table for nvarchar watchlist if it exists
if(select(object_id('dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar'))) is not null
drop table dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
 
-- create table for watchlist
CREATE TABLE dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar(
   [Date] date,
   [Symbol] nvarchar(10),
   [Open] nvarchar(50) NULL,
   [High] nvarchar(50) NULL,
   [Low] nvarchar(50) NULL,
   [Close] nvarchar(50) NULL,
   [Volume] nvarchar(50) NULL
) 
GO
 
-- drop table for data typed watchlist if it exists
if(select(object_id('dbo.yahoo_prices_volumes_for_MSSQLTips'))) is not null
drop table dbo.yahoo_prices_volumes_for_MSSQLTips
CREATE TABLE [dbo].[yahoo_prices_volumes_for_MSSQLTips](
   [Date] [date] NULL,
   [Symbol] [nvarchar](10) NULL,
   [Open] [money] NULL,
   [High] [money] NULL,
   [Low] [money] NULL,
   [Close] [money] NULL,
   [Volume] [bigint] NULL
)
GO
 
---------------------------------------------------------------------------------------------------
 
-- for first symbol set
 
-- migrate csv file to nvarchar watchlist
truncate table dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
bulk insert dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
from 'D:\stu\iiis\bd\project\StockMarketSimulator\yahoo_prices_volumes_for_ExchangeSymbols_from_01012022_291222.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',  --CSV field delimiter
    rowterminator = '\n'
)
 
-- insert dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar into dbo.yahoo_prices_volumes_for_MSSQLTips
insert into dbo.yahoo_prices_volumes_for_MSSQLTips
select 
   [Date],
   [Symbol],
   [Open],
   [High],
   [Low],
   [Close],
   cast([Volume] as float) 
from dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
 
---------------------------------------------------------------------------------------------------
 /*
-- for second symbol set
 
-- migrate csv file to nvarchar watchlist
truncate table dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
bulk insert dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
from 'C:\python_programs_output\yahoo_prices_volumes_for_ExchangeSymbols_from_01012009_07102019_kzr_hci.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',  --CSV field delimiter
    rowterminator = '\n'
) 
 
--select count(*) from dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar ;select * from dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
 
-- insert dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar into -- dbo.yahoo_prices_volumes_for_MSSQLTips
insert into dbo.yahoo_prices_volumes_for_MSSQLTips
select 
   [Date],
   [Symbol],
   [Open],
   [High],
   [Low],
   [Close],
   cast([Volume] as float) 
from dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
 
---------------------------------------------------------------------------------------------------
 
-- for third symbol set
 
-- migrate csv file to nvarchar watchlist
truncate table dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
bulk insert dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar
from 'C:\python_programs_output\yahoo_prices_volumes_for_ExchangeSymbols_from_01012009_07102019_hcp_uwm.csv'
with
(
    firstrow = 2,
    fieldterminator = ',',  --CSV field delimiter
    rowterminator = '\n'
)
 
-- insert  dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar into dbo.yahoo_prices_volumes_for_MSSQLTips
insert into dbo.yahoo_prices_volumes_for_MSSQLTips
select 
   [Date],
   [Symbol],
   [Open],
   [High],
   [Low],
   [Close],
   cast([Volume] as float) 
from dbo.yahoo_prices_volumes_for_MSSQLTips_nvarchar */
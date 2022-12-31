
import pandas_datareader.data as web
import datetime

#read ticker symbols from a file to python list object named symbol
symbol = []
with open('D:\stu\iiis\\bd\project\StockMarketSimulator\StockMarketSimulator\simbolList.txt') as f:
    for line in f:
        symbol.append(line.strip())
f.close


#datetime is a Python module
#datetime.date is a data type within the datetime module

#the start expression is for January 1, 2009
start = datetime.date(2022,1,1)

#the end expression is for October 7, 2019
end = datetime.date(2022,12,1)

#path_out = 'c:/python_programs_output/'
path_out = 'D:/stu/iiis/bd/project/StockMarketSimulator/StockMarketSimulator'
file_out = 'yahoo_prices_volumes_for_ExchangeSymbols_from_01012022_291222.csv'

#loop through tickers in symbol list with i values of 0 through
#index for last list item

#if no historical data returned on any pass, try to get the ticker data again
#if destination file is open in Excel, close Excel and continue data collection
#quit retries to get historical data for a symbol after tenth retry

i=0  #pointer for symbol
j=0  #count for loop within symbol
while i<len(symbol):
    try:
        df = web.DataReader(symbol[i], 'yahoo', start, end)
        df.insert(0,'Symbol',symbol[i])
        df = df.drop(['Adj Close'], axis=1)
        print ("from after dr", i,j, symbol[i])

        if i == 0:
            df.to_csv(path_out+file_out)
        else:
            df.to_csv(path_out+file_out,mode = 'a',header=False)
        j=0
    except:
        print ("from except", i,j, symbol[i])
        if j <=9:
            print(i, symbol[i], j,"Eligible for retry")
            j = j+1
            continue
        if j == 10:
            j=0
            i=i+1
            continue
    i=i+1#-1 tab
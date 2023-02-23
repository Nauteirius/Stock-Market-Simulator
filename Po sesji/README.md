# Tabele:
1. BuyOrders
2. RegisteredUsers
3. SellOrders
4. StockHistory
5. Symbols
6. Users
7. UsersStocks
8. TransactionsHistory
9. DeletedUsers

# Triggery:
1. Oddawanie reszty z zamrożonych pieniędzy (StockHistory)
2. Przelanie pieniędzy za sprzedaż (StockHistory)
3. Aktualizacja StockHistory wskutek transakcji (StockHistory)
4. Dodanie akcji na konto kupującego (StockHistory)
5. Usun gdy ilość równa 0 (BuyOrders)
6. Usuń gdy ilość równa 0 (SellOrders)
7. Usuń gdy ilość równa 0 (UserActions)
8. Wpisywanie daty usunięcia konta do DeletedUsers po usunięciu z registeredUsers 

# Procedury
1. Zwiększanie ilości akcji użytkownika
2. Zmniejszanie ilości akcji użytkownika
3. Sprzedaż akcji
4. Kupno akcji
5. Rejestracja
6. Wplacanie pieniedzy na konto 
7. Usnięcie użykownika

# Funkcje i Widoki
1. Czytanie daty urodzenia
2. Czytanie płci
3. Sprawdzanie czy pesel poprawny
4. Pokazanie akcji konkretnego użytkownika
5. Widok giełdy z konkretnego dnia
6. Widok histori konkretnej akcji
7. Funkcja sprawdzający czy dany użytkownik posiada daną ilość akcji
8. Funkcja sprawdzająca czy dany użytkownik posiada daną kwotę
9. Czy użytkownik istnieje
10. Sprawdzanie czy hasło spełnia dane warunki
11. [ ] Wyznaczanie prawdopodobnej kwoty danej akcji
12. [ ] Wartość portfela użytkownika

# Co przenieść do całości
* [ ] Zmienić kolejność drop table by relacje kluczy obcych nie powodowaly bledow
* [ ] Dokumentacja 
* [ ] Usunąć open i close
* [ ] Usunąć totalDeposit oraz moneyspent. Tą rolę spełnia transactionHistory

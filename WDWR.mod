###########################################################
# WDWR 18042                                              #
# Planowanie produkcj w warunkach ryzyka.                 #
# MODEL                                                   #
# Autor: Jan Kumor                                        #
###########################################################

##########
# Zbiory #
##########
# Produkty
set PRODUCTS;
# Narzedzia
set TOOLS;
# Miesiące
set MONTHS ordered;

#############
# Parametry #
#############

# Liczba narzędzi
param toolCount {TOOLS} >= 1;

# Dochody ze sprzedazy [pln/szt]
param sellUnitProfit;
	
# Czasy produkcji [godz]
param productionTimes {TOOLS, PRODUCTS} >= 0;

# Ograniczenia rynkowe liczby sprzedawanych produktow [szt]
param salesMarketLimits {MONTHS, PRODUCTS} >= 0;
			
# Ograniczeine liczby magazynowanych produktów [szt]
param storageLimit {PRODUCTS} >= 0;

# Koszt magazynowania produktów [pln/szt per msc]
param storageUnitCost >= 0;

# Aktualny stan magazynowy [szt]
param startingStorage {PRODUCTS} >= 0;
	
# Pożądany stan magazynowy na koniec symulacji [szt]
param desiredEndStorage {PRODUCTS} >= 0;

# Liczba dni roboczych w miesiącu [d]
param workDaysPerMonth >= 0;

# Liczba zmian w ciągu jednego dnia roboczego
param shiftsPerDay >= 1;

# Długość zmiany [godz]
param shiftHours >= 8;

###########
# Zmienne #
###########
# Produkcja produktów w danym miesiącu
var produced {MONTHS, PRODUCTS} >= 0;

# Sprzedaż produktów w danym miesiącu
var sold {MONTHS,PRODUCTS} >= 0;

# Ilość produktów przekazanych do magazynu w danym miesiącu
var stored {m in MONTHS, p in PRODUCTS} = produced[m, p] - sold[m, p]; 

# Stan magazynowy na koniec danego miesiąca
var storage {m in MONTHS, p in PRODUCTS} =
	startingStorage[p] + sum {m2 in MONTHS: ord(m2) <= ord(m)} stored[m2, p];  

#######################
# Ograniczenia modelu #
#######################

# Ograniczenie rynkowe sprzedaży produktów
subject to MonthlySalesMarketLimit {m in MONTHS, p in PRODUCTS}:
	sold[m, p] <= salesMarketLimits[m, p];
# Ograniczenie magazynowe sprzedaży produktów
subject to MonthlySalesLimit1 {p in PRODUCTS}:
	sold[first(MONTHS), p] <= produced[first(MONTHS), p];
subject to MonthlySalesLimit2 {m in MONTHS, p in PRODUCTS: m != first(MONTHS)}:
	sold[m, p] <= produced [m, p] + storage[m, p];

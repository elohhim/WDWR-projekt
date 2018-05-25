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
set PRODUCTS = {"P1", "P2", "P3", "P4"};

# Narzedzia
set TOOLS;
# Miesiace
set MONTHS ordered;

#############
# Parametry #
#############

# Liczba kazdego z narzedzi
param toolCount {TOOLS} >= 1;

# Dochody ze sprzedazy [pln/szt]
param expectedProfitPerUnit {PRODUCTS} >= 0;
	
# Czasy produkcji [godz]
param toolTimePerUnit {TOOLS, PRODUCTS} >= 0;

# Ograniczenia rynkowe liczby sprzedawanych produktow [szt]
param salesMarketLimit {MONTHS, PRODUCTS} >= 0;
			
# Ograniczeine liczby magazynowanych produktow [szt]
param storageLimit {PRODUCTS} >= 0;

# Koszt magazynowania produktow [pln/szt per msc]
param storageUnitCost >= 0;

# Aktualny stan magazynowy [szt]
param startingStorage {PRODUCTS} >= 0;
	
# PoÅ¼Ä…dany stan magazynowy na koniec symulacji [szt]
param desiredEndStorage {PRODUCTS} >= 0;

# Liczba dni roboczych w miesiacu [d]
param daysPerMonth >= 1;

# Liczba zmian w ciagu jednego dnia roboczego
param shiftsPerDay >= 1;

# Dlugosc zmiany [godz]
param hoursPerShift >= 1;

# Liczba roboczogodzin w miesi¹cu [godz]
param workHoursPerMonth = daysPerMonth*shiftsPerDay*hoursPerShift;

###########
# Zmienne #
###########
# Produkcja produktow
var produced {MONTHS, PRODUCTS} >= 0 integer;

# Sprzedaz produktow w danym miesiacu
var sold {MONTHS,PRODUCTS} >= 0 integer;
var totalSold {p in PRODUCTS} = sum {m in MONTHS} sold[m, p];

# Iloosc produktow przekazanych do magazynu w danym miesiacu
var stored {m in MONTHS, p in PRODUCTS} = produced[m, p] - sold[m, p]; 

# Stan magazynowy na koniec danego miesiaca
var storage {m in MONTHS, p in PRODUCTS} =
	startingStorage[p] + sum {m2 in MONTHS: ord(m2) <= ord(m)} stored[m2, p];  

# Czas pracy narzedzi w danym miesi¹cu
var toolUsageTime {m in MONTHS, t in TOOLS} =
	sum {p in PRODUCTS} produced[m,p]*toolTimePerUnit[t,p];

# Koszt magazynowania
var monthlyStorageCost {m in MONTHS} =
	(sum {p in PRODUCTS} storage[m, p])*storageUnitCost;
var totalStorageCost = sum {m in MONTHS} monthlyStorageCost[m];

# Wartosc oczekiwana calkowitego zysku 
var expectedSalesProfit = sum {p in PRODUCTS} totalSold[p]*expectedProfitPerUnit[p];
var expectedProfit = expectedSalesProfit - totalStorageCost;

#######################
# Ograniczenia modelu #
#######################

# Ograniczenie rynkowe sprzedazy produktow
subject to SalesMarketLimit {m in MONTHS, p in PRODUCTS}:
	sold[m, p] <= salesMarketLimit[m, p];
# Ograniczenie magazynowe sprzedazy produktow
subject to SalesLimit1 {p in PRODUCTS}:
	sold[first(MONTHS), p] <= produced[first(MONTHS), p];
subject to SalesLimit2 {m in MONTHS, p in PRODUCTS: m != first(MONTHS)}:
	sold[m, p] <= produced [m, p] + storage[m, p];
# Powiazanie sprzedazy produktu P4 ze sprzedaza produktow P1 i P2
subject to P4SalesConstraint {m in MONTHS}:
	sold[m, "P4"] >= sold[m, "P1"] + sold[m, "P2"];
# Ograniczenie pojemnoœci magazynowej
subject to StorageLimit {m in MONTHS, p in PRODUCTS}:
	storage[m, p] <= storageLimit[p];
# Ograniczenie na po¿¹dany stan magazynowy na koniec marca
subject to DesiredStorage {p in PRODUCTS}:
	storage[last(MONTHS), p] >= desiredEndStorage[p];
#Ograniczenie czasu pracy narzedzi w miesiacu
subject to ToolWorkTime {m in MONTHS, t in TOOLS}:
	toolUsageTime[m, t] <= toolCount[t]*workHoursPerMonth;
	
################
# Funkcje celu #
################
maximize TEST1: expectedProfit;
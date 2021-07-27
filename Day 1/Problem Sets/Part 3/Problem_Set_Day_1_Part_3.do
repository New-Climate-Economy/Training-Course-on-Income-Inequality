********************************************************************************
* Global Inequality Dynamics: New Findings from WID.world
* Replication Codes
********************************************************************************

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

// Setup

*Directory
global repdir "${maindir}Inequality Course Training Materials\Day 1\Problem Sets\Part_3\Data/"
cd "${repdir}"

//
// What is Income?
//

************************************************************* 
* STEP 1: INCOME AT THE NATIONAL LEVEL
*************************************************************

************************************************************* 
* GDP and National Income:
* nninc		(=) net national income
* gdpro	    (+) gross domestic product
* confc	    (-) consumption of fixed capital
* nnfin	    (+) foreign income
*************************************************************

*Call WID Data
wid, indicators(mnninc mgdpro mconfc mnnfin xlcusp) areas(ET TJ CH QA) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren (valuemgdpro999i valuemnnfin999i valuemconfc999i valuemnninc999i valuexlcusp999i) (gdp fi cfc ni xr)

*As Time Series
egen id = group(country)
tsset id year, yearly

*Plots
foreach c in ET TJ CH QA{
	local ET_n "Ethiopia"
	local TJ_n "Tajikistan"
	local CH_n "Switzerland"
	local QA_n "Qatar"
	
*Restrict Data	
	preserve
	keep if country == "`c'" & inrange(year,2000,2020)

*To Billions of US$ Dollars
	global factor = 1000000000
	sum xr if year == 2015
	local xr = `r(mean)'
	foreach var in gdp fi cfc ni{
		replace `var' = (`var' / `xr') / ${factor}
	}
		
	# d ;
	tw 
		tsline ni || 
		tsline gdp || 
		tsline fi ||
		tsline cfc,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "National Income (=)" 2 "Domestic Output (+)" 3 "Foreign Income (+)" 4 "Consumption of Fixed Capital (-)") cols(2) nobox)
		ytitle("Billions of 2012 US$")
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg ET.gph TJ.gph CH.gph QA.gph, cols(2) legendfrom(ET.gph) graphregion(color(white))
graph export "${repdir}National Income and GDP.pdf", replace

*************************************************************
* Labor, Capital and National Income: 
* nninc		(=) net national income
* comhn	    (+) compensation of employees
* fkpin	    (+) net capital income		
* nmxho	    (+) net mixed income of households
* ptxgo	    (+) taxes on products and production
************************************************************* 

*Call WID Data
wid, indicators(mnninc mcomhn mfkpin mnmxho mptxgo xlcusp) areas(GN IS NE CO) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren (valuemcomhn999i valuemfkpin999i valuemnmxho999i valuemnninc999i valuemptxgo999i valuexlcusp999i) (labor capital mixed_income ni taxes xr)

*As Time Series
egen id = group(country)
tsset id year, yearly

*Plots
foreach c in GN IS NE CO{
	local GN_n "Guinea"
	local IS_n "Iceland"
	local NE_n "Nepal"
	local CO_n "Colombia"
	
*Restrict Data	
	preserve
	keep if country == "`c'" & inrange(year,2005,2015)

*To Billions of US$ Dollars
	global factor = 1000000000
	sum xr if year == 2015
	local xr = `r(mean)'
	foreach var in ni labor capital mixed_income taxes{
		replace `var' = (`var' / `xr') / ${factor}
	}
		
	# d ;
	tw 
		tsline ni || 
		tsline labor || 
		tsline capital ||
		tsline mixed_income ||
		tsline taxes,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "National Income (=)" 2 "Labor Income (+)" 3 "Capital Income (+)" 4 "Mixed Income (+)" 5 "Taxes (+)") cols(3) size(small)  nobox)
		ytitle("Billions of 2012 US$")
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg GN.gph IS.gph NE.gph CO.gph, cols(2) legendfrom(GN.gph) graphregion(color(white))
graph export "${repdir}National Income, Labor and Capital.pdf", replace


//
// What is Capital?
//

************************************************************* 
* STEP 1: WEALTH AND CAPITAL AT THE NATIONAL LEVEL
*************************************************************

*************************************************************
* National Wealth 
* nweal	(=) net market-value national wealth
* nwnfa	(+) national non-financial assets
* nwnxa	(+) net foreign assets
************************************************************* 

*Call WID Data
wid, indicators(mnweal mnwnfa mnwnxa xlcusp) areas(NO JP RU US) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren (valuemnweal999i valuemnwnfa999i valuemnwnxa999i valuexlcusp999i) (nw na fa xr)

*As Time Series
egen id = group(country)
tsset id year, yearly


*Plots
foreach c in NO JP RU US{
	local NO_n "Norway"
	local JP_n "Japan"
	local RU_n "Russia"
	local US_n "United States"
	
*Restrict Data	
	preserve
	keep if country == "`c'" & inrange(year,2000,2020)

*To Billions of US$ Dollars
	global factor = 1000000000000
	sum xr if year == 2015
	local xr = `r(mean)'
	foreach var in nw na fa{
		replace `var' = (`var' / `xr') / ${factor}
	}
		
	# d ;
	tw 
		tsline nw || 
		tsline na || 
		tsline fa,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "National Wealth (=)" 2 "National Assets (+)" 3 "Foreign Assets (+)") cols(3) nobox size(small))
		ytitle("Thousands of Billions of 2012 US$", size(small))
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg NO.gph JP.gph RU.gph US.gph, cols(2) legendfrom(US.gph) graphregion(color(white))
graph export "${repdir}National Wealth, National and Foreign Assets.pdf", replace

*************************************************************
* National Non-Financial Assets 
* nwnfa	(=) national non-financial assets
* nwhou	(+) national housing assets
* nwdwe		(+) dwellings
* nwlan		(+) land underlying dwellings
* nwbus	(+) national business and other non-financial assets
* nwagr		(+) agricultural land
* nwnat		(+) natural capital
* nwodk	(+) other domestic capital
************************************************************* 

*Call WID Data
wid, indicators(mnwnfa mnwhou mnwbus mnwodk mnwnat mnwagr xlcusp) areas(AU CA ES JP) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren ///
	(valuemnwnfa999i valuemnwhou999i valuemnwbus999i valuemnwodk999i valuemnwnat999i valuemnwagr999i  valuexlcusp999i) ///
	(nw nwhou nwbus nwoth nwagr nwnat xr)

*As Time Series
egen id = group(country)
tsset id year, yearly


*Plots
foreach c in AU CA ES JP{
	local AU_n "Australia"
	local CA_n "Canada"
	local ES_n "Spain"
	local JP_n "Japan"
	
*Restrict Data	
	preserve
	keep if country == "`c'" & inrange(year,2000,2020)

*To Billions of US$ Dollars
	global factor = 1000000000000
	sum xr if year == 2015
	local xr = `r(mean)'
	foreach var in nw nwhou nwbus nwoth{
		replace `var' = (`var' / `xr') / ${factor}
	}
		
	# d ;
	tw 
		tsline nw || 
		tsline nwhou || 
		tsline nwbus ||
		tsline nwoth,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "National Assets (=)" 2 "Housing Assets (+)" 3 "Business Assets (+)" 4 "Other Assets (+)") cols(2) nobox size(small))
		ytitle("Thousands of Billions of 2012 US$", size(small))
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg AU.gph CA.gph ES.gph JP.gph, cols(2) legendfrom(AU.gph) graphregion(color(white))
graph export "${repdir}National Wealth, Housing and Business Assets.pdf", replace

*************************************************************
* Natural Capital
* nwnat		(+) natural capital
************************************************************* 

*Call WID Data
wid, indicators(mnwnat xlcusp) areas(FR KR NL CZ) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren ///
	(valuemnwnat999i valuexlcusp999i) ///
	(nwnat xr)

*As Time Series
egen id = group(country)
tsset id year, yearly

*Calculation with respect to base year
gen nwnat_base = .
foreach c in FR KR NL CZ{
	qui sum nwnat if year == 2000 & country == "`c'"
	qui replace nwnat_base = 100 * (nwnat / `r(mean)') if country == "`c'"
}
keep if inrange(year,2000,2020)

*Plot
# d ;
tw
	tsline nwnat_base if country == "FR" ||
	tsline nwnat_base if country == "KR" ||
	tsline nwnat_base if country == "NL" ||
	tsline nwnat_base if country == "CZ",
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "France" 2 "South Korea" 3 "Netherlands" 4 "Czech Republic") cols(2) nobox size(small))
		ytitle("Natural Capital (Base Year 2000)", size(small))
		xtitle("Year")
;
# d cr
graph export "${repdir}Natural Capital.pdf", replace

//
// Inequality Between Labor and Capital
//


************************************************************* 
* STEP 1: WEALTH AND CAPITAL AT THE NATIONAL LEVEL
*************************************************************

*************************************************************
* Cobb-Douglas production function: Y = F(K, L) = K^{α} x L^{1−α}
*
* With perfect competition:
* - wage rate v = marginal product of  labor 
* - rate of return r = marginal product of capital
*
* Were:
* r = F_{K} = α x K^{α−1} x L^{1−α}  and v = F_{L} = (1 − α) x K^{α} x L^{−α}
*
* So capital income:
* - Y_{K} = r x K = α x Y 
*
* and labor income:
* - Y_{L} = v x L = (1 − α) x Y
************************************************************* 

*************************************************************
* Capital and Labor Shares:
* wlabsh  = (compensation of employees + 70% of net mixed income) /
*         	(net national income – taxes on products and production)		
* wcapsh  =  (net capital income + 30% of net mixed income) /
*			(net national income – taxes on products and production)
*************************************************************

		
*Call WID Data
wid, indicators(wlabsh wcapsh) areas(US FR GB JP) perc(p0p100) ages(999) pop(_all) clear

*Reshape WID Data
reshape wide value, i(country year) j(variable) string

*Rename Variables
ren (valuewlabsh999i valuewcapsh999i) (ls cs)

*As Time Series
egen id = group(country)
tsset id year, yearly


*Plots
foreach c in US FR GB JP{
	local JP_n "Japan"
	local GB_n "Great Britain"
	local FR_n "France"
	local US_n "United States"
	
*Restrict Data	
	preserve
	keep if country == "`c'" & inrange(year,1960,2020)
	foreach v in ls cs{
		replace `v' = 100 * `v'
	}
		
	# d ;
	tw 
		tsline ls ||
		tsline cs,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "Labor Share" 2 "Capital Share") cols(2) nobox size(small))
		ytitle("% of National Income", size(small))
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg US.gph FR.gph GB.gph JP.gph, cols(2) legendfrom(US.gph) graphregion(color(white))
graph export "${repdir}Labor and Capital Shares.pdf", replace

//
// Inequality between Individuals
//


************************************************************* 
* STEP 1: WEALTH AND CAPITAL AT THE NATIONAL LEVEL
*************************************************************

*************************************************************
* Cobb-Douglas production function: Y = F(K, L) = K^{α} x L^{1−α}
*
* With perfect competition:
* - wage rate v = marginal product of  labor 
* - rate of return r = marginal product of capital
*
* Were:
* r = F_{K} = α x K^{α−1} x L^{1−α}  and v = F_{L} = (1 − α) x K^{α} x L^{−α}
*
* So capital income:
* - Y_{K} = r x K = α x Y 
*
* and labor income:
* - Y_{L} = v x L = (1 − α) x Y
************************************************************* 

*************************************************************
* Average Income of Top 10% versus Average Income of Bottom 50%
*************************************************************

*Get Exchange Rate
wid, indicators(xlcusp) areas(FR US CN JP) year(2015) clear
ren value xr
keep xr country
tempfile xr
save `xr', replace

*Get WID Data
wid, indicators(aptinc) areas(FR US CN JP) perc(p0p50 p90p100) year(2000/2017) ages(992) pop(j) clear

*Reshape WID Data
reshape wide value, i(country year percentile) j(variable) string
reshape wide valueaptinc992j, i(country year) j(percentile) string
merge m:1 country using `xr', nogen

*Rename Variables
ren (valueaptinc992jp0p50 valueaptinc992jp90p100 xr) (y_bot y_top xr)

*In Constant US$
foreach var in y_bot y_top{
	replace `var' = (`var' / xr) / 1000
}

*As Time Series
egen id = group(country)
tsset id year, yearly

*Plots
foreach c in FR US CN JP{
	local JP_n "Japan"
	local CN_n "China"
	local FR_n "France"
	local US_n "United States"
	
*Restrict Data	
	preserve
	keep if country == "`c'"

	# d ;
	tw 
		tsline y_bot ||
		tsline y_top,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "Bottom 50%" 2 "Top 10%") cols(2) nobox size(small))
		ytitle("Average Income, Thousands of 2015 US$", size(small))
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg FR.gph US.gph CN.gph JP.gph, cols(2) legendfrom(US.gph) graphregion(color(white))
graph export "${repdir}Average Income, Top10 and Bottom 50.pdf", replace

*************************************************************
*Income Share of Top 10% and Top 1%
*************************************************************

*Get WID Data
wid, indicators(sptinc) areas(FR US CN JP) perc(p90p100 p99p100) year(1980/2017) ages(992) pop(j) clear

*Reshape WID Data
reshape wide value, i(country year percentile) j(variable) string
reshape wide valuesptinc992j, i(country year) j(percentile) string

*Rename Variables
ren (valuesptinc992jp90p100 valuesptinc992jp99p100) (top10 top1)

*As Percentages
foreach var in top10 top1{
	replace `var' = 100 * `var'
}

*As Time Series
egen id = group(country)
tsset id year, yearly

*Plots
foreach c in FR US CN JP{
	local JP_n "Japan"
	local CN_n "China"
	local FR_n "France"
	local US_n "United States"
	
*Restrict Data	
	preserve
	keep if country == "`c'"

	# d ;
	tw 
		tsline top10 ||
		tsline top1,
		graphregion(color(white))
		ylabel(,nogrid)	
		legend(order(1 "Top 10%" 2 "Top 1%") cols(2) nobox size(small))
		ytitle("Income Share", size(small))
		xtitle("Year")
		title("``c'_n'")
		saving(`c'.gph, replace)	
	;
	# d cr
	restore
}
grc1leg FR.gph US.gph CN.gph JP.gph, cols(2) legendfrom(US.gph) graphregion(color(white))
graph export "${repdir}Income Share, Top10 and Top 1.pdf", replace

*************************************************************
* Top Incomes in Ethiopia
*************************************************************

*Get Exchange Rate
wid, indicators(xlcusp) areas(ET) year(2015) clear
ren value xr
keep xr country
tempfile xr
save `xr', replace

*Get WID Data
wid, indicators(aptinc) areas(ET) perc(p0p50 p90p100) year(2000/2017) ages(992) pop(j) clear

*Reshape WID Data
reshape wide value, i(country year percentile) j(variable) string
reshape wide valueaptinc992j, i(country year) j(percentile) string
merge m:1 country using `xr', nogen

*Rename Variables
ren (valueaptinc992jp0p50 valueaptinc992jp90p100 xr) (y_bot y_top xr)

*In Constant US$
foreach var in y_bot y_top{
	replace `var' = (`var' / xr) / 1000
}

*As Time Series
egen id = group(country)
tsset id year, yearly

# d ;
tw 
	tsline y_bot ||
	tsline y_top,
	graphregion(color(white))
	ylabel(,nogrid)	
	legend(order(1 "Bottom 50%" 2 "Top 10%") cols(2) nobox size(small))
	ytitle("Average Income, Thousands of 2015 US$", size(small))
	xtitle("Year")
	title("Ethiopia")
;
# d cr
graph export "${repdir}Average Income, Top10 and Bottom 50 - Ethiopia.pdf", replace

*************************************************************
*Income Shares in Ethiopia
*************************************************************

*Get WID Data
wid, indicators(sptinc) areas(ET) perc(p50p100 p90p100 p99p100) year(1981/2017) ages(992) pop(j) clear

*Reshape WID Data
reshape wide value, i(country year percentile) j(variable) string
reshape wide valuesptinc992j, i(country year) j(percentile) string


*Rename Variables
ren (valuesptinc992jp50p100 valuesptinc992jp90p100 valuesptinc992jp99p100) (top50 top10 top1)

*As Percentages
foreach var in top50 top10 top1{
	replace `var' = 100 * `var'
}

*As Time Series
egen id = group(country)
tsset id year, yearly

# d ;
tw 
	tsline top50 ||
	tsline top10 ||
	tsline top1,
	graphregion(color(white))
	ylabel(,nogrid)	
	legend(order(1 "Top 50%" 2 "Top 10%" 3 "Top 1%") cols(3) nobox size(small))
	ytitle("Income Share", size(small))
	xtitle("Year")
	title("Ethiopia")
;
# d cr
graph export "${repdir}Income Share, Top50, Top10 and Top 1 - Ethiopia.pdf", replace

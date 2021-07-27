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
global repdir "${maindir}\Inequality Course Training Materials\Day 1\Problem Sets\Part_2\Data/"
cd "${repdir}"

// Source Data

*Excel File
global xlsfile "ACPSZ2017.xlsx"

// Table 1: Real Income Growth and Inequality,

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("Data4") clear
keep if _n >= 7 // Drop rows with no relevant information

*China
destring C D, replace force
gen china = 100 * ((D - C)/ C)

*USA
destring G H, replace force
gen usa = 100 * ((H - G)/ G)

*France
destring L K, replace force
gen france = 100 * ((L - K)/ K)

*Rounding
foreach var in china usa france{
	drop if mi(`var')
	replace `var' = round(`var')
	local u = proper("`var'")
	lab var `var' "`u' (%)"
}

*Column
gen income_group = ""
replace income_group = "Full Population" in 1
replace income_group = "Bottom 50%" in 2
replace income_group = "Middle 40%" in 3
replace income_group = "Top 10%" in 4
replace income_group = "Top 10% - incl. Top 1%" in 5
replace income_group = "Top 10% - incl. Top 0.1%" in 6
replace income_group = "Top 10% - incl. Top 0.01%" in 7
replace income_group = "Top 10% - incl. Top 0.001%" in 8
lab var income_group "Income group (distribution of per-adult pretax national income)"

*Table
keep income_group china usa france
order income_group china usa france
save "${repdir}ACPSZ - 	Table 1", replace

// Figure 1

*Panel A: Top 1% income share

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("Data3") clear

*Top 1% Series
destring Z, gen(france_top1) force
destring AD, gen(usa_top1) force
destring E, gen(china_top1) force
foreach var in france_top1 usa_top1 china_top1{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep france_top1 usa_top1 china_top1 year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter china_top1 year, connect(direct) lpattern(dash) ||
	scatter usa_top1 year, connect(direct) lpattern(dash) ||
	scatter france_top1 year, connect(direct) lpattern(dash)
	graphregion(color(white))
	legend(order(1 "China" 2 "USA" 3 "France") cols(3))
	xtitle("")
	saving(panelA, replace)
;
# d cr


*Panel B: Bootom 50% income share

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("Data3") clear

*Top 1% Series
destring W, gen(france_bot50) force
destring AA, gen(usa_bot50) force
destring B, gen(china_bot50) force
foreach var in france_bot50 usa_bot50 china_bot50{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep france_bot50 usa_bot50 china_bot50 year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter china_bot50 year, connect(direct) lpattern(dash) ||
	scatter usa_bot50 year, connect(direct) lpattern(dash) ||
	scatter france_bot50 year, connect(direct) lpattern(dash)
	graphregion(color(white))
	legend(order(1 "China" 2 "USA" 3 "France") cols(3))
	xtitle("")	
	saving(panelB, replace)
;
# d cr

*Combine Plots
grc1leg panelA.gph panelB.gph, cols(2) legendfrom(panelA.gph) graphregion(color(white))
graph export "${repdir}ACPSZ - Figure 1.pdf", replace

// Figure 2: The Decline of Public Property versus the Rise of Sovereign Funds

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("Data2") clear

*Public Share in National Wealth Series
destring W, gen(china_psnw) force
destring CD, gen(usa_psnw) force
destring DW, gen(france_psnw) force
destring FD, gen(uk_psnw) force
destring FJ, gen(japan_psnw) force
destring FW, gen(germany_psnw) force
destring GJ, gen(norway_psnw) force
foreach var in china_psnw usa_psnw france_psnw uk_psnw japan_psnw germany_psnw norway_psnw{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep china_psnw usa_psnw france_psnw uk_psnw japan_psnw germany_psnw norway_psnw year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter china_psnw year, connect(direct) lpattern(dash) ||
	scatter usa_psnw year, connect(direct) lpattern(dash) ||
	scatter france_psnw year, connect(direct) lpattern(dash) ||
	scatter uk_psnw year, connect(direct) lpattern(dash) ||
	scatter japan_psnw year, connect(direct) lpattern(dash) ||
	scatter germany_psnw year, connect(direct) lpattern(dash) ||
	scatter norway_psnw year, connect(direct) lpattern(dash)		
	graphregion(color(white))
	legend(order(1 "China" 2 "USA" 3 "France" 4 "UK" 5 "Japan" 6 "Germany" 7 "Norway") cols(3))
	xtitle("")
;
# d cr
graph export "${repdir}ACPSZ - Figure 2.pdf", replace

// Figure 3: Top 1 Percent Wealth Share in China, United States, France, and United Kingdom, 1890–2015

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("Data5") clear

*Top 1 Percent Wealth Share
destring W, gen(china_ws) force
destring P, gen(usa_ws) force // Capitalization Method
destring U, gen(france_ws) force
destring D, gen(uk_ws) force
foreach var in china_ws usa_ws france_ws uk_ws{
	replace `var' = 100 * `var' // As %
}

*Year
ren A year

*Reduce Dataset
keep china_ws usa_ws france_ws uk_ws year
drop if year == . | year < 1890

*Plot
sort year, stable
# d ;
tw 
	scatter china_ws year, connect(direct) lpattern(dash) ||
	scatter usa_ws year, connect(direct) lpattern(dash) ||
	scatter france_ws year, connect(direct) lpattern(dash) ||
	scatter uk_ws year, connect(direct) lpattern(dash)
	graphregion(color(white))
	legend(order(1 "China" 2 "USA" 3 "France" 4 "UK") cols(2))
	xtitle("")
	xlabel(1890(10)2010)
;
# d cr
graph export "${repdir}ACPSZ - Figure 3.pdf", replace

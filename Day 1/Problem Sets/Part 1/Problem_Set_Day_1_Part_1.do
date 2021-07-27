********************************************************************************
* Simplified Distributional National Accounts
* Replication Codes
********************************************************************************

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

// Setup

*Directory
global repdir "${maindir}\Inequality Course Training Materials\Day 1\Problem Sets\Part_1\Data/"
cd "${repdir}"

// Source Data

*Excel File
global xlsfile "PSZ2019datafile.xlsx"

// Figure 1: Top 1 Percent Income Shares, 1960 –2016

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring AJ, gen(psz_taxunit) force
destring AL, gen(psz_adultunit) force
destring AD, gen(pikettysaez_taxunit) force
destring AM, gen(autensplinter_adultunit) force
foreach var in pikettysaez_taxunit psz_taxunit psz_adultunit autensplinter_adultunit{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep pikettysaez_taxunit psz_taxunit psz_adultunit autensplinter_adultunit year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter pikettysaez_taxunit year, connect(direct) lpattern(dash) ||
	scatter psz_taxunit year, connect(direct) lpattern(dash) ||
	scatter psz_adultunit year, connect(direct) lpattern(dash) ||
	scatter autensplinter_adultunit year, connect(direct) lpattern(dash)
	graphregion(color(white))
	legend(order(1 "Piketty-Saez fiscal income (tax unit)" 2 "PSZ Pre-Tax National Income (tax unit)" 
		3 "PSZ Pre-Tax National Income (adult unit)" 4 "Auten and Splinter (2018) (adult unit)") cols(1))
	xtitle("")
;
# d cr
graph export "${repdir}PSZ2019 - Figure 1.pdf", replace

// Figure 2: From Taxable to Total Pretax National Income, 1960–2016

** Panel A

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring W, gen(tax_exempt_labor_income) force
destring T, gen(taxable_income) force
destring X, gen(tax_exempt_capital_income) force
foreach var in tax_exempt_labor_income taxable_income tax_exempt_capital_income{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep tax_exempt_labor_income taxable_income tax_exempt_capital_income year
drop if year == .

*Plot
replace tax_exempt_capital_income = tax_exempt_capital_income + taxable_income + tax_exempt_labor_income
replace tax_exempt_labor_income = taxable_income + tax_exempt_labor_income

# d ;
tw 
	area tax_exempt_capital_income year ||
	area tax_exempt_labor_income year ||
	area taxable_income year,
	graphregion(color(white))
	ylabel(0(25)100)
	xlabel(1960(5)2015)
	ytitle("Percent of factor-price national income")
	xtitle("")
	title("Panel A. From taxable to total pretax national income")
	legend(order(1 "Tax-Exempt Capital Income" 2 "Tax-Exempt Labor Income" 3 "Taxable Income") cols(1))
	saving(panelA, replace)
;
# d cr


** Panel B

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring U, gen(taxable_labor_income) force
destring W, gen(tax_exempt_labor_income) force
destring V, gen(taxable_capital_income) force
destring Y, gen(tax_exempt_capital_income_pf) force
destring Z, gen(other_tax_exempt_capital_income) force

foreach var in taxable_labor_income taxable_capital_income tax_exempt_labor_income tax_exempt_capital_income_pf other_tax_exempt_capital_income{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep taxable_labor_income taxable_capital_income tax_exempt_labor_income tax_exempt_capital_income_pf other_tax_exempt_capital_income year
drop if year == .

*Plot
replace other_tax_exempt_capital_income = taxable_labor_income + taxable_capital_income + tax_exempt_labor_income + tax_exempt_capital_income_pf + other_tax_exempt_capital_income
replace tax_exempt_capital_income_pf = taxable_labor_income + taxable_capital_income + tax_exempt_labor_income + tax_exempt_capital_income_pf
replace taxable_capital_income = taxable_labor_income + taxable_capital_income + tax_exempt_labor_income
replace tax_exempt_labor_income = taxable_labor_income + tax_exempt_labor_income

# d ;
tw 
	area other_tax_exempt_capital_income year ||
	area tax_exempt_capital_income_pf year ||
	area taxable_capital_income year ||
	area tax_exempt_labor_income year ||
	area taxable_labor_income year,
	graphregion(color(white))
	ylabel(0(25)100)
	xlabel(1960(5)2015)
	ytitle("Percent of factor-price national income")
	xtitle("")
	title("Panel B. Separating taxable labor and taxable capital income")
	legend(order(
		1 "Other Tax-Exempt Capital Income" 
		2 "Tax-Exempt Capital Income in Pension Funds" 
		3 "Tax-Exempt Labor Income"
		4 "Taxable Capital Income"
		5 "Taxable Labor Income") cols(1))
	saving(panelB, replace)
;
# d cr

*Combine Plots
grc1leg panelA.gph panelB.gph, cols(1) legendfrom(panelA.gph) graphregion(color(white))
graph export "${repdir}PSZ2019 - Figure 2.pdf", replace

// Figure 3: Top 1 Percent Pretax National Income Share: PSZ versus Simplified Computations

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring AJ, gen(psz_taxunit) force
destring AC, gen(simplified_psz_taxunit) force
foreach var in simplified_psz_taxunit psz_taxunit{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep simplified_psz_taxunit psz_taxunit year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter simplified_psz_taxunit year, connect(direct) lpattern(dash) ||
	scatter psz_taxunit year, connect(direct) lpattern(solid) msymbol(none)
	graphregion(color(white))
	legend(order(1 "Simplified PSZ (tax units)" 2 "PSZ (tax units)") cols(1))
	xtitle("")
	xlabel(1960(5)2015)	
;
# d cr
graph export "${repdir}PSZ2019 - Figure 3.pdf", replace

// Figure 4. How to Recover Auten and Splinter Top 1 Percent Income Share Series Using Simplified Computations

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring AZ, gen(simplified_autensplinter) force
destring AM, gen(autensplinter) force
foreach var in simplified_autensplinter autensplinter{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep simplified_autensplinter autensplinter year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter simplified_autensplinter year, connect(direct) lpattern(dash) ||
	scatter autensplinter year, connect(direct) lpattern(solid) msymbol(none)
	graphregion(color(white))
	legend(order(1 "Simplified Auten and Splinter" 2 "Auten and Splinter") cols(1))
	xtitle("")
	xlabel(1960(5)2015)	
;
# d cr
graph export "${repdir}PSZ2019 - Figure 4.pdf", replace



// Figure 5. Top 1 Percent Wealth Share in the United States: Capitalized Incomes and SCF

*Raw Data
import excel using "${repdir}${xlsfile}", sheet("SimpleDINApretax") clear

*Top 1% Series
destring BJ, gen(scf) force
destring BK, gen(capitalized_incomes) force
foreach var in scf capitalized_incomes{
	replace `var' = 100 * `var' // As %
}

*Year
destring A, gen(year) force

*Reduce Dataset
keep scf capitalized_incomes year
drop if year == .

*Plot
sort year, stable
# d ;
tw 
	scatter scf year, connect(direct) lpattern(solid) msymbol(triangle) ||
	scatter capitalized_incomes year, connect(direct) lpattern(solid) msymbol(oh)
	graphregion(color(white))
	legend(order(1 "SCF (including Forbes 400)" 2 "Capitalized incomes (Saez-Zucman)") cols(1))
	xtitle("")
	xlabel(1960(5)2015)	
;
# d cr
graph export "${repdir}PSZ2019 - Figure 5.pdf", replace

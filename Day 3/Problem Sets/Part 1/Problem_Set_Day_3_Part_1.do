// Setup

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

*Directory
global repdir "${maindir}Inequality Course Training Materials\Day 3\Problem Sets\Part_1\Data/"

************************************************************* 
* AUXILIAR STEP: VARIABLE LISTS
*************************************************************

*Survey Variables
global survey_vars idh idp weight

*Demographic Variables
global demo_vars age male

*Income Variables
global income_vars total_y labor_y transfer_y other_y

************************************************************* 
* STEP 1: Call Survey Data
*************************************************************

// Survey Data

use $survey_vars $demo_vars $income_vars if inrange(age,18,65) using "${repdir}CASEN", clear

************************************************************* 
* STEP 2: Size distribution (deciles and quantiles)
*************************************************************

// Income Percentiles
foreach var in $income_vars{
	foreach q in 5 10 100{
		xtile q`q'_`var' = `var' [aw = weight] if `var' > 0, nq(`q')

*Income distribution within quantiles
		foreach ivar in $income_vars{
			egen `ivar'_q`q'`var' = mean(`ivar'), by(q`q'_`var')		
		}
	}	
}

// Income Composition

*Average Income by Income Quantile
preserve
collapse (mean) ${income_vars} [aw = weight], by(q10_total_y)

*Levels		
# d ;
graph bar (mean) transfer_y labor_y other_y, 
	over(q10_total_y)
	stack
	graphregion(color(white))
	ytitle("Total Income (2017 US$)")
	legend(order(1 "Transfers Income" 2 "Labor Income" 3 "Other Income") nobox cols(1))
	blabel("Income Decile")

;
# d cr
graph export "${repdir}income composition - levels - q10_total_y.pdf", replace

*Percentages		
foreach ivar in transfer_y labor_y other_y{
	replace `ivar' = 100 * `ivar' / total_y
}
# d ;
graph bar (mean) transfer_y labor_y other_y, 
	over(q10_total_y)
	stack
	graphregion(color(white))
	ytitle("Income Share (%)")
	legend(order(1 "Transfers Income" 2 "Labor Income" 3 "Other Income") nobox cols(1))
	blabel("Income Decile")	
;
# d cr
graph export "${repdir}income composition - shares - q10_total_y.pdf", replace
restore


************************************************************* 
* STEP 3: Lorenz curve and Gini coefficient
*************************************************************

*Inequality Decomposition Package
foreach var in $income_vars{
	qui ineqdeco `var' if `var' > 0 [aw = weight]
	local gini = round(100*`r(gini)')
	di in red "Gini Coefficient: `gini'"
}

*Generalized Lorenz Curves
foreach var in $income_vars{
	glcurve `var' [aw = weight] if `var' > 0, gl(g_`var') p(p_`var') nograph lorenz replace
}

*Plot
# d ;
tw 
	line g_total_y p_total_y, sort ||
	line g_labor_y p_labor_y, sort ||
	line g_transfer_y p_transfer_y, sort ||
	line g_other_y p_other_y, sort
	legend(order(1 "Total" 2 "Labor" 3 "Transfers" 4 "Other") cols(4))
	graphregion(color(white))
	xtitle("Income Rank")
	ytitle("Income Share")
;
# d cr
graph export "${repdir}lorenz curves.pdf", replace

************************************************************* 
* STEP 4: Coefficient of variation
*************************************************************

*Coefficient of Variation
preserve
foreach var in $income_vars{
	sum  `var' if `var' > 0 [aw = weight]
	local cv_`var' = 100 * `r(sd)' / `r(mean)'
	gen cv_`var' = 100 * `r(sd)' / `r(mean)' in 1
	di in red "Coefficient of Variation: `cv'"
}

# d ;
graph bar (mean) cv_transfer_y cv_labor_y cv_total_y cv_other_y, 
	graphregion(color(white))
	ytitle("Coefficient of Variation")
	legend(order(1 "Transfers Income" 2 "Labor Income"  3 "Total Income"  4 "Other Income") nobox cols(2))
;
# d cr
graph export "${repdir}coefficient of variation.pdf", replace
restore

************************************************************* 
* STEP 5: Atkinson index
*************************************************************

*Inequality Decomposition Package
foreach var in $income_vars{
	qui ineqdeco `var' if `var' > 0 [aw = weight]
	foreach atk in half 1 2{
		local atkinson = round(100*`r(a`atk')')
		di in red "Atkinson(`atk'): `atkinson'"
	}
}

************************************************************* 
* STEP 6: Theil Index
*************************************************************

*Theil Index Package
foreach var in $income_vars{
	theildeco `var' if `var' > 0 [aw = weight]
	local theil = round(100*`r(Theil)')
	di in red "Theil Index: `theil'"
}

********************************************************************************
* Measuring the Trends in Inequality of Individuals and Families Income and 
* 	Consumption
* Replication Codes
********************************************************************************

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

// Setup

*Directory
global repdir "${maindir}\Inequality Course Training Materials\Day 3\Problem Sets\Part_2\Data/"
cd "${repdir}"

// Data Preparation

*Raw Data
use "${repdir}FJS2013 - Data", clear

* Create equivalent measures using square root of family size as the equivalence scale
gen scale=fam_size^.5
gen eq_cons=consumption/scale
gen eq_income=income/scale
gen eq_disp_income=disp_income/scale
gen eq_hpv=hpv_nondurables/scale
gen eq_ahp=ahp_nondurables/scale
gen eq_ms=ms_consumption/scale

* Create family weight
gen fwgt=weight*fam_size

*This is an auxiliar bit
gen _mi_miss=0
gen _mi_id=0
mi extract 0, clear

*Save Data
compress
sort year, stable
save "${repdir}FJS2013 - Worked Data", replace

// Figure 1: Inequality Using the Gini Coefficient

*Setup
preserve
keep if inrange(year,1985,2010)

*Indexes
sort year, stable
qui sum year
local miny = r(min)
local maxy = r(max)
local gini_vars eq_income eq_disp_income eq_cons
egen tag_year = tag(year)

*Fill Gini Levels
foreach var of local gini_vars{
	gen gini_`var' = .
	ineqdeco `var' [w=fwgt], bygroup(year)
	local j = 1
	forv yr = `miny'(1)`maxy'{
		replace gini_`var' = r(gini_`yr') if year == `yr' & tag_year == 1
		local j = `j' + 1
	}
}

*Prepare Plot
keep if tag_year == 1
keep year gini_*
tsset year, yearly

*Merge CPS
merge 1:1 year using "CPS Gini", nogen keep(matched)
ren gini_corrected gini_cps

*Plot
# d ;
tw
	tsline gini_cps ||
	tsline gini_eq_income  ||
	tsline gini_eq_disp_income ||
	tsline gini_eq_cons,
	graphregion(color(white))
	ytitle("Gini Coefficient")
	xtitle("Year")
	legend(order(1 "CPS Income" 2 "Income" 3 "Disposable Income" 4 "Consumption"))
;
# d cr
graph export "${repdir}FSJ2013 - Figure 1.pdf", replace
restore

// Figure 2: Comparing the Trends in Inequality 

*Setup
preserve
keep if inrange(year,1985,2010)

*Indexes
sort year, stable
qui sum year
local miny = r(min)
local maxy = r(max)
local mean_gini_vars eq_cons eq_disp_income eq_hpv eq_ahp eq_ms
egen tag_year = tag(year)

*Fill Mean Gini Levels
foreach var of local mean_gini_vars{
	gen mean_gini_`var' = .
	ineqdeco `var' [w=fwgt], bygroup(year)
	local j = 1
	forv yr = `miny'(1)`maxy'{
		replace mean_gini_`var' = r(gini_`yr') if year == `yr' & tag_year == 1
		local j = `j' + 1
	}
	sum mean_gini_`var' if tag_year == 1
	replace mean_gini_`var' = 100 * (mean_gini_`var' / `r(mean)')
}

*Prepare Plot
keep if tag_year == 1
keep year mean_gini_*
tsset year, yearly

*Plot
# d ;
tw
	tsline mean_gini_eq_cons ||
	tsline mean_gini_eq_hpv ||
	tsline mean_gini_eq_ahp ||
	tsline mean_gini_eq_ms ||
	tsline mean_gini_eq_disp_income,
	graphregion(color(white))
	ytitle("Mean = 100")
	xtitle("Year")
	legend(order(1 "Consumption" 2 "HPV Consumption" 3 "AHP Consumption" 4 "MS Consumption" 5 "Diposable Income"))
;
# d cr
graph export "${repdir}FSJ2013 - Figure 2.pdf", replace
restore

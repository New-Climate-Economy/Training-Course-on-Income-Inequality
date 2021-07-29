*************************************************************
* Day 5: Policy Problem - A Practical Exercise
*************************************************************
*************************************************************
* Organize Survey Microdata
*************************************************************

*Housekeeping
version 15.1
macro drop _all
clear 
clear mata
clear matrix
set more off, permanently
set mem 10g
set maxvar 32767
cap log close
set excelxlsxlargefile on
 
*************************************************************
* Set Directories, Files and Variable Names
*************************************************************

** User Written Commands
foreach c in wid{
	cap which `c'
	if _rc cap ssc install `c'
}

** Parameters and Flags

* Set Date
global date "20210308"

** Directories

* main directory
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/Course/Day 5/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/Course/Day 5/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/Course/Day 5/"

* log directory 
global logdir "${maindir}Log/"

* codes directory 
global codedir "${maindir}Codes/"

* data directory
global datadir "${maindir}Data/"

* intermediate data directory
global intermediate "${maindir}Data/Working Data/"

* figure output directory
global figdir "${maindir}Output/Figures/"

* table output directory
global tabdir "${maindir}Output/Tables/"

** Start log file
log using "${logdir}day5 - ${date}.log", replace

********************************************************************************
*Jah, Matthews and Muller (2019), "Does Enviromental Policy Affect Income Inequality? 
*Evidence from the Clean Air Act.", American Economic Review Papers and Proceedings, 271-276.
********************************************************************************

/* Abstract: This paper quantifies the impact of environmental policy on 
			 income inequality. We focus on the Clean Air act and the National
			 Ambient Air Quality standards for fine particulate matter and ozone. 
			 Using a matched difference-in-differences estimator, we find evidence
			 that both standards increased inequality in market income and a measure
			 of income that deducts per-capita air pollution damage from adjusted gross
			 income. While pollution standards can reduce pollution levels and thus result
			 in significant environmental benefits in aggregate, our findings suggest that 
			 these standards appear to distort the distribution of economic resources in complex, 
			 and at times unfortunate, ways.
	
	The exercise has two parts:
						
			- Part 1: Compute summary statistics by state using Market income data, Pm25 data and O3 data
					  for the 5 states at top of the distribution the 5 state at the bottom and NY
					  and visualize the evolution of the indicatores over the period only for NY and the state
					  at the bottom of the distribution. The variables to compute
					  are:
							- Percentile 90
							- Percentile 50
							- Percentile 10 
							- Meand
							- Standard Deviarion
							- Gini
					  
			- Part 2: Replicate Table 1 results using PM25 data for log gini indicator. 

*/

*************************************************************
* Part 1: Summary statistics
*************************************************************
	
**Compute Summary statistics for the following indicators using market income, O3 and PM25 data
			
	**1. Market Income data
	
	**Open SOI Zipcode data and deflate household income to 2011 dollars for each year (2005-2015)
	forvalues y = 2005/2015 {
		use "${datadir}Market_Income/SOI_zipcode_data_Update.dta", clear
		
		**Keep the 5 states with the higher average income and the 5 states with the lower average market income over the whole period
		tempvar aux1 aux2
		bys state: egen `aux1'=mean(a00100)
		egen `aux2'=group(`aux1' state)
		qui sum `aux2'
		
			**Keep relevant states
			keep if  `aux2'<=`r(min)'+4|`aux2'>=`r(max)'-4|state=="NY"
			
		**Sort states by average income (over the period) and tabulates them
		sort `aux1'
		tab state
		
		**Merge with inflation data 									
		keep if year==`y'														

		merge m:1 year using "${datadir}inflation_cpi.dta"
		drop if _merge==2
		drop _merge

		replace a00100 = a00100 * (1/inflation)									// deflate  household income (2011 US dollars)

		**Compute within state-year: gini,standard deviation, CV, IQR in household income.
		
			*Gini
			gen gini= .
			quietly {
				egen stateyear = group(state year)
				sum stateyear, d
				forvalues f = `r(min)'/`r(max)'{	
					fastgini a00100 if stateyear==`f'
					matrix gini = r(gini)
					replace gini = gini[1,1] if stateyear==`f'
					ineqdec0 a00100 if stateyear==`f', summ
				}
			}	

			drop if gini <=0 														// drop negative values
		
			*Create data with indicators (there are other ways)
			collapse (p90) HH90 = a00100 (p50) HH50 = a00100 (p10) HH10 = a00100 (sd) Var_HH = a00100 (mean) MU_HH = a00100 gini (iqr) IQR_HH = a00100, by(state year)

		**Save temporary files
		tempfile SOI_County_a00100_`y'
		save `SOI_County_a00100_`y'', replace		
	}

	clear
	forvalues y = 2005/2015 {
		append using `SOI_County_a00100_`y''
	}
	

	** Graph main indicators over time
	global ineqind HH90 HH50 HH10 MU_HH gini
	label var HH90 "90 percentile" 
	label var HH50 "50 percentile" 
	label var HH10 "10 percentile" 
	label var  MU_HH "Mean Household Income" 
	label var  gini "Gini"
	
	foreach k in $ineqind {
		# d ;
			twoway(line `k' year if state=="NY", lcolor(red) lwidth(0.5) lpattern(solid))
			(line  `k' year if state=="ND", lcolor(blue) lwidth(0.5)  lpattern(dash))
			,xtitle("Year")	
			title("Inequality Indicators - Market Income")
			legend(order(1 "New York" 2 "North Dakota")) bgcolor("white")  graphregion(color(white)) legend(region(style(none)))
		;
		# d cr
		graph export "${figdir}`k'_.png", replace
	}
	
	
	**1.2 PM25 DATA
	
		**Import data and keep relevan variables and years
		import delimited "${datadir}PM25/LUR_PM25_O3_1999_2015_Block_Group.csv", delimiter(comma) clear
		keep if pollutant=="pm25"
		drop pollutant
		keep if year>=2005
		rename state_abbr state

		**Keep the 5 states with the higher average income and the 5 states with the lower average market income over the whole period
		tempvar aux1 aux2
		bys state: egen `aux1'=mean(pred_wght)
		egen `aux2'=group(`aux1' state)
		qui sum `aux2'
		
			**Keep relevant states
			keep if  `aux2'<=`r(min)'+4|`aux2'>=`r(max)'-4|state=="NY"
			
		**Sort states by average income (over the period) and tabulates them
		sort `aux1'
		tab state

	**Compute within county-year/state-year: gini,standard deviation, CV, skewness, IQR in household income.
	gen gini_pm25 = .
	quietly{
		egen stateyear = group(state year)
		qui sum stateyear, d
		forvalues f = `r(min)'/`r(max)'{
			fastgini pred_wght if stateyear==`f'
			matrix gini_pm25 = r(gini)
			replace gini_pm25 = gini_pm25[1,1] if stateyear==`f'
			ineqdec0 pred_wght if stateyear==`f', summ
		}		
	}

	collapse (p90) pm2590 = pred_wght (p50) pm2550 = pred_wght (p10) pm2510 = pred_wght (sd) Var_pm25 = pred_wght (mean) MU_pm25 = pred_wght gini_pm25 (iqr) IQR_pm25 = pred_wght, by(state year)
	sort state year 
	
	** Graph main indicators over time
	global ineqind pm2590 pm2550  pm2510 MU_pm25 gini_pm25
	label var pm2590 "90 percentile" 
	label var pm2550 "50 percentile" 
	label var pm2510 "10 percentile" 
	label var MU_pm25 "Mean" 
	label var gini_pm25 "Gini" 
	
	foreach k in $ineqind {
		# d ;
			twoway(line `k' year if state=="NY", lcolor(red) lwidth(0.5) lpattern(solid))
			(line  `k' year if state=="WY", lcolor(blue) lwidth(0.5)  lpattern(dash))
			,xtitle("Year")	
			title("Inequality Indicators - PM25")
			legend(order(1 "New York" 2 "Wyoming")) bgcolor("white")  graphregion(color(white)) legend(region(style(none)))
		;
		# d cr
		graph export "${figdir}`k'_.png", replace
	}

	**1.3 O3 DATA
	
		**Import data and keep relevan variables and years
		import delimited "${datadir}PM25/LUR_PM25_O3_1999_2015_Block_Group.csv", delimiter(comma) clear
		keep if pollutant=="o3"
		drop pollutant
		keep if year>=2005
		rename state_abbr state
		
		**Keep the 5 states with the higher average income and the 5 states with the lower average market income over the whole period
		tempvar aux1 aux2
		bys state: egen `aux1'=mean(pred_wght)
		egen `aux2'=group(`aux1' state)
		qui sum `aux2'
		
			**Keep relevant states
			keep if  `aux2'<=`r(min)'+4|`aux2'>=`r(max)'-4|state=="NY"
			
		**Sort states by average income (over the period) and tabulates them
		sort `aux1'
		tab state

	**Compute within county-year/state-year: gini,standard deviation, CV, skewness, IQR in household income (using weights)
	gen gini_o3 = .
	quietly{
		egen stateyear = group(state year)
		qui sum stateyear, d
		forvalues f = `r(min)'/`r(max)'{
			fastgini pred_wght if stateyear==`f'
			matrix gini_o3 = r(gini)
			replace gini_o3 = gini_o3[1,1] if stateyear==`f'
			ineqdec0 pred_wght if stateyear==`f', summ
		}
	}

	collapse (p90) o390 = pred_wght (p50) o350 = pred_wght (p10) o310 = pred_wght (sd) Var_o3 = pred_wght (mean) MU_o3 = pred_wght gini_o3 (iqr) IQR_o3 = pred_wght, by(state year)
	sort state year

	** Graph main indicators over time
	global ineqind o390 o350 o310 MU_o3 gini_o3
	label var o390 "90 percentile" 
	label var o350 "50 percentile" 
	label var o310 "10 percentile" 
	label var MU_o3 "Mean" 
	label var gini_o3 "Gini" 
	
	foreach k in $ineqind {
		# d ;
			twoway(line `k' year if state=="NY", lcolor(red) lwidth(0.5) lpattern(solid))
			(line  `k' year if state=="WA", lcolor(blue) lwidth(0.5)  lpattern(dash))
			,xtitle("Year")	
			title("Inequality Indicators - O3")
			legend(order(1 "New York" 2 "Washington")) bgcolor("white")  graphregion(color(white)) legend(region(style(none)))
		;
		# d cr
		graph export "${figdir}`k'_.png", replace
	}	


*************************************************************
* Part 2: Replicate Table 1 results using PM25 data for log gini indicator.
*************************************************************

**Setup: Generate data for matching

	**Import data and keep relevant variables
	use "${datadir}PM25/LUR_PM25_county.dta", clear
	global varcap Log_Gini
	global regdata = 10

	keep if year>=2005
	keep if year<=2015
	drop if fips==.

	**Merge with population data
	merge m:1 fips year using "${datadir}county_population_long.dta"
	drop if _merge==2
	drop _merge

	**Logging variables
	capture gen CV_pm25 = Var_pm25/MU_pm25
	gen Log_MU_pm25 = log(MU_pm25)
	gen Log_CV_pm25 = log(CV_pm25)
	gen Log_Var_pm25 = log(Var_pm25)
	gen Log_IQR_pm25 = log(IQR)
	gen Log_90_50_pm25 = log(pm2590 - pm2550)
	gen Log_90_10_pm25 = log(pm2590 - pm2510)
	gen Log_Gini = log(gini)

	**Merge with NAAQS STANDARDS DATA
	merge m:1 fips year using "${datadir}compliance_history_clean_long.dta"
	drop if _merge==2
	drop _merge

	**Indicator of compliance (3 - O3 (2008) and 10 - PM25 (2006))
	gen indcomptotal = 0
	sort fips year
	forvalues i = 1/13{
		replace indcomp`i' = (indcomp`i'>0) & (indcomp`i'!=.)
		replace indcomptotal = indcomptotal + indcomp`i'
		by fips: egen everindcomp`i' = total(indcomp`i')
		replace everindcomp`i' = everindcomp`i'>0
	}
	
	tempfile a1
	save `a1', replace
	
	**Create compliance files (3 - O3 (2008) and 10 - PM25 (2006); 0: noncompliance and 1: compliance)
	foreach reg in 3 10 {
		foreach value in 0 1{
			preserve
				keep if everindcomp`reg'==`value'
				keep if year==2005
				keep fips ${varcap}
				duplicates drop
		
				rename  ${varcap} mean_income_`reg'_`value'
				gen fips_`reg'_`value' = fips
		
				gen index = 1
				
				tempfile temp_`reg'_`value'
				save `temp_`reg'_`value'', replace
			restore
		}
	}
	
		**Merge compliance and noncompliance files
		foreach reg in 3 10{
			use `temp_`reg'_0', clear
			joinby index using `temp_`reg'_1'

			gen abs_diff = abs(mean_income_`reg'_0 - mean_income_`reg'_1)	// Distance between non-attainment and always attainment counties
			sort fips_`reg'_1 abs_diff 	
			
			by fips_`reg'_1: gen count_obs = _n
			keep if count_obs<=10											// Pick always attainment counties with the smallest distance
			keep fips_`reg'_1 fips_`reg'_0 abs_diff
	
			tempfile matched_`reg'
			save `matched_`reg'', replace
		}

**MATCHED DATA SET
use `a1', clear
	
	*Always attainment data
	preserve
		keep if everindcomp${regdata}==1
		gen fips_${regdata}_1 = fips

		tempfile LUR_PM25_county_${regdata}_1
		save `LUR_PM25_county_${regdata}_1', replace
	restore

	*Non attainment data
	keep if everindcomp${regdata}==0
	gen fips_${regdata}_0 = fips

	*Merge with "matched" always attainment counties data
	joinby fips_${regdata}_0 using `matched_${regdata}'
	
	tempfile MATCHED_LUR_PM25_county_${regdata}_0
	save `MATCHED_LUR_PM25_county_${regdata}_0', replace

	**Matched data
	use `LUR_PM25_county_${regdata}_1', clear
	append using `MATCHED_LUR_PM25_county_${regdata}_0'

	**Weights
	drop fips_${regdata}_0
	gen constant = 1

	sort year fips_${regdata}_1 fips
	
	/*	Generate weights: each observation corresponding to county m is given sample 
		weight 1 while each observation corresponding to its matched always-attainment counties is given sample weight 0.1
	*/
	by year fips_${regdata}_1: egen weight = total(constant) 
	replace weight = 1/weight	
	replace weight = 1 if fips_${regdata}_1==fips

	egen fips_matched = group(fips fips_${regdata}_1) // Matched id

*************************************************************
* Matched regressions
*************************************************************

	capture reghdfe Log_Gini  indcomp10 indcomp9  [aw = weight] if year<2015, vce(cluster fips) absorb(fips year)
	if(_rc==0){
		outreg2 using "${tabdir}DD_PM25_LUR_control_by_standard10.doc", replace word excel slow(1000000)  label
	}
	
******************************************************************************
* Figures: Common trends assumption - Trends in Average Outcome
*		   Over Time For Ever-Nonattainment versus Always-Attainment Counties
******************************************************************************
global varattain = "indcomp10"
preserve
	keep if year<2015
	gen temp = year if ${varattain}==1
	egen fipsnum = group(fips)

	bys fipsnum: egen min_${varattain}_year = min(temp) 
	gen year_diff = year - min_${varattain}_year

	egen year_diff2 = min(min_${varattain}_year)
	replace year_diff2 = year - year_diff2

	bys year_diff2 ever${varattain}: egen mean_var = mean(${varcap}*pop)
	bys year_diff2 ever${varattain}: egen mean_pop = mean(pop)
	replace mean_var = mean_var/mean_pop

	**Plot
	twoway(line mean_var year_diff2 if ever${varattain}==0, lcolor(red) lwidth(0.5) lpattern(solid)) ///
	(line mean_var year_diff2 if ever${varattain}==1, lcolor(blue) lwidth(0.5)  lpattern(dash)) ///
	, ytitle("Mean of Dependent Variable") xtitle("Year - First Year Out of Attainment") title("Log Gini") ///
	legend(order(1 "Always In Attainment" 2 "Ever Out of Attainment")) bgcolor("white")  graphregion(color(white)) legend(region(style(none)))
	graph export "${figdir}log_gini_reg_.png", replace
	
restore		

log close

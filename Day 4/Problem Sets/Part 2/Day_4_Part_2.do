// Setup

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

*Directory
global repdir "${maindir}\Inequality Course Training Materials\Day 4\Problem Sets\Part_2\Data/"
cd "${repdir}" 

**************************************************************************	
* Table 3 - Summary Statistics: 
* Beneficiary and Non-Beneficiary Households
**************************************************************************	

// Variable Lists

*Columns
# d ;
global colvar
	benef
;
# d cr

*Rows
# d ;
global rowvar
	index_food 
	indexcons2011
	indexhome2011
	tot_ganado2011
	smallanimals2011
	liveinfra2011
	aginput2011
	agequip2011
	indexcons2007 
	indexhome2007  
	tot_ganado2007 
	smallanimals2007
	liveinfra2007 
	aginput2007 
	agequip2007 
	elevmn 
	slopemn 
	d5000 
	mpov05
	area 
	hhsize
	ejidatario 
	adays2007 
	parti_fma2007
	highrisk
;
# d cr

*Selection Variables
# d ;
global selvar
	indexcons2011
	indexhome2011
	tot_ganado2011
	smallanimals2011
	liveinfra2011
	aginput2011
	agequip2011
	highrisk
;
# d cr

*Matching Variables
# d ;
global matvar
	particom2007
	region
	folio_captura
;
# d cr

*All Variables
global allvar $colvar $rowvar $selvar $matvar

// Data Setup

*1. Common Properties
# d ;
use "${repdir}onetree_data_eji021114v2", clear
;
# d cr

*Tag Sample
gen complete_sample = 1 if index_food~=. & indexcons2007~=. & indexcons2011~=. & indexhome2007~=. & indexhome2011~=. & ///
                           tot_ganado2007~=. & tot_ganado2011~=. & smallanimals2007~=. & smallanimals2011~=. & ///
						   liveinfra2007~=. & liveinfra2011~=. & aginput2007~=. & aginput2011~=. & ///
						   agequip2007~=. & agequip2011~=. &  d5000~=. & hhsize~=. & mpov05~=. & elevmn~=. & ejidatario~=. & highrisk~=.
keep if complete_sample == 1
tempfile common_properties
save `common_properties', replace

*2. Private Properties
# d ;
use "${repdir}onetree_data_priv021114v2", clear
;
# d cr

*Tag Sample
gen complete_sample = 1 if index_food~=. & indexcons2007~=. & indexcons2011~=. & indexhome2007~=. & indexhome2011~=. & ///
                           tot_ganado2007~=. & tot_ganado2011~=. & smallanimals2007~=. & smallanimals2011~=. & ///
						   liveinfra2007~=. & liveinfra2011~=. & aginput2007~=. & aginput2011~=. & ///
						   agequip2007~=. & agequip2011~=. &  d5000~=. & hhsize~=. & mpov05~=. & elevmn~=.
keep if complete_sample == 1
tempfile private_properties
save `private_properties', replace

*3. Matched Sample
# d ;
use "${repdir}onetree_data_eji021114v2", clear
;
# d cr

*Common Properties Data
gen complete_sample = 1 if index_food~=. & indexcons2007~=. & indexcons2011~=. & indexhome2007~=. & indexhome2011~=. & ///
                           tot_ganado2007~=. & tot_ganado2011~=. & smallanimals2007~=. & smallanimals2011~=. & ///
						   liveinfra2007~=. & liveinfra2011~=. & aginput2007~=. & aginput2011~=. & ///
						   agequip2007~=. & agequip2011~=. &  d5000~=. & hhsize~=. & mpov05~=. & elevmn~=. & ejidatario~=. & highrisk~=.
keep if complete_sample==1

*Id's
sort folio_captura
gen num=_n

* Match on baseline cooperation levels
rename parti_fma2007 par2007
rename particom2007 particom
rename adays2007 day2007
cd "${repdir}"
nnmatch num benef par2007 day2007 particom, tc(att) metric(maha) m(5) exact(region) keep(matches_coop) replace

*Get Distance Metric
gen dist_match = .
foreach n in 0 1{
	preserve
	use "${repdir}matches_coop", clear
	keep dist num_`n'
	ren (dist num_`n') (dist_match_`n' num)
	sort num dist_match
	by num: keep if _n == 1
	tempfile tomerge
	save `tomerge', replace
	restore
	merge 1:1 num using `tomerge', gen(_match_`n')
	replace dist_match = dist_match_`n' if _match_`n' == 3
}


*Tag Matched Sample
egen trim95 = pctile(dist_match), p(95)
keep if dist_match < trim95
tempfile matched_sample
save `matched_sample', replace

// Tables

*Preamble
putexcel B1:G1 = ("Full Sample") using "${repdir}mainstats.xls", replace
putexcel H1:J1 = ("Full Sample") using "${repdir}mainstats.xls", modify

putexcel B2:D2 = ("Common properties") using "${repdir}mainstats.xls", replace
putexcel E2:G2 = ("Private properties") using "${repdir}mainstats.xls", modify
putexcel H2:J2 = ("Matched Sample") using "${repdir}mainstats.xls", modify

putexcel B3 = ("Beneficiary") using "${repdir}mainstats.xls", modify
putexcel C3 = ("Non-Beneficiary") using "${repdir}mainstats.xls", modify
putexcel D3 = ("Norm. Diff.") using "${repdir}mainstats.xls", modify

putexcel E3 = ("Beneficiary") using "${repdir}mainstats.xls", modify
putexcel F3 = ("Non-Beneficiary") using "${repdir}mainstats.xls", modify
putexcel G3 = ("Norm. Diff.") using "${repdir}mainstats.xls", modify

putexcel H3 = ("Beneficiary") using "${repdir}mainstats.xls", modify
putexcel I3 = ("Non-Beneficiary") using "${repdir}mainstats.xls", modify
putexcel J3 = ("Norm. Diff.") using "${repdir}mainstats.xls", modify

*Row Names
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	local row: variable label `var'
	putexcel A`j' = ("`row'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}	
putexcel A`j' = ("Number of Observations") using "${repdir}mainstats.xls", modify

*1. Common Properties
use `common_properties', clear

*First Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 1
	putexcel B`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 1
putexcel B`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Second Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 0
	putexcel C`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 0
putexcel C`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Third Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	ttest `var', by (benef)
	gen norm`var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2))
	qui sum norm`var' if benef == 0
	putexcel D`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}

*2. Common Properties
use `private_properties', clear

*First Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 1
	putexcel E`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 1
putexcel E`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Second Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 0
	putexcel F`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 0
putexcel F`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Third Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	ttest `var', by (benef)
	gen norm`var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2))
	qui sum norm`var' if benef == 0
	putexcel G`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}

*3. Matched Sample
use `matched_sample', clear

*First Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 1
	putexcel H`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 1
putexcel H`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Second Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	qui sum `var' if benef == 0
	putexcel I`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}
count if benef == 0
putexcel I`j' = ("`r(N)'") using "${repdir}mainstats.xls", modify

*Third Column
local j = 4
foreach var in index_food indexcons2007 indexhome2007  tot_ganado2007 smallanimals2007 ///
	liveinfra2007 aginput2007 agequip2007 elevmn slopemn d5000 mpov05 ///
	area hhsize{
	ttest `var', by (benef)
	gen norm`var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2))
	qui sum norm`var' if benef == 0
	putexcel J`j' = ("`r(mean)'") using "${repdir}mainstats.xls", modify
	local j = `j' + 1
}

*************************************	
* Table 4:
* Impacts of PSAH on NDVI
*************************************	

// Variable Lists

*Dependent Variable
# d ;
global yvar 
	mndvi
;
# d cr

*Treatment Variables
# d ;
global tvar
	recipL 
	time_recipL 
	recipL_recipyrs
;
# d cr

*Control Variables
# d ;
global xvar
	time
	mndvi2003 
	lnslope 
	lnelev 
	dloc5000 
	im_00 
	bos_mesofi 
	sobreexp 
	z_disp 
	montana 
	majindig
	lndry 
	lnfull 
	st_dev_rf 
	hurricane
	vegcat
;
# d cr	

*Fixed Effect Variables
# d ;
global fevar
	year
	state
;
# d cr

*Cluster Variables
# d ;
global cvar
	id
	polyfid
;
# d cr

*All Variables
global allvar $yvar $tvar $xvar $fevar $cvar

// Estimation Proceduere

*Call Dataset
use $allvar using "${repdir}matchedpnts-maha-wreplace_final.dta", clear
ren year trend
gen year = trend + 2000 // So as to tag years
*keep if inrange(runiform(),0,0.05)

*Point fe, no time trend
xi: xtreg mndvi recipL lndry lnfull st_dev_rf hurricane i.year*i.state, fe i(id) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs
	noni
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in levels (1)")
	title("Annual mean dry season NDVI (points data)")
	addtext(Point FE, Yes)
	keep(recipL)
	label
	replace
;
# d cr

*Point fe with time trend times recipL
xi: xtreg mndvi time time_recipL lndry lnfull st_dev_rf hurricane i.year*i.state, fe i(id) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs 
	noni	
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in trend (2)")
	addtext(Point FE, Yes)
	keep(time_recipL)
	label
	append
;
# d cr


*Point fe with recipyrs
xi: xtreg mndvi recipL recipL_recipyrs lndry lnfull st_dev_rf hurricane i.year*i.state, fe i(id) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs
	noni
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in level and years in program (3)")
	addtext(Point FE, Yes)	
	keep(recipL recipL_recipyrs)
	label
	append
;
# d cr

*Poly no time trend adding all controls (only 2004 and after)
keep if year > 2003
xi: xtreg mndvi recipL mndvi2003 lnslope lnelev dloc5000 im_00 bos_mesofi sobreexp z_disp montana majindig ///
	i.vegcat lndry lnfull st_dev_rf hurricane i.year*i.state if year > 2003, fe i(polyfid) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs
	noni
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in levels (4)")
	addtext(Parcel FE, Yes)	
	keep(recipL)
	label
	append
;
# d cr


*Poly with time trend and all controls
xi: xtreg mndvi time time_recipL mndvi2003 lnslope lnelev dloc5000 im_00 bos_mesofi sobreexp z_disp montana majindig ///
	i.vegcat lndry lnfull st_dev_rf hurricane i.year*i.state if year > 2003, fe i(polyfid) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs
	noni
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in trend (5)")
	addtext(Parcel FE, Yes)		
	keep(time_recipL)
	label
	append
;
# d cr

*Poly with recipyrs
xi: xtreg mndvi recipL recipL_recipyrs mndvi2003 lnslope lnelev dloc5000 im_00 bos_mesofi sobreexp z_disp montana majindig ///
	i.vegcat lndry lnfull st_dev_rf hurricane i.year*i.state if year > 2003, fe i(polyfid) robust cluster(polyfid)
# d ;
outreg2 using "${repdir}maineffects.xls", 
	br 
	se 
	bdec(3) 
	nocons 
	noobs 
	noni
	adds("Observations Total", e(N), "Observation Points", e(N_g), "Observation Parcels", e(N_clust)) 
	ctitle("Change in level and years in program (6)")
	addtext(Parcel FE, Yes)	
	keep(recipL recipL_recipyrs)
	label
	append
;
# d cr

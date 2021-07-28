// Setup
version 15.1
macro drop _all
clear 
clear mata
clear matrix
set more off, permanently
set mem 10g
set maxvar 12000
cap log close
set excelxlsxlargefile on
 
** User Written Commands
foreach c in wid{
	cap which `c'
	if _rc cap ssc install `c'
}


*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (Personal)/New Climate Economy/Course/Day 4/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/Course/Day 4/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/Course/Day 4/"

*************************************************************
* 1. RCT: BjÖrkman and Jayachandran (2017) 
*************************************************************
*****************************************************************************************
/* Case 1: BjÖrkman and Jayachandran (2017), "Mothers Cares More, But Fathers Decide: Eduacting
		   Parents about Child Health in Uganda", American Economic Review: Papers and
		   Proceedings 2017, 107(5): 496-500
	
	*Abstract: Research on intrahousehold decision-making generally finds that fathers 
			   have more bargaining power than mothers, but mothers put more weight on 
			   children's well-being. This suggests a tradeoff when targeting policies 
			   to improve child health: fathers have more power to change household 
			   behavior in ways that improve child health, but mothers might have a 
			   stronger desire to do so. This paper compares health classes in Uganda 
			   that enrolled either mothers or fathers. We find that educating mothers 
			   leads to greater adoption of health-promoting behaviors by the household. 
			   In addition, educating one parent leads to positive spillovers on the other 
			   spouse's health behaviors.*/

*****************************************************************************************
use "${repdir}day_4_rct_1.dta", clear

**Setup

**Compute balance: Health and decision-making power for women and men
matrix define balance_test_k=J(2,2,.)
matrix define balance_test_d=J(2,2,.)

	**Women
	local i= 1
	foreach var in w_WHknowl_index m_WHknowl_index {
		sum `var'
		local m`i': di %7.3f r(mean)
		local sd`i': di %7.3f r(sd)
		local sd`i'=strtrim("`sd`i''")
		matrix define balance_test_k[1,`i']=`m`i''
		matrix define balance_test_k[2,`i']=`sd`i''
		local ++i
	}
	**Men
	local i=1
	foreach var in  w_avg_decisonwife m_avg_decisonhusb {
		sum `var'
		local m`i': di %7.3f r(mean)
		local sd`i': di %7.3f r(sd)
		local sd`i'=strtrim("`sd`i''")
		matrix define balance_test_d[1,`i']=`m`i''
		matrix define balance_test_d[2,`i']=`sd`i''
		local ++i

	}
matrix define balance_test=(balance_test_k\ balance_test_d)

*Impacts on Health knowledge and health behavior
local control district health_index3 health_index3_flag ///
					log_hhwage log_hhwage_flag gender_index gender_index_flag

	foreach var in Eattend Eparticipant_WHknowl Espouse_WHknowl {
	
		if "`var'"=="Eparticipant_WHknowl" {
			//Participant/spouse's knowledge
			foreach x in "" "E" {
				gen `x'participant_WHknowl=`x'w_WHknowl_index if whn==1
					replace `x'participant_WHknowl=`x'm_WHknowl_index if mhn==1
					
				gen `x'spouse_WHknowl=`x'w_WHknowl_index if mhn==1
					replace `x'spouse_WHknowl=`x'm_WHknowl_index if whn==1
				}
				
			// Expand control sample, include 2 observations for each spouse
				expand 2 if control==1, gen(x) //x==1 is men
				
				*Hknowl
				foreach x in "" "E" {
					replace `x'participant_WHknowl=`x'w_WHknowl_index if x==0 & control==1
					replace `x'participant_WHknowl=`x'm_WHknowl_index if x==1 & control==1

					replace `x'spouse_WHknowl=`x'w_WHknowl_index if x==1 & control==1
					replace `x'spouse_WHknowl=`x'm_WHknowl_index if x==0 & control==1
					}

			//Participant's gender (1=woman)
				gen D_woman=0
					replace D_woman=1 if whn==1 | (x==0 & control==1)		
			}
		
	if "`var'"=="Eattend" areg `var' whn mhn `control', a(stratum) cluster(villageid)
		if "`var'"!="Eattend" areg `var' whn mhn participant_WHknowl spouse_WHknowl `control' D_woman, a(stratum) cluster(villageid)
			local c1: di %7.3f _b[whn]
			local se1: di %7.3f _se[whn]
				local se1=strtrim("`se1'")
			local c2: di %7.3f _b[mhn]
			local se2: di %7.3f _se[mhn]
				local se2=strtrim("`se2'")
			local n: di %9.0fc e(N)
				test whn=mhn
			local pv: di %7.3f r(p)
			
			local whn `whn' & `c1'
			local whn_se `whn_se' & (`se1')
			local mhn `mhn' & `c2'
			local mhn_se `mhn_se' & (`se2')
			local N `N' & `n'
			local pval `pval' & `pv'
		}
		

*************************************************************
* 2. RCT: Blattman & Dercon (2018) 
*************************************************************

/* Case 2: Blattman and Dercon (2018), "The Impacts of Industrial and Entrepreneurial Work on
Income and Health: Experimental Evidence from Ethiopia", American Economic Journal: Applied Economics, 1–38 
	
	* Abstract:Working with five Ethiopian firms, we randomized applicants to an
				industrial job offer, an “entrepreneurship” program of $300 plus
				business training, or control status. Industrial jobs offered more and
				steadier hours but low wages and risky conditions. The job offer doubled
				exposure to industrial work but, since most quit within months,
				had no impact on employment or income after a year. Applicants
				largely took industrial work to cope with adverse shocks. This
				exposure, meanwhile, significantly increased health problems. The
				entrepreneurship program raised earnings 33 percent and provided
				steadier hours. When barriers to self-employment were relieved,
				applicants preferred entrepreneurial to industrial labor.Each observation is for an individual. 
			

*/
**Setup
use "${repdir}day_4_rct_2.dta", clear
	
	** Set globals (baseline and outcomes)
	
	*Baseline controls
	# delimit ;
		global baseline_larger "exactage_p99_b female_b
					single_b r_muslim_b hhsize_b head_b  dep_worker_p99_b educ_p99_b executive_score_b
					totalprofit7_av_p99_b consdur_p99_std_b factory_b 
					hourswork_wk_p99_b nowork_4weeks_b
					incdiff12_permon_p99_b borr3000bus_p99_b healthproblems_p99_b  disabled_b
					riskaversion_all_b patience_all_b locuscontrol_p99_std_b selfesteem_p99_std_b 
					famsupport_std_b commsupport_std_b  
					stat_change1_b phqtotal_r_std_b gadtotal_r_std_b agression_std_b consc_std_b fac_expery_b shop_expery_b statengo_expery_b
					prob_betterjob_b prob_regwork_b";
	# delimit cr

	*Outcomes

	# delimit ;	
		global incomevars "incomefamilyindex_e 
					totalprofit7_av_p99_e totalprofit_h_av_p99_e totalprofit_sqdev_e
					consdur_p99_std_e cons_month_p99_e proddur_p99_std_e";
	# delimit cr
	
	*Controls
	global demo "exactage_p99_b age2_p99_b age3_p99_b age4_p99_b female_b single_b r_muslim_b hhsize_b head_b dep_worker_p99_b"
	global cog "all_math_p99_b educ_p99_b cognitive_score_b executive_score_b finsecondary_b"
	global econ "totalprofit7_av_p99_b consdur_p99_std_b proddur_p99_std_b debttotal_p99_b save4weeks_p99_b"
	global work "aghours_wk_p99_b cashours_wk_p99_b facthours_wk_p99_b pettybusnhours_wk_p99_b skilledhours_wk_p99_b wagelowhours_wk_p99_b wagemedhours_wk_p99_b othhours_wk_p99_b nowork_2weeks_b"
	global exper "factory_b agexper_mo_p99_b casexper_mo_p99_b factexper_mo_p99_b pettybusnexper_mo_p99_b skilledexper_mo_p99_b wagelowexper_mo_p99_b wagemedexper_mo_p99_b othexper_mo_p99_b fac_expery_b shop_expery_b state_expery_b ngo_expery_b "
	global optim "becomeill_b prob_betterjob_b prob_regwork_b mid12months_b incdiff30_b incdiff12_permon_p99_b"
	global support "borr3000bus_p99_b famsupport_std_b commsupport_std_b"
	global health "healthproblems_p99_b disabled_b stat_change1_b phqtotal_r_std_b gadtotal_r_std_b"
	global personality "riskaversion_ibm_b riskaversion_p99_b patience_ibm_b timeinc_ibm_b patience_p99_b locuscontrol_p99_std_b selfesteem_p99_std_b selfcontrol_p99_std_b agression_std_b consc_std_b"
	
	global controls "$demo $cog $econ $work $exper $optim $support $health $personality"
	
	*Cohort dummies
	global cohort "coh1 coh2 coh3 coh4 coh5 coh6 coh7 coh8" 
	global blocks "coh1m coh2m coh3m coh4m coh5m coh6m coh7m coh8m coh1f coh2f coh3f coh4f coh5f coh6f coh7f coh8f"
		
					


	*Tests of Baseline Balance (by-hand)
	local i = 0			
	foreach var in $baseline_larger {
		local ++i
		local var`i' = "`var'"
		
		/* Control Mean */
		qui sum `var' if round_b == 1 & treatment_b == 0
			local cm`i' = r(mean)
			local csd`i' = r(sd)
			local cN`i' = r(N)
		/* Jobs */
		qui sum `var' if round_b == 1 & treatment_b == 1
			local job_m`i' = r(mean)
			local job_sd`i' = r(sd)
			local job_N`i' = r(N)
		/* NGO */
		qui sum `var' if round_b == 1 & treatment_b == 2
			local ngo_m`i' = r(mean)
			local ngo_sd`i' = r(sd)
			local ngo_N`i' = r(N)
		/* Job vs. Control Difference */
		qui reg `var' job ${blocks} if round_b == 1 & ngo!=1, robust
			local job_b`i' = _b[job]
			qui testparm job
			local job_p`i' = r(p)
		/* NGO vs. Control Difference */
		qui reg `var' ngo ${blocks} if round_b == 1 & job!=1, robust
			local ngo_b`i' = _b[ngo]
			qui testparm ngo
			local ngo_p`i' = r(p)
	}
		
		**Create Table (another option is to fill  a matrix and export it with 'putexcel')
		local I = `i'
		preserve
			clear
			qui set obs `I'
			qui gen var = ""
			foreach v in cm csd cN job_m job_sd job_N ngo_m ngo_sd ngo_N job_b job_p ngo_b ngo_p {
				qui gen `v' = .
			}
			forvalues i = 1/`I' {
				qui replace var =  "`var`i''" in `i'
				foreach v in cm csd cN job_m job_sd job_N ngo_m ngo_sd ngo_N job_b job_p ngo_b ngo_p {
					qui replace `v' = ``v'`i'' in `i'
				}				
			}
			export excel using "${repdir}rct2_table1.xlsx", sheet(raw) sheetreplace firstrow(var)
		restore
	
		
	*ITT INCOME (by-hand)	

		local i = 0
		foreach y in $incomevars {

			*Increment counter 
			local ++i
			*Get var label
			local var`i': var lab `y'

			* Set sample
			if ("`y'" == "totalcash_absdev_e" | "`y'" == "totalcash_sqdev_e" | "`y'" == "totalprofit_absdev_e" | "`y'" == "totalprofit_sqdev_e") {
				local sample1 "round<=2 & found_av == 1"
			}
			else {
				local sample1 "round<=3 & found == 1"
			}
			
			*Get means and SD by treatment status
			qui sum `y' if treatment_b == 1 & `sample1'
				local m_job`i' = r(mean)
				local sd_job`i' = r(sd)
			qui sum `y' if treatment_b == 2 & `sample1'
				local m_ngo`i' = r(mean)
				local sd_ngo`i' = r(sd)
			qui sum `y' if treatment_b == 0 & `sample1'
				local m_control`i' = r(mean)
				local sd_control`i' = r(sd)
			qui count if !missing(`y') & `sample1'
				local N`i' = r(N)
				
			*Run ITT regression
			 qui reg `y' job ngo ${blocks} ${controls} i.round if `sample1', robust cluster(appid) 
			
				*Coefficient for job recipients
				local b_ittjob`i' = _b[job]
				local se_ittjob`i' = _se[job]
				local p_ittjob`i' = 2*ttail(e(df_r),abs(_b[job]/_se[job]))
				
				*Coefficient for cash recipients
				local b_ittngo`i' = _b[ngo]
				local se_ittngo`i' = _se[ngo]
				local p_ittngo`i' = 2*ttail((e(N)-1)-e(df_m),abs(_b[ngo]/_se[ngo]))
				
				*Recover N
				local Nreg`i' = e(N)
				qui lincom job - ngo
						local b_diff`i' = r(estimate)
						local se_diff`i' = r(se)
						local p_diff`i' = 2*ttail(e(df_r),abs(r(estimate)/r(se)))
						
		}
		
		*Create matrix for results
		local I = `i'
		preserve
			clear
			qui set obs `I'
			foreach x in var m_job sd_job m_ngo sd_ngo m_control sd_control N b_ittjob se_ittjob b_ittngo se_ittngo Nreg b_diff se_diff {
				qui gen `x' = ""
				forvalues i = 1/`I' {
					qui replace `x' = "``x'`i''" in `i'
				}
			}
			qui destring m_job sd_job m_ngo sd_ngo m_control sd_control N b_*, replace
			export excel using "${repdir}/rct_table2.xlsx", sheet(raw) sheetreplace firstrow(var)
		restore
		
*************************************************************
* 2. Matching
*************************************************************

/* Case 1: R.H. Dehejia and S. Wahba (1999), "Causal Effects in Nonexperimental Studies: 
	reevaluating the Evaluation of Training Programs", JASA, 1053-1062 
	
	* Each observation is for an individual. 
	* There are 2,675 observations: 185 in treated group and 2490 in control

	* Variables are :
  						- TREAT 1 if treated (NSW treated) and 0 if not (PSID-1 control)
						- AGE   in years
						- EDUC  in years   
						- BLACK 1 if black
						- HISP  1 if hispanic
						- MARR  1 if married
						- RE74  Real annual earnings in 1974  (pre-treatment)
						- RE75  Real annual earnings in 1974  (pre-treatment)
						- RE78  Real annual earnings in 1974  (post-treatment)
						- U74   1 if unemployed in 1974
						- U75   1 if unemployed in 1974

 **NOTE: U74 and U75 are miscoded in these data and also in the 
       summary statistics table of DW02
       See below for correction to data
*/
	
*Setup: Read data, set seed and set globals
use "${repdir}day_4_matching_1.dta", clear
set seed 10101

global mainvars AGE EDUC NODEGREE BLACK HISP MARR U74 U75 RE74 RE75 RE78 TREAT AGESQ EDUCSQ RE74SQ RE75SQ U74BLACK U74HISP  // Main variables
global nreps 200 																											// N° of replications
global regressors AGE AGESQ EDUC EDUCSQ MARR NODEGREE BLACK HISP RE74 RE75 RE74SQ U74 U75 U74HISP								// Regressors

*Descriptive statistics: Entire data and by treatment
sum $mainvars
bys TREAT: sum $mainvars

**Two different approaches 

	*1. attnd + pscore command
	
		*1.1 Compute propensity score using 'pscorep command
		pscore TREAT $regressors, pscore(myscore) comsup blockid(myblock) numblo(5) level(0.005) logit  
		predict treat_hat
	
		*1.2 Analize distribution of common support
		twoway (kdensity treat_hat if TREAT==0) (kdensity treat_hat if TREAT==1)
		psgraph, t(TREAT) pscore(myscore) support(comsup)

		*1.3 Compute att using 'attnd' command (Nearest neighbor matching and Radius matching)

			/* We are computing using bootstrap, so it might take a little more time than usual!*/
			
			*Nearest neighbor matching 
			attnd RE78 TREAT $XDW02 RE75SQ, comsup boot reps($nreps) dots logit  
			attnd RE78 TREAT $XDW02, comsup boot reps($nreps) dots logit

			*Radius matching for Radius=0.001
			attr RE78 TREAT $XDW02 RE75SQ, comsup boot reps($breps) dots logit radius(0.001)
			attr RE78 TREAT $XDW02, comsup boot reps($breps) dots logit radius(0.001)
		
	*2. psmatch2 command 
	
		*2.1 Compute propensity score using 
		pscore TREAT $regressors, pscore(myscore) comsup blockid(myblock) numblo(5) level(0.005) logit   
		logit TREAT $regressors
		predict treat_hat
	
		*2.2 Compute att using 'psmatch2' command (Nearest neighbor matching and Radius matching)
		
			*Nearest neighbor matching 
			psmatch2 TREAT ${regressors}, out(RE78) common logit

			*Radius matching for Radius=0.001
			psmatch2 TREAT ${regressors}, out(RE78) common radius caliper(0.001) logit

		*2.3 Test balance with 'pstest' command
		pstest $regressors, both support(comsup)  graph graphregion(color(white))
		
		
	**There is another command named 'teffects' introduced with Stata 13, but the most popular is by far 'psmatch2'

/* Case 2: Chilean Social protection survey 2006 
	
	 **Analyze relation between income and being married
	 
	 Step 1: Use job history data and keep last job information:
		
		- Keep id, income last month, last year andt activity variales
		
	 Step 2: Merge with socioeconomic data and keep relevant variables:
	 
		- Keep id, income last month, last year andt activity variales + sex, birth place, age, marital status and region

	 Step 3: Generate variables for analysis: Gender, income and married
	 
		**Income: create and additional income variable named income2 and drop all the observations with values over 10000000 
	 	 	 
*/

*Setup: Read data, set seed and set globals
use "${repdir}day_4_matching_historialaboral_06.dta", clear

	**1. Keep last job history history; keep relevant variables variables
	bys folio: egen morden=max(orden)
	drop if morden!=orden
	keep  folio  b2 b1tm b1ta actividad b12
	
	tempfile last_job
	save `last_job', replace

	*2. Merge socioeconomic data and labor history data
	use "${repdir}day_4_matching_entrevistado_06.dta", clear
	merge 1:1 folio using  `last_job'

		*Keep relevant variables
		keep region  i1 a6a a8 a9 b2 b1tm b1ta actividad b12 a12n

	 *3. Generate variables for analysis: Gender, income and married

		*Married
		gen married=0
		replace married=1 if i1==1 | i1==3 | i1==4 | i1==6 | i1==8

		*Sex
		rename a8 sex
		replace sex=0 if sex==2

		*Income
		format %30.0g b12
		rename b12 income

		gen income2=income
		replace income2=. if income>10000000

*Compute ATT using psmatch2
	
	*Generate the propensity score using a probit regression: married vs. sex + a6a + a9
	probit married sex  a6a a9 if income!=0 & income2!=.
	predict married_hat

		*Graphical analysis of common support
		twoway (kdensity married_hat if married==0) (kdensity married_hat if married==1)
		psgraph, t(TREAT) pscore(married_hat)


	**Matching 1-on-1
	psmatch2 married sex a6a a9, out(income2)

	**Nearest Neighbour
	psmatch2 married sex a6a a9, out(income2) n(5)
	pstest sex a6a a9, both  graph graphregion(color(white))


*************************************************************
* 3. Difference-in-Difference (DID) - Panel regression
*************************************************************

/* Case 1:  Ian Ayres and John J. Donohue III (2003) "Shooting Down the ‘More Guns Less Crime", 
			Stanford Law Review, 1193-1312.
	
	**Growth is a balanced panel of data on 50 US states, plus the District of Columbia (for a
	  total of 51 “states”), by year for 1977 – 1999. Each observation is a given state in a given
	  year. There are a total of 51 states × 23 years = 1173 observations. We will analyze the relation
	  betweenof shall-issue laws on violent crime rates
	  
	 **Variables definitions:
	 
		- vio : violent crime rate (incidents per 100,000 members of the population)
		- rob : robbery rate (incidents per 100,000)
		- mur :murder rate (incidents per 100,000)
		- shall : = 1 if the state has a shall-carry law in effect in that year; = 0 otherwise
		- incarc_rate: incarceration rate in the state in the previous year (sentenced
		- prisoners: per 100,000 residents; value for the previous year)
		- density: population per square mile of land area, divided by 1000
		- avginc: real per capita personal income in the state, in thousands of dollars
		- pop: state population, in millions of people
		- pm1029: percent of state population that is male, ages 10 to 29
		- pw1064: percent of state population that is white, ages 10 to 64
		- pb1064: percent of state population that is black, ages 10 to 64
		- stateid: ID number of states (Alabama = 1, Alaska = 2, etc.)
		- year: Year (1977-1999)  
*/

*Setup: Read data, set seed and set globals
use "${repdir}day_4_panel_data_guns.dta", clear

	**Generate the logarithm of the violent rate
	gen lnvio=ln(vio)
	
	**Check if there is variation over the variable of interest (shall) --- As an example we will check for year 99
	bys  stateid: egen des_state=sd(shall)
	gen ddes_stata=0
	replace ddes_stata=1 if des_state!=0
	tab ddes_stata if year==99             

	**1. Analyze two periods - '95 and '96
	preserve
		keep if year==96| year==95

		**First run a simple regression on the whole sample: lnvio vs. shall
		reg lnvio shall, r
		reg lnvio shall incarc_rate density avginc pop pb1064 pw1064 pm1029, r
	restore


	**2. Set panel data and run fixed effects regressions
	xtset stateid year, year
	
		*Approach 1: 'xtreg'
		xtreg lnvio shall if year==96 | year==95, fe

		*Approach 2: Using factor variables 'i.'
		xi: reg lnvio shall i.state if year==96 | year==95, r

		
/* Case 2:  Gary V. Engelhardt and Jonathan Gruber (2011) "Medicare Part D and the Financial Protection of the Elderly", 
			American Economic Journal: Economic Policy, Vol. 3, No. 4 (November 2011), pp. 77-102.
	
	**Abstract: We examine the impact of the expansion of public prescription-drug
				insurance coverage from Medicare Part D and find evidence of
				substantial crowd-out. Using the 2002-2007 waves of the Medical
				ExpenditureP anel Survey; we estimatet he extensiono f Part D benefits
				resulted in 75 percent crowd-out of both prescription-drug
				insurancec overage and expenditureso f those6 5 and older.P art D is
				associated withs izeable reductionsi n out-of-pockestp ending, much
				of whichh as accrued to a small proportiono f the elderly. On average
				,we estimatea welfareg ainf romP art D comparable to the dead-weight
				cost ofp rogramf inancing
	 
*/

**Part 1: Replicate graphical evidence on the age of profile of prescription-drug coverage before and after the enanctment of Part D

	*Setup: Read data, set seed and set globals
	use "${repdir}day_4_panel_data_medicare2.dta", clear

	*Adjustments before graph
	keep if rage<=80
	drop if year==2006
	
	gen hhid=rwho_ref
	gen hhidpn=rdupersid

	keep rage year rdrxacov rdrxgcov2
	gen dpost=year==2007
	collapse rdrxacov rdrxgcov2, by(rage dpost)   // Collapse data
	
	*Labels
	label var rage "Respondent's Age"
	label var dpost "After Enactment"
	label var rdrxacov "Any Rx Coverage"
	label var rdrxgcov2 "Public Rx Coverage"
	compress


	*Replicate figure 1 (You can use any color you want)
	twoway (line rdrxacov rage if dpost==0 & rage>=50 & rage<=80, lcolor(black)) ///
	(line rdrxgcov2 rage if dpost==1 & rage>=50 & rage<=80, clpat(shortdash_dot) lcolor(black) ///
	yaxis(2) ytitle(Public Take-Up Rate After Enactment, axis(2)) ylabel(, angle(horizontal) axis(2)) yscale(titlegap(3) axis(2))) ///
	(line rdrxacov rage if dpost==1 & rage>=50 & rage<=80, lcolor(black) clpat(longdash) ///
	ytitle(Coverage Rate Before and After Enactment) ///
	yscale(titlegap(3)) ylabel(, angle(horizontal) labels grid nogmax nogmin glwidth(none) glcolor(none) nogextend) ///
	ymlabel(, noticks nolabels tlcolor(none) labcolor(none) labsize(zero)) xtitle(Age) ///
	xlabel(50 55 60 65 70 75 80, labels) xscale(titlegap(3)) ///
	title(Figure 1. Age Profile of Prescription Drug Coverage, size(medium) color(none)) ///
	subtitle(Before and After the Enactment of Part D) ///
	legend(on notextfirst nostack cols(1) all label(3 "Public Take-Up After Enactment (right-hand axis)") label(1 "Before Enactment, 2002-2005 (left-hand axis)") label(2 "After Enactment, 2007 (left-hand axis)")) ///
	legend(region(fcolor(none) lcolor(none) lstyle(none))) ///
	graphregion(fcolor(white) lcolor(white) lwidth(none) ifcolor(none) ilcolor(none) ilwidth(none)) ///
	plotregion(fcolor(none) lcolor(none) lwidth(none) ifcolor(none) ilcolor(none) ilwidth(none))) 
	graph export "${repdir}did_figure_1.png", replace
	
	
**Part 2: Replicate table 3 of the paper: Difference-in-Difference evidence
	
	*Setup: Read data, set seed and set globals
	use "${repdir}day_4_panel_data_medicare1.dta", clear


	***Panel A***;
	xi: reg rdrxacov if dpost==0 & rdage65==0, cluster(clustid)
	outreg2 using "${repdir}table3_panela_mn", replace ctitle(before mean below) nonotes nor2 noaster word
	xi: reg rdrxacov if dpost==0 & rdage65==1, cluster(clustid)
	outreg2 using "${repdir}table3_panela_mn", append ctitle(before mean above) nonotes nor2 noaster word
	xi: reg rdrxacov if dpost==1 & rdage65==0, cluster(clustid)
	outreg2 using "${repdir}table3_panela_mn", append ctitle(after mean below) nonotes nor2 noaster word
	xi: reg rdrxacov if dpost==1 & rdage65==1, cluster(clustid)
	outreg2 using "${repdir}table3_panela_mn", append ctitle(after mean above) nonotes nor2 noaster word

	xi: reg rdrxacov rdage65 if dpost==1, cluster(clustid)
	outreg2 rdage65 using "${repdir}table3_panela_dd", replace ctitle(group diff after) nocons nonotes nor2 noaster word
	xi: reg rdrxacov rdage65 if dpost==0, cluster(clustid)
	outreg2 rdage65 using "${repdir}table3_panela_dd", append ctitle(group diff before) nocons nonotes nor2 noaster word

	xi: reg rdrxacov dpost if rdage65==0, cluster(clustid)
	outreg2 dpost using "${repdir}table3_panela_dd", append ctitle(time diff below) nocons nonotes nor2 noaster word
	xi: reg rdrxacov dpost if rdage65==1, cluster(clustid)
	outreg2 dpost using "${repdir}table3_panela_dd", append ctitle(time diff above) nocons nonotes nor2 noaster word

	xi: reg rdrxacov rdage65 dpost rdage65_post, cluster(clustid)
	outreg2 rdage65_post using "${repdir}table3_panela_dd", append ctitle(diff-in-diff) nocons nonotes nor2 noaster word

	***Panel B***;
	xi: reg rdrxgcov2 if dpost==0 & rdage65==0, cluster(clustid)
	outreg2 using "${repdir}table3_panelb_mn", replace ctitle(before mean below) nonotes nor2 noaster word
	xi: reg rdrxgcov2 if dpost==0 & rdage65==1, cluster(clustid)
	outreg2 using "${repdir}table3_panelb_mn", append ctitle(before mean above) nonotes nor2 noaster word
	xi: reg rdrxgcov2 if dpost==1 & rdage65==0, cluster(clustid)
	outreg2 using "${repdir}table3_panelb_mn", append ctitle(after mean below) nonotes nor2 noaster word
	xi: reg rdrxgcov2 if dpost==1 & rdage65==1, cluster(clustid)
	outreg2 using "${repdir}table3_panelb_mn", append ctitle(after mean above) nonotes nor2 noaster word

	xi: reg rdrxgcov2 rdage65 if dpost==1, cluster(clustid)
	outreg2 rdage65 using "${repdir}table3_panelb_dd", replace ctitle(group diff after) nocons nonotes nor2 noaster word
	xi: reg rdrxgcov2 rdage65 if dpost==0, cluster(clustid)
	outreg2 rdage65 using "${repdir}table3_panelb_dd", append ctitle(group diff before) nocons nonotes nor2 noaster word

	xi: reg rdrxgcov2 dpost if rdage65==0, cluster(clustid)
	outreg2 dpost using "${repdir}table3_panelb_dd", append ctitle(time diff below) nocons nonotes nor2 noaster word
	xi: reg rdrxgcov2 dpost if rdage65==1, cluster(clustid)
	outreg2 dpost using "${repdir}table3_panelb_dd", append ctitle(time diff above) nocons nonotes nor2 noaster word

	xi: reg rdrxgcov2 rdage65 dpost rdage65_post, cluster(clustid)
	outreg2 rdage65_post using "${repdir}table3_panelb_dd", append ctitle(diff-in-diff) nocons nonotes nor2 noaster word
	
	

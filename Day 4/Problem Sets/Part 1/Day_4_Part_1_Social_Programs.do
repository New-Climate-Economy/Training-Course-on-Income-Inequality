// Setup
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

** User Written Commands
foreach c in wid{
	cap which `c'
	if _rc cap ssc install `c'
}


*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (Personal)/New Climate Economy/Course/Day 4/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/Course/Day 4/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/Course/Day 4/"
cd "${repdir}" 

*****************************************************************************************
/* Case 1: McIntosh et al.(2018), "The Neighborhood Impacts of Local Infrastructure
		   Investment: Evidence from Urban Mexico", American Economic Journal: Applied Economics, 263–286
	
	*Abstract: This paper reports on the results of a large infrastructure investment
			   experiment in which $68 million in spending was randomly allocated
			   across a set of low-income urban neighborhoods in Mexico. We show
			   that the program resulted in substantial improvements in access
               to infrastructure and increases in private investment in housing.
               While a pre-committed index of social capital did not improve, we
               find an apparent decrease in the incidence of personal assault and
               teen misbehavior in neighborhoods where investments were made.
               The program increased the aggregate real estate value in program
               neighborhoods by two dollars for every dollar invested.
*/
*****************************************************************************************
use "${repdir}day_4_social_programs.dta", clear

**Setup

	**Set globals with relevant variables
	global infrastructure "Disp_Infra_Bas Disp_Agua	Disp_Drenaje Disp_Luz Alumbrado_Siempre_Enc Disp_Guarniciones	Disp_Banquetas	Disp_Pavimento  "
	global investment " brick_walls  concrete_floor kitchen bathroom flush_toilet septic piped_water   home_owner f_banca_privada rent_usd "
	global attribution "conoce_habitat conoce_nonhabitat recibido_habitat recibido_nonhabitat"
	
	**Collapse data with polygon-level averages
	
	/*IMPORTANT: First generate average weights for regressions using m_Factor_C and wgt_sat. 
				 These are the steps:
				  
				  1. Sum weights by polygon and round (which one?) if the unit belongs to the panel and the corresponding round
				  2. Compute the mean by polygon
				  
				  *Clue: On both steps use the 'egen' command 
	*/
	collapse $infrastructure $investment $attribution satis* crm_12mo sum_Factor_C dropped_hh sum_Factor_S treat_r2 sat sat_treat treat r2 cve_mun if sample_PANEL==1 [pweight=m_Factor_Corto_Vivienda], by(N_POLIGONO round)
	gen sum_Factor = sum_Factor_C
	gen dropped_hh_r2 = dropped_hh * r2

**Compute balance using clusters at polygon level

/*Important: Use proportion weights for all calculations and variable sum_Factor_C */
*#delimit;
	regr Disp_Agua treat [pweight=sum_Factor_C], cluster(N_POLIGONO)
	outreg2 treat using "${repdir}balance_social_programs_1.xlsx", nolabel nocons ctitle(RESET) replace

	foreach x in $infrastructure   {
		reg `x' treat   if round==1 [pweight=sum_Factor_C], cluster(cve_mun)	
		outreg2 treat using "${repdir}balance_social_programs_1.xlsx", nolabel nocons ctitle(`x') append
	}
	
** 2. Fixed effects regressions

	*Public Infrastructure Impacts with polygon fixed effects	
	regr Disp_Agua treat_r2 r2 [pweight=sum_Factor_C], robust
	outreg2 treat_r2 using "${repdir}fe_impact_social_programs_1.xlsx", nolabel nocons ctitle(RESET) replace
	foreach x in $infrastructure satis_colon_fis satis_colon_soc {
		xtreg `x' treat_r2  r2 [pweight=sum_Factor_C], i(N_POLIGONO) fe cluster(cve_mun)
		outreg2 treat_r2 using "${repdir}fe_impact_social_programs_1.xlsx", nolabel nocons ctitle(`x',polyFE) append
	}

	*Private Investment Impacts
	regr Disp_Agua treat_r2 r2 [pweight=sum_Factor_C], robust
	outreg2 treat_r2  r2 using impact, nolabel nocons ctitle(RESET) replace
	outreg2 treat_r2 using "${repdir}fe_impact_social_programs_1.xlsx", nolabel nocons ctitle(RESET) replace
	foreach x in $investment  {
		xtreg `x' treat_r2  r2 [pweight=sum_Factor_C], i(N_POLIGONO) fe cluster(cve_mun)
  		outreg2 treat_r2 using "${repdir}fe_impact_social_programs_1.xlsx",  nolabel nocons ctitle(`x',polyFE) append
	}

********************************************************************************
* Multidimensional Poverty
* Replication Codes
********************************************************************************

*Root
if "`c(username)'" == "Cristian" global maindir "C:/Users/Cristian/Dropbox (NEO)/New Climate Economy/"
if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/New Climate Economy/"
if "`c(username)'" == "Javiera" global maindir "C:/Users/Javiera/Dropbox (NEO)/New Climate Economy/"

*Directory
global repdir "${maindir}Inequality Course Training Materials\Day 2\Problem Sets\Data/"

*Data
use "${repdir}casen_day3.dta", clear



****************************************
* 1. Multidimensional poverty dimensions 
****************************************

*** A - EDUCATION ***
** 	i) Years of schooling **
* Reference population are all the people older than 18 (either they assist or not). 
* A household is considered deprived if any of its members hasn´t accomplished the years of 
* studies required by law (according their age). 

* In Chile there have been four (4) modifications 
* 1) from 1920 to 1929: 4 years
* 2) from 1930 to 1965: 6 years
* 3) from 1966 to 2002: 8 years
* 4) from 2003 to adelante: 12 years

* Auxiliary ranges
gen     aux_age = 1 if (age>107) & age!=.
replace aux_age = 2 if (age>99 & age<=107)
replace aux_age = 3 if (age>64 & age<=99)
replace aux_age = 4 if (age>32 & age<=64)
replace aux_age = 5 if (age>18 & age<=32)

* Reference population 
gen ref_population=.
replace ref_population= 1 if (age>18)
replace ref_population=0 if (age<=18)  

* Individual deprivation *
gen depriv_sch=.
replace depriv_sch = 0 if ((aux_age==1)|((aux_age==2) & schooling>=4)|(aux_age==3 & schooling>=6)|(aux_age==4 & schooling>=8)|(aux_age==5 & schooling>=12)) & ref_population == 1   
replace depriv_sch = 1 if ((aux_age==2 & schooling<4)|(aux_age==3 & schooling<6)|(aux_age==4 & schooling<8)|(aux_age==5 & schooling<12 )) & ref_population == 1 

* Household deprived *
bys id_household : egen sum_d_sch = sum(depriv_sch)
bys id_household : egen aux_depriv_sch = max(sum_d_sch)
gen house_d_sch = 0
replace house_d_sch = 1 if aux_depriv_sch >= 1 & ref_population==1 

* Drop auxiliary variable
drop aux_age ref_population sum_d_sch aux_depriv_sch

** ii) School attendance **
* Reference population corresponds to people between 4 and 18 years old (and to 26 if
* they have a disability) that are currently attending to school 
* A deprived household is considered when at least one of their members of the 
* reference population  is not attending. 

* Reference population 
gen ref_population=.
replace ref_population=1 if inrange(age, 4, 18) & age!=.
replace ref_population=0 if (age<4 | age>18) & age!=.
replace ref_population=1 if inrange(age, 6, 26) & (disability<7) 
replace ref_population=0 if (age<6) & (disability<7) 
replace ref_population=0 if (age>26) & (disability<7) 

* Individual deprivation *
gen depriv_att=.
replace depriv_att=1 if (attendance==2) & ref_population==1 
replace depriv_att=0 if (attendance==1) & ref_population==1 

* Household deprived *
bys id_household : egen sum_d_att = sum(depriv_att)
bys id_household : egen aux_depriv_att= max(sum_d_att)
gen house_d_att = 0
replace house_d_att = 1 if aux_depriv_att >= 1 & ref_population==1

* Drop auxiliary variable
drop ref_population sum_d_att aux_depriv_att

*** B - HEALTH  ***
** i) Nutrition **

* Reference population 
gen ref_population= (age<=70)

* Individual deprivation *
gen depriv_nut = .
replace depriv_nut = 1 if ref_population==1 & (nutrition == 1 | nutrition == 3 | nutrition == 4) 
replace depriv_nut = 0 if ref_population==1 & nutrition == 2   

* Household deprived*
bys id_household : egen sum_d_nut = sum(depriv_nut)
bys id_household : egen aux_depriv_nut= max(sum_d_nut)
gen house_d_nut = 0
replace house_d_nut = 1 if aux_depriv_nut >= 1 & ref_population==1

* Drop auxiliary variables
drop ref_population sum_d_nut aux_depriv_nut

** ii) Affilitation to health system **

* Reference population 
gen ref_population=(id_household!=.)

* Individual deprivation *
gen depriv_affi=.
replace depriv_affi = 0 if (affiliation <8 | affiliation ==9) 
replace depriv_affi = 1 if (affiliation==8) 

* Household deprived *
bys id_household : egen sum_d_affi = sum(depriv_affi)
bys id_household : egen aux_depriv_affi= max(sum_d_affi)
gen house_d_affi = 0
replace house_d_affi = 1 if aux_depriv_affi >= 1 & ref_population==1 

* Drop auxiliary variables
drop ref_population sum_d_affi aux_depriv_affi

*** C - LABOR ***
** i) Employment **

* Reference population: anyone over 18 years
gen ref_population=.
replace ref_population=1 if age>18
replace ref_population=0 if age<=18

* Individual deprivation *
gen depriv_employment=.
replace depriv_employment=1 if (activ==2) & ref_population==1
replace depriv_employment=0 if (activ==1 | activ==3) & ref_population==1

* Household deprived *
bys id_household : egen sum_d_emplo = sum(depriv_employment)
bys id_household : egen aux_depriv_emplo= max(sum_d_emplo)
gen house_d_emplo = 0
replace house_d_emplo = 1 if aux_depriv_emplo >= 1 & ref_population==1

* Drop auxiliary variables
drop ref_population sum_d_emplo aux_depriv_emplo

*** D - HOUSING ***
** i) Drinking water **

* Reference population 
gen ref_population=(id_household!=.)

* Individual deprivation *
gen depriv_water=.
replace depriv_water= 0 if water2==1 
replace depriv_water= 1 if water2==2|water2==3 

* Household deprived *
gen house_d_water = 0
replace house_d_water = 1 if depriv_water== 1 & ref_population==1

* Drop auxiliary variables
drop ref_population 

** ii) Enviornment ** 

* Reference population 
gen ref_population=(id_household!=.)

* Air 
gen air_poll=.
replace air_poll=1 if air==4 
replace air_poll=0 if (air==1 | air==2 | air==3)

* Rivers, canals, lakes
gen rivers_poll=.
replace rivers_poll=1 if river==4
replace rivers_poll=0 if (river==1 | river==2 | river==3)

* Public water suppliers
gen pwater_poll=.
replace pwater_poll=1 if pwater==4
replace pwater_poll=0 if (pwater==1 | pwater==2 | pwater==3)

* Garbage
gen garbage_poll=.
replace garbage_poll=1 if garbage==4
replace garbage_poll=0 if (garbage==1 | garbage==2 | garbage==3)

* Plague 
gen plague_poll=.
replace plague_poll=1 if plague==4
replace plague_poll=0 if (plague==1 | plague==2 | plague==3)

* Sum of pollution problems
egen sum_pollution=rowtotal(air_poll rivers_poll pwater_poll garbage_poll plague_poll)

** Individual deprivation **
gen depriv_environment=.
replace depriv_environment=1 if (sum_pollution>=2) & ref_population==1
replace depriv_environment=0 if (sum_pollution<2) & ref_population==1

** Household deprived **
gen house_d_environment = 0
replace house_d_environment = 1 if depriv_environment== 1 & ref_population==1

* Drop auxiliary variables
drop ref_population air_poll rivers_poll pwater_poll garbage_poll plague_poll sum_pollution


*********************
********* 2 *********
*********************

** What is the percentage of people deprived in each dimension? **
* 1: Years of schooling *
tab depriv_sch
* 2: School attendance *
tab depriv_att
* 3: Nutrition *
tab depriv_nut
* 4: Affilitation to the Health System *
tab depriv_affi
* 5: Employment *
tab depriv_employment
* 6: Drinking water *
tab depriv_water
* 7: Environment *
tab depriv_environment 

** How are these percentages in rural and urban areas? ** 

* 1: Years of schooling *
bys zone: tab depriv_sch
* 2: School attendance *
bys zone: tab depriv_att 
* 3: Nutrition *
bys zone: tab depriv_nut 
* 4: Affilitation to the Health System *
bys zone: tab depriv_affi
* 5: Employment *
bys zone: tab depriv_employment 
* 6: Drinking water *
bys zone: tab depriv_water
* 7: Environment *
bys zone: tab depriv_environment 

** Which dimensions present the highest levels of deprivation? **

*********************
********* 3 *********
*********************

** Build a chart bar to show the comparison of the deprivation headcount
** ratios between rural and urban areas.
** NOTE: This is a raw headcount ratio (deprivation rates in each indicator), which includes everyone who is deprived, regardless of whether they are multidimensionally poor or not (within a given reference population).

graph bar depriv_sch depriv_att depriv_nut depriv_affi depriv_employment depriv_water depriv_environment, over(zone)

*********************
******* 4 y 5 *******
*********************

** Calculate the incidence and intensity of multidimensional poverty with a K=25% threshold. **

************************************************************* 
* Aggregation by households of deprivation cutoffs 
*************************************************************

local aux sch att nut affi emplo water environment
foreach var in `aux' {
gen hh_d_`var'= house_d_`var' 
label var hh_d_`var' "Deprivation of `var' at individual level"
}

** Weighting (4 dimensions)

local pp1 sch att nut affi water environment
foreach var in `pp1' {
gen pp_`var'_ant=0.25/2
* Weighting deprivation
gen w_hh_d_`var'_ant= hh_d_`var'* pp_`var'_ant
label var pp_`var'_ant " `var' weighting"
label var w_hh_d_`var'_ant "Weighting deprivation of `var'"
}

gen pp_emplo_ant=0.25
gen w_hh_d_emplo_ant= hh_d_emplo * pp_emplo_ant
label var pp_emplo_ant " employment weighting"
label var w_hh_d_emplo_ant "Weighting deprivation of employment"

** Aggregation

egen ci_ant=rsum(w_hh_d_*_ant)
label var ci_ant "Aggregation vector"

** Incidence and intensity of multidimensional poverty with a K=25% threshold

gen h_ant=(ci_ant>=0.25) 
label var h_ant "Situation (incidence) of multidimensional poverty (4 dimensions)"
gen a_ant=ci_ant if h_ant==1
label var a_ant "Intensity of multidimendional poverty (4 dimensiones)"

** (a) Total population, urban area, and rural area. ** 

tab zone h_ant

** (b) Male and female headed households. **
* Create male and female headed households *

gen fem_head = .
replace fem_head = 1 if head_related == 1 & sex == 2
bys id_household : egen fem_headed = sum(fem_head)

tab fem_headed h_ant


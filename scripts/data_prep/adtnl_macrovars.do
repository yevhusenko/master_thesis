******************* PREPARE ADDITIONAL MACRO DATA *****************************

/* Macro variables: population, unemployment, interest rates
	World Development Indicators
	Source: World Bank
*/


// 
import excel ./inputs/data/pop_unempl_interest.xlsx, firstrow clear

// rename variables
rename Population dlpop
rename Unemployment unempl_ilo
rename G unempl_ne
rename Realinterest rlendrate
rename Lendingint lendrate
rename Depositint deprate

// corrections re: id codes
kountry CountryCode, from(iso3c) to(cown) marker
drop if CountryName == "South Sudan" | CountryName == "Sudan"
drop if missing(_COWN_)
rename Time year
rename _COWN_ ccode
gen cyear = real(string(ccode) + string(year))
order ccode cyear, after(year)

// calculate changes in unemployment and in interest rates
tsset ccode year
foreach i of varlist unempl* *rate {
	gen D`i' = D.`i'
}

drop if year == 2003 | year == 2017 // limitations of FAS data

keep CountryName year ccode cyear dlpop *unempl_ilo *rlendrate *lendrate *deprate

save ./output/data/pop_unempl_int_upd.dta, replace


// add population
import excel ./inputs/data/population.xlsx, firstrow clear
rename Population poptotal

kountry CountryCode, from(iso3c) to(cown) marker
drop if CountryName == "South Sudan" | CountryName == "Sudan"
drop if missing(_COWN_)
rename Time year
rename _COWN_ ccode
gen cyear = real(string(ccode) + string(year))
order ccode cyear, after(year)

// add a variable for population in 2004 (effectively a year before the analysis 
// starts)
tempvar popstart
gen `popstart' = poptotal if year == 2004
bysort ccode: egen pop2004 = max(`popstart')
keep CountryName year ccode cyear poptotal pop2004

drop if year == 2003 | year == 2017
save ./output/data/population.dta, replace

// merge
use ./output/data/pop_unempl_int_upd.dta, replace
merge 1:1 cyear using ./output/data/population.dta, nogen

save ./output/data/pop_unempl_int_upd.dta, replace

rm ./output/data/population.dta

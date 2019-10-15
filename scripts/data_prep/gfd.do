********************** BANKING SYSTEM VARIABLES *****************************

/* Additional data from:
 -- Global Financial Development Database
 -- source: World Bank 
*/


import excel ./inputs/data/world_bank_gfd.xlsx, firstrow clear

foreach i of varlist * {
	lab var `i' "`=`i'[1]'"
	replace `i' = "" if _n ==1
	destring `i', replace
}

drop if _n == 1
sort countrygfd year
order year, after(countrygfd)

kountry countrycode, from(iso3c) to (cown) marker
drop if countrygfd == "South Sudan" | countrygfd == "Sudan"
rename _COWN_ ccode 
drop NAMES_STD MARKER
drop if missing(ccode)

drop if year < 2004 // because of data limitations of Financial Access Survey

gen cyear = real(string(ccode) + string(year)) 
order ccode, after(countrygfd)
order cyear, after(year)

save ./output/data/wb_gfd_upd.dta, replace

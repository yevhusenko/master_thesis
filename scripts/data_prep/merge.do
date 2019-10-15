************************* MERGING DATA *********************************

// Import FAS, add Database of Political Institutions
use ./output/data/fas_upd.dta, clear
merge 1:1 cyear using ./output/data/dpi2017_upd.dta, gen(_merge1)
drop if _merge1 != 3
drop _merge1 countrydpi


// Add World Development Indicators data
merge 1:1 cyear using ./output/data/wdi_upd.dta, gen(_merge3)
drop if _merge3 == 2
drop countrywdi _merge3 iso3


// Add Global Financial Development Database
merge 1:1 cyear using ./output/data/wb_gfd_upd.dta, gen(_merge4)
drop if _merge4 == 2
drop countrygfd countrycode _merge4


// Aditional macro variables from WDI
merge 1:1 cyear using ./output/data/pop_unempl_int_upd.dta, gen(_merge6)
drop if _merge6 == 2
drop CountryName _merge6


// Add Quality of Government Dataset
merge 1:1 cyear using ./inputs/data/QoG.dta, gen(_merge7)
drop if _merge7 == 2
drop cname _merge7

save ./output/data/thesisdata_int.dta, replace


// Add deposit insurance dummy from Demirgüç-Kunt et al. (2014) 
do ./scripts/data_prep/depinsurance.do

use ./output/data/thesisdata_int.dta, clear
merge 1:1 cyear using ./output/data/depinsurance.dta, gen(_mergex)
drop _mergex



save ./output/data/thesisdata_int.dta, replace

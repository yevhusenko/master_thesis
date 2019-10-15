***************** IMF's FINANCIAL ACCESS SURVEY *****************************


use ./inputs/data/financial_access_survey.dta, clear



// ***** Import and basic cleaning *****

local counter = 0
foreach i of varlist * {
	local counter = `counter' + 1
	local varlabel : variable label `i'
	display "`counter'. `i'" _col(50) "`varlabel'"
}


// ***** Prepare country names and codes for merging with other datasets *****

rename economy countryname

// convert ISO country codes to Correlates of War
kountry iso3, from(iso3c) to(cown) marker 
drop if missing(_COWN_) // drop countries that have no COW code -- we have no 
						// info on their politics
drop if countryname == "Sudan" | countryname == "South Sudan" // drop these 
								// because they used to be one polity and 
								// then split
drop if countryname == "Serbia, Republic of" // went through a big war
								// and then split up
								

// Estonia changed currency in 2011								
foreach i of varlist s_deposits_A1 s_deposits_A1_hhs ///
					s_loans_A1 s_loans_A1_hhs s_loans_A1_sme {
	replace `i' = `i'/15.6466 if countryname == "Estonia" & year < 2011
}


rename _COWN_ ccode
replace countryname = NAMES_STD
drop NAMES_STD MARKER

gen cyear = real(string(ccode) + string(year))


// ***** drop variables not used in the analysis *****

rename countryname countryfas
order ccode, after(countryfas)
order cyear, after(year)

keep countryfas ccode year cyear i_ATMs_pop i_branches_km2_A1 i_branches_pop_A1 ///
		s_deposits_A1 s_deposits_A1_hhs s_loans_A1 s_loans_A1_hhs s_loans_A1_sme

save ./output/data/fas_upd.dta, replace

*********************** FINAL PREPARATIONS *********************************

/* 
	- Make consistent sample
	- Create additional variables for regressions
*/

use ./output/data/thesisdata_int.dta, clear




// *** Create additional variables ***
cap drop __*
tsset ccode year

gen rdeposits = s_deposits_A1 / linkdeflator *100 // convert deposits outstanding to constant LCU
gen rdeposits_hhs = s_deposits_A1_hhs/linkdeflator *100 // convert household deposits to constant LCU

gen dlrdeposits = (rdeposits - L.rdeposits)/L.rdeposits *100 // real deposit growth
gen dlrdeposits_hhs = (rdeposits_hhs - L.rdeposits_hhs)/L.rdeposits_hhs *100  // real HH deposit growth

gen rloans = s_loans_A1 / linkdeflator *100 // convert outstanding loans with com. banks to constant LCU
gen rloans_hhs = s_loans_A1_hhs / linkdeflator *100 // convert loans to HHs to constant LCU
gen rloans_sme = s_loans_A1_sme / linkdeflator *100 // convert loans to SME to constant LCU

gen dlrloans = (rloans - L.rloans)/L.rloans *100 // real loan growth

gen dlrdeposits_lag = L.dlrdeposits
gen dlrdeposits_hhs_lag = L.dlrdeposits_hhs 
gen dlrloans_lag = L.dlrloans

foreach i of varlist capitaltoassets depositstogdp zscore bankconcentr ///
					liqratio roa credittodeposits crisis dlpop unempl_ilo ///
					Dunempl_ilo depinsurance deprate Ddeprate fh_rol ///
					hf_prights ti_cpi gsd_cg gsd_ia {
	gen `i'_lag = L.`i'
} 

drop if year == 2004 // this year is irrelevant for our regressions since 
					// there's no data for the dependent vars

					
					
									
// *** Focus only on democratic countries ***

tempvar p33
egen `p33' = pctile(fh_ep), p(33) // drop bottom third of the data wrt free elections
drop if fh_ep < `p33'

tsset ccode year
tempvar pattern
xtpatternvar, gen(`pattern')
keep if `pattern' == "111111111111" // make balanced panel



// Winsorize dependent variables
winsor dlrdeposits, gen(dlrdeposits_w) p(0.01) //winsorize deposit growth at 1% level
winsor dlrdeposits_hhs, gen(dlrdeposits_hhs_w) p(0.01) //winsorize HH deposit growth at 1% level

winsor dlrloans, gen(dlrloans_w) p(0.01)

gen dlrdeposits_hhs_w_lag = L.dlrdeposits_hhs_w
gen dlrloans_w_lag = L.dlrloans_w



// *** Other changes ***

/* Add a dummy for whether a country has strong checks and balances on the 
executive. 
	Based on Political Constrains Index III by Henisz */

replace h_polcon3 = . if h_polcon3 == 0 // 0 in the original source denotes no assignment
qui su h_polcon3, d
gen lowpolcon = 0 if !missing(h_polcon3)
// bottom half = low level of political constraints
replace lowpolcon = 1 if h_polcon3 <= r(p50) & !missing(h_polcon3) 

// Year dummies
tab year, gen(y)

// Complete election closeness variable for the end sample
// save ./output/data/thesisdata_int.dta, replace
qui do ./scripts/data_prep/close_elections.do // create close election closeness variables


// Close elections dummy based on popular vore shares

gen clelec = 0 if !missing(vote_closeness2)

// select bottom half as close elections, but separately for presidential and 
// parliamentary elections, for they usually have different structures and 
// different margins
su vote_closeness2 if system == 0 & election == 1, d 
replace clelec = 1 if vote_closeness2 <= r(p50) & system == 0 & election == 1
su vote_closeness2 if inlist(system, 1, 2) & election == 1, d
replace clelec = 1 if vote_closeness2 <= r(p50) & inlist(system, 1, 2) & election == 1
// Inverse of close elections variable
gen sureelec = 0 if !missing(vote_closeness2)
replace sureelec = 1 if election == 1 & clelec == 0



// Close elections dummy based on actual seats in the legislature 
// or electoral votes if applicable

gen clelec2 = 0 if !missing(vote_closeness_seats2)
su vote_closeness_seats2 if system == 0 & election == 1, d
replace clelec2 = 1 if vote_closeness_seats2 <= r(p50) & system == 0 & election == 1
su vote_closeness_seats2 if inlist(system, 1, 2) & election == 1, d
replace clelec2 = 1 if vote_closeness_seats2 <= r(p50) & inlist(system, 1, 2) & election == 1
gen sureelec2 = 0 if !missing(vote_closeness_seats2)
replace sureelec2 = 1 if election == 1 & clelec2 == 0


// Incumbent's political affiliation
gen execrlc1 = execrlc if execrlc > 0 // 0 and negative values mean not defined in the original source
label values execrlc1 rlc
tab execrlc1, gen(platform)
gen mktfr = 0 if !missing(execrlc1) 
replace mktfr = 1 if inlist(execrlc1, 1, 2)   // market-friendly incumbent



// *** Generate interaction terms ***
gen intercb1 = election * lowpolcon
gen interdi = election * depinsurance_lag
gen interright = election * platform1
gen intercent = election * platform2
gen interleft = election * platform3
gen intermktfr = election * mktfr 


// *** Label the variables ***
run ./scripts/data_prep/labels.do

cap drop __*

// output
save ./output/data/thesisdata.dta, replace

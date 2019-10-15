***************************** ELECTIONS DATA PREP ***************************


use ./inputs/data/DPI2017.dta, clear

// ********* CORRECTIONS ********


// List all variables
local counter = 0
foreach i of varlist * {
	local counter = `counter'+1
	local varlabel : variable label `i'
	display "`counter'. `i'" _col(50) "`varlabel'"
}


// Keep relevant variables and observations
keep countryname ifs year system finittrm percent1 percentl execrlc totalseats ///
gov*seat gov*vote govothst govothvt opp*seat opp*vote oppothst oppothvt ///
numul ulvote dateleg dateexec legelec exelec pluralty pr housesys sensys ///
numgov numvote numopp oppvote checks


drop if year == . | year < 2002 // 2002 -- because FAS starts in 2004 


// Manual corrections when needed
replace legelec = 0 in 847 // correct missing leg. election for Estonia

// political systems not classified, should be parlamentary
replace system = 2 if countryname == "Belgium"
replace system = 2 if countryname == "Estonia"
replace system = 2 if countryname == "Moldova"

// not classified, should be presidential
replace system =  0 if countryname == "Togo"

// correct country codes when `kountry` gets them wrong
replace ifs = "COD" if ifs == "ZAR"
replace ifs = "TLS" if ifs == "TMP"
kountry ifs, from(iso3c) to(cown) marker
replace _COWN_ = 360 if NAMES_STD == "Romania" // missing for some reason, 
											   // but it should be 360
drop if NAMES_STD == "South Sudan" | NAMES_STD == "Sudan"

drop if missing(_COWN_)
replace countryname = NAMES_STD
rename _COWN_ ccode
drop MARKER NAMES_STD
gen cyear = real(string(ccode) + string(year))


// ************* GENERATE ADDITIONAL VARIABLES ****************

// Election dummies
gen election_lax = 0
replace election_lax = 1 if exelec == 1 | legelec == 1 // dump-all election dummy = 1 
									// if presidential OR legislative election
									
replace election_lax = 0 if cyear == 1552010 // 2nd round in Jan 2010, //
									// but election only one - in 2009, Chile
									
gen election = 0
replace election = 1 if system == 0 & exelec ==1
replace election = 1 if inlist(system,1,2) & legelec == 1 // legislative elections 
									// count only for parliamentary democracies 
									// and assembly-elected president
									
replace election = 0 if cyear == 1552010 // 2nd round in Jan 2010, but 
										// election only one - in 2009, Chile

										
// Fixed/flexible timing re: elections
tsset ccode year
tsspell, fcond(election==1)
replace _spell = . if _spell == 0  // do not count initial spells
replace _seq = 999 if year == 2017 // so that the last spell doesn't count either

by ccode _spell, sort: egen len_spell = max(_seq)
sort ccode year
replace len_spell = . if inlist(len_spell, 0, 999)

tempvar maxlen 
bysort ccode: egen `maxlen' = max(len_spell) if !missing(len_spell)
tempvar minlen
bysort ccode: egen `minlen' = min(len_spell) if !missing(len_spell)
tempvar lendiff
gen `lendiff' = `maxlen' - `minlen'
tempvar fixed1
gen `fixed1' = 0
replace `fixed1' = 1 if `lendiff' == 0 // if all periods in between elections
										// are of equal length -> fixed timing
bysort ccode: egen fixed = max(`fixed1')
drop _* len_spell

tempvar numelections
bysort ccode: egen `numelections' = sum(election)
replace fixed = 0 if `numelections' <= 2  // do not count elections as 
								// fixed-term if there's only 1 period to compare

					
// Fixed/flexible timing for lax election variable
* Are the executive elections fixed in timing?
tsset ccode year
tsspell, fcond(exelec == 1)
replace _spell = . if _spell == 0
replace _seq = 999 if year == 2017

by ccode _spell, sort: egen len_spell = max(_seq)
sort ccode year
replace len_spell = . if inlist(len_spell, 0, 999)
tempvar maxlen 
bysort ccode: egen `maxlen' = max(len_spell) if !missing(len_spell)
tempvar minlen
bysort ccode: egen `minlen' = min(len_spell) if !missing(len_spell)
tempvar lendiff
gen `lendiff' = `maxlen' - `minlen'
tempvar fixed1
gen `fixed1' = 0
replace `fixed1' = 1 if `lendiff' == 0
bysort ccode: egen fixed_exec = max(`fixed1')
drop _* len_spell

tempvar numelections
bysort ccode: egen `numelections' = sum(exelec)
replace fixed_exec = 0 if `numelections' <= 2

*Are the legislative elections fixed in timing?
tsset ccode year
tsspell, fcond(legelec == 1)
replace _spell = . if _spell == 0
replace _seq = 999 if year == 2017

by ccode _spell, sort: egen len_spell = max(_seq)
sort ccode year
replace len_spell = . if inlist(len_spell, 0, 999)
tempvar maxlen 
bysort ccode: egen `maxlen' = max(len_spell) if !missing(len_spell)
tempvar minlen
bysort ccode: egen `minlen' = min(len_spell) if !missing(len_spell)
tempvar lendiff
gen `lendiff' = `maxlen' - `minlen'
tempvar fixed1
gen `fixed1' = 0
replace `fixed1' = 1 if `lendiff' == 0
bysort ccode: egen fixed_leg = max(`fixed1')
drop _* len_spell

tempvar numelections
bysort ccode: egen `numelections' = sum(legelec)
replace fixed_leg = 0 if `numelections' <= 2


// Account for the fact that some countries don't hold executive/legislative 
// elections and make final fixed_lax variable
tempvar fixed_joint
gen `fixed_joint' = 0
tempvar existelecexec
bysort ccode: egen `existelecexec' = max(exelec)
replace fixed_exec = 1 if `existelecexec' != 1 // executive elections ``fixed" if they are not held at all
tempvar existelecleg 
bysort ccode: egen `existelecleg' = max(legelec)
replace fixed_leg = 1 if `existelecleg' != 1 // leg. elections ``fixed'' if they are not held at all
replace `fixed_joint' = 1 if fixed_exec == 1 & fixed_leg == 1
bysort ccode: egen fixed_lax = max(`fixed_joint')


************* VOTE CLOSENESS **********

// Calculate p.p. difference between gvnt and opposition parties IN TOTAL, 
// valid for parliamentary elections
gen votediff = numvote - oppvote if numvote != 0 & oppvote != 0


// generate difference between the 2 largest party vote shares
tempvar maxvote
tempvar maxvote2
egen `maxvote' = rowmax(gov1vote gov2vote gov3vote govothvt) // vote share of the largest government party
egen `maxvote2' = rowmax(opp1vote opp2vote opp3vote oppothvt) // vote share of the largest opposition party

// difference b/w largest government and opposition parties' vote shares
gen votediff2 = `maxvote' - `maxvote2' if `maxvote' != 0 & `maxvote2' != 0


// Analogous variables, but using actual seats
tempvar govseatshare
gen `govseatshare' = numgov/totalseats *100
tempvar oppseatshare 
gen `oppseatshare' = numopp/totalseats *100
gen seatsdiff = `govseatshare' - `oppseatshare'

tempvar maxseat 
tempvar maxseat2
egen `maxseat' = rowmax(gov1seat gov2seat gov3seat govothst)
egen `maxseat2' = rowmax(opp1seat opp2seat opp3seat oppothst)
replace `maxseat' = `maxseat' /totalseats *100
replace `maxseat2' = `maxseat2' /totalseats *100
gen seatsdiff2 = `maxseat' - `maxseat2' if `maxseat' != 0 & `maxseat2' != 0


// Presidential elections vote: take the first round if no second.
gen presvote = percent1
replace presvote = percentl if percentl != -999

// Forward all these variables 1 period since they represent the shares 
// next year after an election
foreach i of varlist votediff votediff2 seatsdiff seatsdiff2 presvote{
	replace `i' = F.`i'
}

// Generate vote closeness variables
gen vote_closeness1 = 0
label var vote_closeness1 "Vote: Total govt - total opposition"
replace vote_closeness1 = votediff if inlist(system, 1, 2) & election == 1
replace vote_closeness1 = presvote if system == 0 & election == 1
replace vote_closeness1 = . if vote_closeness1 == -999

gen vote_closeness2 = 0 
lab var vote_closeness2 "Vote: Biggest govt - biggest opposition"
replace vote_closeness2 = votediff2 if inlist(system, 1,2) & election == 1
replace vote_closeness2 = presvote if system == 0 & election == 1
replace vote_closeness2 = . if vote_closeness2 == -999

gen vote_closeness_seats1 = 0
lab var vote_closeness_seats1 "Seat shares: Total govt - total oppo"
replace vote_closeness_seats1 = seatsdiff if inlist(system, 1,2) & election == 1
replace vote_closeness_seats1 = . if missing(seatsdiff)

gen vote_closeness_seats2 = 0
lab var vote_closeness_seats2 "Seat shares: biggest govt - biggest oppo"
replace vote_closeness_seats2 = seatsdiff2 if inlist(system, 1,2) & election == 1
replace vote_closeness_seats2 = . if missing(seatsdiff2)


*************** FINAL CHANGES *************
keep countryname ccode year system execrlc checks election_lax election ///
			fixed fixed_lax vote_closeness*
order ccode, after(countryname)

gen cyear = real(string(ccode) + string(year))
order cyear, after(year)
rename countryname countrydpi

save ./output/data/dpi2017_upd.dta, replace

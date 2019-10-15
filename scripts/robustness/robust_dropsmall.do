/*
 Robustness: do the main results change if we drop small countries?
*/

clear all

use ./output/data/thesisdata_int.dta

save ./output/data/nosmallcountries.dta,replace
use ./output/data/nosmallcountries.dta, clear


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



// *** Drop small/violent countries ***

drop if pop2004 <= 1500000 // remove if population less than 1.5 mil


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
run ./scripts/data_prep/close_elections.do // create close election closeness variables


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


save ./output/data/nosmalldata.dta, replace


clear all
use ./output/data/nosmalldata.dta, clear




// *** Regressions ****

** Define macros for the regressions **
global y "dlrdeposits_hhs"
global x "election"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag"
global politvars "hf_prights_lag ti_cpi_lag h_polcon3"
global clustlev "ccode"


*********************** ORDINARY REGRESSIONS **********************************
** Define macros for the regressions **
global y "dlrdeposits_hhs_w"
global x "election"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Baseline **
reg $y $x $macrolags $bankvars $politvars, vce(cluster $clustlev)
eststo baseline1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Baseline with time fixed effects **
reg $y $x $macrolags $bankvars $politvars y1-y12, vce(cluster $clustlev)
eststo baseline2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Baseline with time and country fixed effects **
xtreg $y $x $macrolags $bankvars $politvars y1-y12, fe vce(cluster $clustlev)
eststo baseline3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Baseline with FE re-estimated using Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust small noleveleq 
eststo baseline4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

**************************** INTERACTION WITH C&B ****************************
global y "dlrdeposits_hhs_w"
global x "election intercb1 lowpolcon"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag"
global clustlev "ccode"

** C&B **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo cb1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo cb3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** C&B with FE using Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust small noleveleq
eststo cb4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************* INTERACTION WITH DEP. INSURANCE *********************
global y "dlrdeposits_hhs_w"
global x "election interdi depinsurance_lag"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** DI **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo di1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** DI with year fixed effects **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo di2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** DI with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo di3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** DI with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 4) collapse) robust noleveleq small
eststo di4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************ RIGHT-LEFT DIVIDE ************************************
global y "dlrdeposits_hhs_w"
global x "election intermktfr mktfr"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Right-left **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo rl1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Right-left with year fixed effects **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo rl2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Right-left with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo rl3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Right-left with year and country FE estimed with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 4) collapse) robust noleveleq small
eststo rl4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************ CLOSE ELECTIONS *************************************
global y "dlrdeposits_hhs_w"
global x "election clelec"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Close elections **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo ce1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle(sureelec clelec $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************ PRINTING TO LATEX *********************************

#delimit ;
estout baseline2 baseline3 baseline4 cb2 cb3 cb4 ce2 ce3 ce4 rl2 rl3 rl4 using ./output/tables/robust_nosmall.tex,
			style(tex)
			cells(b(star fmt(3))se(par fmt(3)))
			label
			stats(N
				  ftest
				  estmethod
				  yearfe
				  countryfe
				  numinstr
				  artest
				  jtestp, fmt(0 2 0 0 0 0 3 3)
				  labels("Observations" 
						 "F-test"
						 "Estimator"
						 "Year FE"
						 "Country FE"
						 "N. of instruments"
						 "AR(2) \(p\)"
						 "Hansen J test \(p\)"))
			mlabels(none)
			numbers
			collabels(none)
			varlabels(intercb1 "\multirow{2}{5cm}{$\text{Election}_{it}$ $\times$ $\text{Weak C\&B}_{it}$}" clelec "\multirow{2}{5cm}{$\text{Close election}_{it}$}" intermktfr "\multirow{2}{5cm}{$\text{Election}_{it}$ $\times$ $\text{Market-friendly}_{it}$}")
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election intercb1 clelec intermktfr)
			prehead(\begin{longtable}{m{5cm}*{12}{c}}
					\caption{Political Uncertainty and Bank Deposit Growth: Are the Results Driven by Small Countries?\label{robustnosmall1}}\\
					\toprule
					&\multicolumn{12}{c}{$\text{Real HH deposit growth}_{it}$} \\ \cmidrule(lr){2-13})
			posthead(\midrule\endfirsthead
					\multicolumn{13}{r}{\textit{Table~\ref{robustnosmall1} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{13}{m{\linewidth}}{\footnotesize This table presents estimates of Equations~\eqref{model1}-\eqref{model4} with year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ as the dependent variable on samples that exclude small countries -- i.e., the countries with population less than or equal to 1.5 million in the year 2004. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority, $ Close\ Election_{it} $ is 1 if margin of victory in the relevant election belongs to the bottom 50 percentile, and $ Market\text{-}Friendly_{it} $ is 1 if the incumbent is right- or center-leaning. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.16 to 2.28. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

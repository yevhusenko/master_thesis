/*
 Robustness: 
 • are the results on checks and balances, close elections
 and political platform driven by government tampering?
 • are the results robust to wealth level? 
*/

clear all

use ./output/data/thesisdata.dta



// add variables for if the country is poor or rich based on the new sample
su lrgdppc_usd_lag, d
gen poor1 = 0 if !missing(lrgdppc_usd_lag)
replace poor1 = 1 if lrgdppc_usd_lag <= r(p50) & !missing(lrgdppc_usd_lag)
gen rich1 = 1 - poor1 if !missing(lrgdppc_usd_lag)
label var poor1 "$\text{Poor}_{it-1}$"
label var rich1 "$\text{Rich}_{it-1}$"

gen interp = election * poor1
gen interr = election * rich1

label var interp "$\text{Election}_{it}$ $\times$ $\text{Poor}_{it-1}$"
label var interr "$\text{Election}_{it}$ $\times$ $\text{Rich}_{it-1}$"

// label alternative close election variable
lab var clelec2 "$\text{Close election}_{it}$ \textit{(alt.)}"
lab var sureelec2 "$\text{Certain election}_{it}$ \textit{(alt.)}"

// define dummy for bad-(good-)performing economy
su dlrgdp_lcu_lag, d
gen badeconomy = 0 if !missing(dlrgdp_lcu_lag)
replace badeconomy = 1 if dlrgdp_lcu_lag <= r(p50) & !missing(dlrgdp_lcu_lag)
gen goodeconomy = 0 if !missing(dlrgdp_lcu_lag)
replace goodeconomy = 1 if badeconomy == 0
gen interbadec = election * badeconomy
gen intergoodec = election * goodeconomy

lab var badeconomy "$\text{Bad economy}_{it-1}$"
lab var goodeconomy "$\text{Strong economy}_{it-1}$"
lab var interbadec "$\text{Election}_{it}$ $\times$ $\text{Bad economy}_{it-1}$"
lab var intergoodec "$\text{Election}_{it}$ $\times$ $\text{Strong economy}_{it-1}$"


**************************** GOVT TAMPERING ******************************

*************************** CHECKS & BALANCES *******************************
****************
** Deposits
****************
global y "dlrdeposits_hhs_w"
global x "election intercb1 lowpolcon intergoodec goodeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag"
global clustlev "ccode"

** C&B **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_dep_cb1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_dep_cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_dep_cb3
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
eststo govtemp_dep_cb4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

*******************
** Loans
******************
global y "dlrloans_w"
global x "election intercb1 lowpolcon intergoodec goodeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
global politvars "hf_prights_lag ti_cpi_lag"
global clustlev "ccode"

** C&B **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_loan_cb1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_loan_cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_loan_cb3
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
eststo govtemp_loan_cb4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)


************************ RIGHT-LEFT DIVIDE ***********************************
**********************
** Deposits
**********************
global y "dlrdeposits_hhs_w"
global x "election intermktfr mktfr interbadec badeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Right-left **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_dep_rl1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Right-left with year fixed effects **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_dep_rl2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Right-left with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_dep_rl3
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
eststo govtemp_dep_rl4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************
** Loans
************************
global y "dlrloans_w"
global x "election intermktfr mktfr interbadec badeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Right-left **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_loan_rl1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Right-left with year fixed effects **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_loan_rl2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Right-left with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_loan_rl3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Right-left with year and country FE estimed with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo govtemp_loan_rl4
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
************************
*** Deposits
***********************
global y "dlrdeposits_hhs_w"
global x "election clelec interbadec badeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Close elections **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_dep_ce1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_dep_ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_dep_ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo govtemp_dep_ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

***************************
** Loans
***************************
** Define macros for the regressions **
global y "dlrloans_w"
global x "election clelec interbadec badeconomy"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Close elections **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo govtemp_loan_ce1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo govtemp_loan_ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo govtemp_loan_ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo govtemp_loan_ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)


*************** ARE THE RESULTS ON C&B ROBUST TO WEALTH LEVEL? **************

****************
** Deposits
****************
global y "dlrdeposits_hhs_w"
global x "election intercb1 lowpolcon interp poor1"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag"
global clustlev "ccode"

** C&B **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo dep_cb1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo dep_cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo dep_cb3
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
eststo dep_cb4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

*******************
** Loans
******************
global y "dlrloans_w"
global x "election intercb1 lowpolcon interp poor1"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
global politvars "hf_prights_lag ti_cpi_lag"
global clustlev "ccode"

** C&B **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo loan_cb1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo loan_cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo loan_cb3
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
eststo loan_cb4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)


************ ARE THE RESULTS ROBUST TO CHANGE OF CLELEC TO CLELEC2 ***********
********************
** Deposits
********************
global y "dlrdeposits_hhs_w"
global x "election clelec2"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag L.dlrdeposits_hhs_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Close elections **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo dep_ce1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo dep_ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo dep_ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust small noleveleq
eststo dep_ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

****************************
** Loans
****************************
global y "dlrloans_w"
global x "election clelec2"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
global politvars "hf_prights_lag ti_cpi_lag lowpolcon"
global clustlev "ccode"

** Close elections **
reg $y $x $politvars $macrolags $bankvars, vce(cluster $clustlev)
eststo loan_ce1
estadd local estmethod "OLS"
estadd local yearfe "No"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo loan_ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo loan_ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo loan_ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local controls "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

********************************************************************************** LATEX *********************************************************************************
#delimit ;
estout dep_cb2 dep_cb3 dep_cb4 loan_cb2 loan_cb3 loan_cb4 using ./output/tables/robust_wealth.tex,
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
			varlabels()
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election intercb1 interp)
			prehead(\begin{longtable}{m{4.5cm}*{6}{c}}
					\caption{Robustness Checks: Do checks \& balances have an effect independent of wealth level?\label{robustindices1}}\\
					\toprule
					&\multicolumn{3}{c}{$\text{Real HH deposit growth}_{it}$} & \multicolumn{3}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7})
			posthead(\midrule\endfirsthead
					\multicolumn{7}{r}{\textit{Table~\ref{robustindices1} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{7}{m{\linewidth}}{\footnotesize This table reports the results of re-estimating Equation~\eqref{model2} -- with year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ as well as with year-on-year percent change in real loans outstanding as dependent variables -- adding wealth level dummy $ Poor_{it-1} $ and its interaction with $ Election_{it} $ to the controls. $ Poor_{it-1} $ is coded as 1 if the country-year belongs to the bottom 50 percentile with respect to real per capita GDP in US dollars. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $ and $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 1.98 to 2.14. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr


#delimit ;
estout dep_ce2 dep_ce3 dep_ce4 loan_ce2 loan_ce3 loan_ce4 using ./output/tables/robust_alt_closeelec.tex,
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
			varlabels()
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election clelec2)
			prehead(\begin{longtable}{m{5.5cm}*{6}{c}}
					\caption{Robustness Checks: Alternative Measure of Election Closeness\label{robustindices3}}\\
					\toprule
					&\multicolumn{3}{c}{$\text{Real HH deposit growth}_{it}$} & \multicolumn{3}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7})
			posthead(\midrule\endfirsthead
					\multicolumn{7}{r}{\textit{Table~\ref{robustindices3} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{7}{m{\linewidth}}{\footnotesize This table reports the results of re-estimating Equation~\eqref{model3} -- with year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ as well as with year-on-year percent change in real loans outstanding as dependent variables -- replacing $ Close\ Election_{it} $ based on popular-vote-share margins with one based on actual legislative seats won if country $ i $ is a parliamentary democracy and Electoral College votes for the USA -- the only presidential democracy in my sample that does not use popular vote to elect their executives. $ Close\ Election_{it}\ (alt.)$ is 1 if the margin of victory in the relevant election belongs to the bottom 50 percentile and $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.01 to 2.17. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

#delimit ;
estout govtemp_dep_cb2 govtemp_dep_cb3 govtemp_dep_cb4 govtemp_loan_cb2 govtemp_loan_cb3 govtemp_loan_cb4 using ./output/tables/robust_govtemp_cb.tex,
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
			varlabels(intergoodec "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Strong economy}_{it-1}$}"
					  intercb1 "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Weak C\&B}_{it}$}")
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election intercb1 intergoodec)
			prehead(\begin{longtable}{m{4.5cm}*{6}{c}}
					\caption{Robustness Checks: Limits on the Executive Authority and Government Tampering with the Economy\label{govtempcb}}\\
					\toprule
					&\multicolumn{3}{c}{$\text{Real HH deposit growth}_{it}$} & \multicolumn{3}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7})
			posthead(\midrule\endfirsthead
					\multicolumn{7}{r}{\textit{Table~\ref{govtempcb} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{7}{m{\linewidth}}{\footnotesize This table reports estimates of Equation~\eqref{model2} with $ Strong\ Economy_{it} $ and its interaction wtih $ Election_{it} $ as additional controls. The case when year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ is the dependent variable as well as that when year-on-year percent change in real loans outstanding is the dependent variable are estimated. $ Strong\ Economy_{it} $ is coded as 1 if the country-year belongs to the top 50 percentile with respect to real GDP growth. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $ and $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 1.98 to 2.14. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

#delimit ;
estout govtemp_dep_rl2 govtemp_dep_rl3 govtemp_dep_rl4 govtemp_loan_rl2 govtemp_loan_rl3 govtemp_loan_rl4 using ./output/tables/robust_govtemp_rl.tex,
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
			varlabels(interbadec "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Bad economy}_{it-1}$}"
					  intermktfr "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Market-friendly}_{it}$}")
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election intermktfr interbadec)
			prehead(\begin{longtable}{m{5cm}*{6}{c}}
					\caption{Robustness Checks: Market-Friendly Incumbents and Government Tampering with the Economy\label{govtemprl}}\\
					\toprule
					&\multicolumn{3}{c}{$\text{Real HH deposit growth}_{it}$} & \multicolumn{3}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7})
			posthead(\midrule\endfirsthead
					\multicolumn{7}{r}{\textit{Table~\ref{govtemprl} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{7}{m{\linewidth}}{\footnotesize This table reports estimates of Equation~\eqref{model4} with $ Bad\ Economy_{it} $ and its interaction wtih $ Election_{it} $ as additional controls. The case when year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ is the dependent variable as well as that when year-on-year percent change in real loans outstanding is the dependent variable are estimated. $ Bad\ Economy_{it} $ is coded as 1 if the country-year belongs to the bottom 50 percentile with respect to real GDP growth. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $ and $ Market\text{-}Friendly_{it} $ is 1 if the incumbent is right- or center-leaning. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.02 to 2.19. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

#delimit ;
estout govtemp_dep_ce2 govtemp_dep_ce3 govtemp_dep_ce4 govtemp_loan_ce2 govtemp_loan_ce3 govtemp_loan_ce4 using ./output/tables/robust_govtemp_clelec.tex,
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
			varlabels(interbadec "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Bad economy}_{it-1}$}"
					  clelec "\multirow{2}{4.5cm}{$\text{Close election}_{it}$}")
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election clelec interbadec)
			prehead(\begin{longtable}{m{5cm}*{6}{c}}
					\caption{Robustness Checks: Close Elections and Government Tampering with the Economy\label{govtempce}}\\
					\toprule
					&\multicolumn{3}{c}{$\text{Real HH deposit growth}_{it}$} & \multicolumn{3}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7})
			posthead(\midrule\endfirsthead
					\multicolumn{7}{r}{\textit{Table~\ref{govtempce} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{7}{m{\linewidth}}{\footnotesize This table reports estimates of Equation~\eqref{model3} with $ Bad\ Economy_{it} $ and its interaction wtih $ Election_{it} $ as additional controls -- both for year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ and for year-on-year percent change in real loans outstanding as the dependent variables. $ Bad\ Economy_{it} $ is coded as 1 if the country-year belongs to the bottom 50 percentile with respect to real GDP growth. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $ and $ Close\ Election_{it} $ is 1 if margin of victory in the relevant election belongs to the bottom 50 percentile. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 1.98 to 2.14. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

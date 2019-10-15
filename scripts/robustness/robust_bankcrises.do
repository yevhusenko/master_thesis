/*
 Robustness: are the results robust to controlling for banking crises?
*/
clear all

use ./output/data/thesisdata.dta


*******************
** Ordinary regs
*******************

** Define macros for the regressions **
global y "dlrdeposits_hhs_w"
global x "election"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag crisis_lag L.dlrdeposits_hhs_w"
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
laglimits(. 3) collapse) robust noleveleq small
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

***************
** C&B
***************
global y "dlrdeposits_hhs_w"
global x "election intercb1 lowpolcon"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag crisis_lag L.dlrdeposits_hhs_w"
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
laglimits(. 3) collapse) robust small noleveleq
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

*************************
** Right-Left Divide
*************************
global y "dlrdeposits_hhs_w"
global x "election intermktfr mktfr"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag crisis_lag L.dlrdeposits_hhs_w"
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
laglimits(. 3) collapse) robust noleveleq small
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

************************
** Close elections
***********************
global y "dlrdeposits_hhs_w"
global x "election clelec"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag depositstogdp_lag liqratio_lag crisis_lag L.dlrdeposits_hhs_w"
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
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 3) collapse) robust noleveleq small
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

**************************** LATEX********************************************

#delimit ;
estout baseline2 baseline3 baseline4 cb2 cb3 cb4 ce2 ce3 ce4 rl2 rl3 rl4 using ./output/tables/robust_crises.tex,
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
					\caption{Political Uncertainty and Bank Deposit Growth: Are the Results Driven by Bank Crises?\label{robustcrises2}}\\
					\toprule
					&\multicolumn{12}{c}{$\text{Real HH deposit growth}_{it}$} \\ \cmidrule(lr){2-13})
			posthead(\midrule\endfirsthead
					\multicolumn{13}{r}{\textit{Table~\ref{robustcrises2} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{13}{m{\linewidth}}{\footnotesize This table shows estimates of Equations~\eqref{model1}-\eqref{model4} with year-on-year percent change in real household deposits with commercial banks in country $ i $ and year $ t $ as the dependent variable and controlling for systemic bank crises indicator of \citet{laeven2012systemic}. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority, $ Close\ Election_{it} $ is 1 if margin of victory in the relevant election belongs to the bottom 50 percentile, and $ Market\text{-}Friendly_{it} $ is 1 if the incumbent is right- or center-leaning. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.14 to 2.31. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

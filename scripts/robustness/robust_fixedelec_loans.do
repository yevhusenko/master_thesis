/* 
 Robustness: are results on bank lending robust to restricting elections
 to fixed ones?
*/

clear all
use ./output/data/thesisdata.dta


drop if fixed == 0


*********************** ORDINARY REGRESSIONS **********************************
** Define macros for the regressions **
global y "dlrloans_w"
global x "election"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
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
laglimits(. 3) collapse) robust small noleveleq 
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
global y "dlrloans_w"
global x "election intercb1 lowpolcon"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
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

************************ RIGHT-LEFT DIVIDE ************************************
global y "dlrloans_w"
global x "election intermktfr mktfr"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
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

************************ CLOSE ELECTIONS *************************************
global y "dlrloans_w"
global x "election clelec"
global macrovars "inflation_cpi lrgdppc_usd dlrgdp_lcu"
global macrolags "inflation_cpi_lag lrgdppc_usd_lag dlrgdp_lcu_lag unempl_ilo_lag"
global bankvars "capitaltoassets_lag credittodeposits_lag bankconcentr_lag liqratio_lag L.dlrloans_w"
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

************************ PRINTING TO LATEX *********************************

#delimit ;
estout baseline2 baseline3 baseline4 cb2 cb3 cb4 ce2 ce3 ce4 rl2 rl3 rl4 using ./output/tables/loanreg_fixed.tex,
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
			varlabels(intercb1 "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Weak C\&B}_{it}$}" clelec "\multirow{2}{4.5cm}{$\text{Close election}_{it}$}" intermktfr "\multirow{2}{4.5cm}{$\text{Election}_{it}$ $\times$ $\text{Market-friendly}_{it}$}")
			starl(* 0.1 ** 0.05 *** 0.01)
			keep(election intercb1 clelec intermktfr)
			prehead(\begin{longtable}{m{4.5cm}*{12}{c}}
					\caption{Political Uncertainty and Bank Loan Growth: Do the Results Hold for Fixed-Term Elections Only?\label{robustloansfixed1}}\\
					\toprule
					&\multicolumn{12}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-13})
			posthead(\midrule\endfirsthead
					\multicolumn{13}{r}{\textit{Table~\ref{robustloansfixed1} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{13}{m{\linewidth}}{\footnotesize This table presents estimates of Equations~\eqref{model1}-\eqref{model4} with year-on-year percent change in real loans outstanding with commercial banks in country $ i $ and year $ t $ as the dependent variable on samples that comprise only countries with fixed-term election schedule. A country is classified as having fixed elections if it held at least 3 elections from 2004 to 2016, and the periods between those elections were equal. $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority, $ Close\ Election_{it} $ is 1 if margin of victory in the relevant election belongs to the bottom 50 percentile and  $ Market\text{-}Friendly_{it} $ is 1 if the incumbent is right- or center-leaning. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.27 to 2.43. \( @starlegend \). }\\
					 \end{longtable})
			replace;

#delimit cr

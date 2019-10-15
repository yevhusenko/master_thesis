
/* Regressions to estimate how bank lending reacts to 
	elections. 
	Section: Political Uncertainty and Bank Lending */


clear all
use ./output/data/thesisdata.dta

winsor dlrloans, gen(dlrloans_w) p(0.01)



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
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Baseline with time fixed effects **
reg $y $x $macrolags $bankvars $politvars y1-y12, vce(cluster $clustlev)
eststo baseline2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Baseline with time and country fixed effects **
xtreg $y $x $macrolags $bankvars $politvars y1-y12, fe vce(cluster $clustlev)
eststo baseline3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Baseline with FE re-estimated using Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo baseline4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
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
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo cb2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** C&B with time and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo cb3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
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
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Right-left with year fixed effects **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo rl2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Right-left with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo rl3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Right-left with year and country FE estimed with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo rl4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************ CLOSE ELECTIONS *************************************
** Define macros for the regressions **
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
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year FE **
reg $y $x $politvars $macrolags $bankvars y1-y12, vce(cluster $clustlev)
eststo ce2
estadd local estmethod "OLS"
estadd local yearfe "Yes"
estadd local countryfe "No"
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

** Close elections with year and country FE **
xtreg $y $x $politvars $macrolags $bankvars y1-y12, fe vce(cluster $clustlev)
eststo ce3
estadd local estmethod "Within"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd scalar ftest = e(F)
display invF(e(df_b), e(df_r), 0.99)

** Close elections with year and country FE estimated with Arellano-Bond **
xtabond2 $y $x $politvars y1-y12 $macrolags $bankvars, ///
ivstyle($x $politvars y1-y12 $macrolags) gmmstyle($bankvars, ///
laglimits(. 5) collapse) robust noleveleq small
eststo ce4
estadd local estmethod "AB"
estadd local yearfe "Yes"
estadd local countryfe "Yes"
estadd local numinstr = e(j)
estadd scalar jtestp = e(hansenp)
estadd scalar artest = e(ar2p)
estadd scalar ftest = e(F)
display invF(e(df_m), e(df_r), 0.99)

************************ PRINTING TO LATEX *********************************
#delimit ;
estout baseline* using ./output/tables/baselinereg_loans.tex,
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
				  jtestp, fmt(0 3 0 0 0 0 3 3)
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
			varlabels(L.dlrloans_w "$\text{Real loan growth}_{it-1}$")
			starl(* 0.1 ** 0.05 *** 0.01)
			drop(y* _cons)
			prehead(\begin{longtable}{m{8cm}*{4}{c}}
					\caption{Political Uncertainty and Bank Loan Growth: Baseline Results \label{baselineloans}}\\
					\toprule
					&\multicolumn{4}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-5})
			posthead(\midrule\endfirsthead
					\multicolumn{5}{r}{\textit{Table~\ref{baselineloans} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{5}{l}{\footnotesize This table presents estimates of the following model:}\\
					 \multicolumn{5}{c}{\footnotesize $ \Delta y_{it} = \beta Election_{it} + X'_{it-1}\kappa +\psi \Delta y_{it-1} + \alpha_i + \alpha_t + \varepsilon_{it}, $}\\
					 \multicolumn{5}{m{\linewidth}}{\footnotesize where $ \Delta y_{it} $ denotes year-on-year percent change in real loans outstanding with commercial banks in country $ i $ and year $ t $, $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $ and $ X_{it-1} $ is the control vector. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.02 to 2.38. \( @starlegend \).}\\
					 \end{longtable})
			replace;
#delimit cr
#delimit ;
estout cb* using ./output/tables/cbreg_loans.tex,
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
				  jtestp, fmt(0 3 0 0 0 0 3 3)
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
			varlabels(L.dlrloans_w "$\text{Real loan growth}_{it-1}$")
			starl(* 0.1 ** 0.05 *** 0.01)
			drop(y* _cons)
			prehead(\begin{longtable}{m{8cm}*{4}{c}}
					\caption{Political Uncertainty and Bank Loan Growth: Checks \& Balances \label{cbloans}}\\
					\toprule
					&\multicolumn{4}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-5})
			posthead(\midrule\endfirsthead
					\multicolumn{5}{r}{\textit{Table~\ref{cbloans} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{5}{l}{\footnotesize This table shows estimation results for the following equation:}\\
					 \multicolumn{5}{c}{\footnotesize $ \Delta y_{it} = \beta_1 Election_{it} + \beta_2 Election_{it} \times Weak\ C\&B_{it} + X'_{it-1}\kappa +\psi \Delta y_{it-1} + \alpha_i + \alpha_t + \varepsilon_{it}, $}\\
					 \multicolumn{5}{m{\linewidth}}{\footnotesize where $ \Delta y_{it} $ denotes year-on-year percent change in real loans with commercial banks in country $ i $ and year $ t $, $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ Weak\ C\&B_{it} $ is 1 if country-year belongs to the bottom half of all country-years with respect to constraints on executive authority and $ X_{it-1} $ is the control vector. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.01 to 2.33. \( @starlegend \).}\\
					 \end{longtable})
			replace;
#delimit cr
#delimit ;			
estout rl* using ./output/tables/rlreg_loans.tex,
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
				  jtestp, fmt(0 3 0 0 0 0 3 3)
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
			varlabels(L.dlrloans_w "$\text{Real loan growth}_{it-1}$")
			starl(* 0.1 ** 0.05 *** 0.01)
			drop(y* _cons)
			prehead(\begin{longtable}{m{8cm}*{4}{c}}
					\caption{Political Uncertainty and Bank Loan Growth: Incumbent's Affiliation\label{rlloans}}\\
					\toprule
					&\multicolumn{4}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-5})
			posthead(\midrule\endfirsthead
					\multicolumn{5}{r}{\textit{Table~\ref{rlloans} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{5}{l}{\footnotesize This table presents estimation results for the following equation:}\\
					 \multicolumn{5}{c}{\footnotesize $ \Delta y_{it} = \beta_1 Election_{it} + \beta_2 Election_{it} \times MF_{it} + \beta_3 MF_{it} + X'_{it-1}\kappa +\psi \Delta y_{it-1} + \alpha_i + \alpha_t + \varepsilon_{it}, $}\\
					 \multicolumn{5}{m{\linewidth}}{\footnotesize where $ \Delta y_{it} $ denotes real loan growth in country $ i $ and year $ t $, $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ MF_{it} $ is 1 if the incumbent is right- or center-leaning and $ X_{it-1} $ is the control vector. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.05 to 2.34. \( @starlegend \).}\\
					 \end{longtable})
			replace;
#delimit cr
#delimit ;
estout ce* using ./output/tables/cereg_loans.tex,
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
				  jtestp, fmt(0 3 0 0 0 0 3 3)
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
			varlabels(L.dlrloans_w "$\text{Real loan growth}_{it-1}$")
			starl(* 0.1 ** 0.05 *** 0.01)
			drop(y* _cons)
			prehead(\begin{longtable}{m{8cm}*{4}{c}}
					\caption{Political Uncertainty and Bank Loan Growth: Close Elections \label{celoans}}\\
					\toprule
					&\multicolumn{4}{c}{$\text{Real loan growth}_{it}$} \\ \cmidrule(lr){2-5})
			posthead(\midrule\endfirsthead
					\multicolumn{5}{r}{\textit{Table~\ref{celoans} continued}} \\
					\toprule\endhead\midrule\endfoot\endlastfoot)
			prefoot(\midrule)
			postfoot(\bottomrule
					 \multicolumn{5}{l}{\footnotesize This table shows estimates for the following model:}\\
					 \multicolumn{5}{c}{\footnotesize $ \Delta y_{it} = \beta_1 Election_{it} + \beta_2 Close\ Election_{it} + X'_{it-1}\kappa +\psi \Delta y_{it-1} + \alpha_i + \alpha_t + \varepsilon_{it}, $}\\
					 \multicolumn{5}{m{\linewidth}}{\footnotesize where $ \Delta y_{it} $ denotes year-on-year percent change in real loans with commercial banks in country $ i $ and year $ t $, $ Election_{it} $ is 1 if country $ i $ held an executive election in year $ t $, $ Close\ Election_{it} $ is 1 if margin of victory in the relevant election belongs to the bottom 50 percentile. $ X_{it-1} $ is the control vector. Standard errors are clustered on the country level and reported in parentheses. Critical values for F-test at 0.01 significance level and actual degrees of freedom range from 2.01 to 2.33. \( @starlegend \).}\\
					 \end{longtable})
			replace;

#delimit cr

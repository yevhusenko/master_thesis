********************************* WDI DATABASE ********************************


import excel ./inputs/data/wdi.xlsx, firstrow clear

foreach i of varlist * {
	lab var `i' "`=`i'[1]'"
	replace `i' = "" if _n ==1
	destring `i', replace
}

drop if _n == 1 
drop if _n >= 3907 // drop footnote
rename countrycode iso3
destring year, replace

kountry iso3, from(iso3c) to(cown) marker
drop if countryname == "South Sudan" | countryname == "Sudan" // drop 
					// because they South Sudan split off of Sudan -- no
					// FAS data on it
replace countryname = NAMES_STD
rename _COWN_ ccode 
drop NAMES_STD MARKER
drop if missing(ccode)

order ccode, after(iso3)
tsset ccode year
sort ccode year


// *** Generate additional variables

// log of per capita GDP in USD
gen lrgdppc_usd = log(rgdppc_usd) // log GDP per capita in constant USD
gen lrgdppc_usd_lag = L.lrgdppc_usd // lagged log GDPPC in contant USD

// real growth in LCU
gen dlrgdp_lcu = ( log(rgdp_lcu) - log(L.rgdp_lcu) )*100 // real GDP growth in percent
gen dlrgdp_lcu_lag = L.dlrgdp_lcu // lagged real GDP growth

// inflation
gen inflation_cpi_lag = L.inflation_cpi // lagged inflation (CPI)
gen inflation_linkdefl_lag = L.inflation_linkdefl // lagged inflation (linked deflator)

// exchange rate
gen dlxrate = (xrate - L.xrate) / L.xrate *100  // exchange rate change in percent
gen dlxrate_lag = L.dlxrate


// is the country poor? 1 if belongs to lowest quartile by GDP (PPP) per capita
gen poor = .
forvalues t = 2000/2017 {
	su gdppc_ppp if year == `t', d
	replace poor = 1 if gdppc_ppp < r(p25) & year == `t' & !missing(gdppc_ppp)
	replace poor = 0 if gdppc_ppp >= r(p25) & year == `t' & !missing(gdppc_ppp)
}



// *** Final touch and export

gen cyear = real(string(ccode) + string(year)) 
keep countryname iso3 ccode year cyear lrgdppc_usd lrgdppc_usd_lag dlrgdp_lcu ///
			dlrgdp_lcu_lag inflation_cpi inflation_cpi_lag ///
			inflation_linkdefl inflation_linkdefl_lag ///
			linkdeflator dlxrate dlxrate_lag poor
			
order cyear, after(year)
rename countryname countrywdi

save ./output/data/wdi_upd.dta, replace

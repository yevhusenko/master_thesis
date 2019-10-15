
clear all
use ./output/data/thesisdata.dta


tsset ccode year


***************************  MAPS ************************************
mkdir ./output/tmp
shp2dta using ./inputs/maps/TM_WORLD_BORDERS-0.3.shp, data(./output/tmp/worlddata) ///
				coor(./output/tmp/worldcoor) genid(id) replace

use ./output/data/thesisdata.dta, clear
eststo clear
kountry ccode, from(cown) to(iso3c) marker
drop MARKER NAMES_STD 
rename _ISO3C_ ISO3

tsset ccode year
gen panelA = 0
replace panelA = 1 if !missing(dlrdeposits_hhs_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, depositstogdp_lag, liqratio_lag, ///
	hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrdeposits_hhs_w)
	
gen panelB = 0
replace panelB = 1 if !missing(dlrloans_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, liqratio_lag, ///
	credittodeposits_lag, bankconcentr_lag, hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrloans_w)

merge m:1 ISO3 using ./output/tmp/worlddata.dta

by ccode, sort: gen n_elecA = sum(election) if _merge == 3
by ccode, sort: gen nA = _n 								// to keep only the last observation
by ccode, sort: egen maxpanelA = max(panelA)				// to keep the country or not?
keep if nA == 12 | _merge == 2
replace n_elecA = . if maxpanelA == 0


spmap n_elecA using ./output/tmp/worldcoor, id(id) fcolor(Pastel1) ///
				ndfcolor(gs14) clmethod(unique) osize(vthin) ndsize(vthin)
graph export ./output/plots/map1.png, as(png) replace

graph drop _all
use ./output/data/thesisdata.dta, clear
eststo clear

kountry ccode, from(cown) to(iso3c) marker
drop MARKER NAMES_STD 
rename _ISO3C_ ISO3

tsset ccode year
gen panelA = 0
replace panelA = 1 if !missing(dlrdeposits_hhs_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, depositstogdp_lag, liqratio_lag, ///
	hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrdeposits_hhs_w)
	
gen panelB = 0
replace panelB = 1 if !missing(dlrloans_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, liqratio_lag, ///
	credittodeposits_lag, bankconcentr_lag, hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrloans_w)

merge m:1 ISO3 using ./output/tmp/worlddata.dta

by ccode, sort: gen n_elecB = sum(election) if _merge == 3
by ccode, sort: gen nB = _n 								// to keep only the last observation
by ccode, sort: egen maxpanelB = max(panelB)				// to keep the country or not?
keep if nB == 12 | _merge == 2
replace n_elecB = . if maxpanelB == 0


spmap n_elecB using ./output/tmp/worldcoor, id(id) fcolor(Pastel1) ///
				ndfcolor(gs14) clmethod(unique) osize(vthin) ndsize(vthin)
graph export ./output/plots/map2.png, as(png) replace


shell rm -r ./output/tmp

************************ Histogram of the elections **********************************
clear all
use ./output/data/thesisdata.dta, clear
graph drop _all

tsset ccode year
gen panelA = 0
replace panelA = 1 if !missing(dlrdeposits_hhs_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, depositstogdp_lag, liqratio_lag, ///
	hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrdeposits_hhs_w)
	
gen panelB = 0
replace panelB = 1 if !missing(dlrloans_w, election, inflation_cpi_lag, lrgdppc_usd_lag, ///
	dlrgdp_lcu_lag, unempl_ilo_lag, capitaltoassets_lag, depositstogdp_lag, liqratio_lag, ///
	credittodeposits_lag, bankconcentr_lag, hf_prights_lag, ti_cpi_lag, lowpolcon, L.dlrloans_w)

	
graph bar (sum) election if panelA == 1, over(year) graphregion(fcolor(white)) ///
				ytitle("Number of elections") ///
				bar(1, color(gray)) name(elec_frequency)	
graph export ./output/plots/elec_freq.png, name(elec_frequency) as(png) replace

graph bar (sum) election if panelB == 1, over(year) graphregion(fcolor(white)) ///
				ytitle("Number of elections") ///
				bar(1, color(gray)) name(elec_frequency2)	
graph export ./output/plots/elec_freq2.png, name(elec_frequency2) as(png) replace

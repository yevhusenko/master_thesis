********************* DEPOSIT INSURANCE SCHEME ********************************

/* Do countries in my sample had deposit insurance?
	Source: Demirguc-Kunt, Kane, Laeven (2014)
*/

use ./output/data/thesisdata_int.dta, clear
keep countryfas ccode year cyear

gen depinsurance = 0

// Africa
replace depinsurance = 1 if inlist(countryfas, "Cameroon", ///
"Central African Republic","Chad", "Congo", "Equatorial Guinea", "Gabon")  & year >=2011
replace depinsurance = 1 if inlist(countryfas, "Kenya", "Nigeria", "Tanzania", "Uganda", "Zimbabwe")

// Asia-Pacific
replace depinsurance = 1 if countryfas == "Australia" & year >=2008
replace depinsurance = 1 if inlist(countryfas, "Bangladesh", "India", "Indonesia", ///
"Japan", "South Korea", "Laos", "Philippines", "Vietnam")
replace depinsurance = 1 if countryfas == "Brunei" & year >= 2011
replace depinsurance = 1 if countryfas == "Malaysia" & year >=2005
replace depinsurance = 1 if countryfas == "Mongolia" & year >=2013
replace depinsurance = 1 if countryfas == "Nepal" & year >=2010
replace depinsurance = 1 if countryfas == "Singapore" & year >=2006
replace depinsurance = 1 if countryfas == "Sri Lanka" & year >=2012
replace depinsurance = 1 if countryfas == "Thailand" & year >= 2008

// Europe
replace depinsurance = 1 if inlist(countryfas, "Albania", "Austria", "Belarus", ///
"Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark")
replace depinsurance = 1 if inlist(countryfas, "Estonia", "Finland", "France", ///
"Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia")
replace depinsurance = 1 if countryfas == "Iceland"
replace depinsurance = 1 if inlist(countryfas, "Macedonia", "Moldova", "Netherlands", ///
"Norway", "Poland", "Portugal", "Romania", "Russia", "Slovak Republic")
replace depinsurance = 1 if inlist(countryfas, "Spain", "Sweden", "Switzerland", ///
"Turkey", "Ukraine", "United Kingdom", "Luxembourg", "Lithuania", "Slovenia")
replace depinsurance = 1 if countryfas == "Bosnia and Herzogovina"
replace depinsurance = 1 if countryfas == "Malta"

// Middle East and Central Asia
replace depinsurance = 1 if countryfas == "Afghanistan" & year >=2009
replace depinsurance = 1 if inlist(countryfas, "Algeria", "Jordan", "Kazakhstan", ///
"Lebanon", "Morocco", "Oman", "Tajikistan", "Uzbekistan")
replace depinsurance = 1 if countryfas == "Armenia" & year >=2005
replace depinsurance = 1 if countryfas == "Azerbaijan" & year >=2007
replace depinsurance = 1 if countryfas == "Kyrgyz Republic" & year >=2008
replace depinsurance = 1 if countryfas == "Libya" & year >=2010
replace depinsurance = 1 if countryfas == "Yemen" & year >=2008
replace depinsurance = 1 if countryfas == "Mauritania" & year >= 2008

// Western Hemisphere
replace depinsurance = 1 if inlist(countryfas, "Argentina", "Brazil", "Canada", ///
"Chile", "Colombia", "Ecuador", "El Salvador", "Guatemala", "Honduras")
replace depinsurance = 1 if inlist(countryfas, "Jamaica", "Mexico", "Nicaragua", ///
"Paraguay", "Peru", "Trinidad and Tobago", "United States","Uruguay", "Venezuela")
replace depinsurance = 1 if countryfas == "Bahamas"
replace depinsurance = 1 if countryfas == "Barbados" & year >= 2007

replace depinsurance = . if year > 2013
save ./output/data/depinsurance.dta, replace


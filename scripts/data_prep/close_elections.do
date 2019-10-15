// use ./output/data/thesisdata_int.dta, clear


gen secround = 0

// US
replace vote_closeness2 = 52.92 - 45.66 if cyear == 22008 // US Pres 2008 pop vote
replace vote_closeness_seats2 = (365-173) / 538 *100 if cyear == 22008 // US Pres 2008 EC vote
replace vote_closeness2 = 51.1 - 47.2 if cyear == 22012 // US Pres 2012 pop vote
replace vote_closeness_seats2 = (332 - 206) / 538 *100  if cyear == 22012 // US Pres 2012 EC vote
replace vote_closeness2 = 46.1 - 48.2 if cyear == 22016 // US Pres 2016 pop vote
replace vote_closeness_seats2 = (304 - 227) / 538 *100 if cyear == 22016 // US Pres 2016 EC vote
replace vote_closeness_seats1 = vote_closeness_seats2 if ccode == 2 // total and biggest are same for the US


// Add data on presidential election closeness. Note that here we deal with 
// countries where popular vote determines the winner. That's why we assign
// values to all three variables below

foreach i of varlist vote_closeness2 vote_closeness_seats1 vote_closeness_seats2 {

// Dominican Republic
replace `i' = 53.83 - 40.48 if cyear == 422008 // Dominican Rep. Pres 2008 pop vote
replace `i' = 51.21 - 46.95 if cyear == 422012 // Dominican Rep. Pres 2012 pop vote
replace `i' = 61.74 - 34.98 if cyear == 422016 // Dominican Rep. Pres 2016 pop vote

// Mexico
replace `i' = 36.7 - 36.1 if cyear == 702006 // Mexico Pres 2006 pop vote
replace `i' = 39.17 - 32.39 if cyear == 702012 // Mexico Pres 2012 pop vote

// Guatemala
replace `i' = 52.84 - 47.16 if cyear == 902007 // Guatemala Pres 2007 pop vote, 2nd round
replace `i' = 53.74 - 46.26 if cyear == 902011 // Guatemala Pres 2011 pop vote, 2nd round
replace `i' = 67.4 - 32.6 if cyear == 902015 // Guatemala Pres 2015 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 902007, 902011, 902015)

// Honduras
replace `i' = 49.9 - 46.2 if cyear == 912005 // 2005 plurality vote
replace `i' = 56.56 - 38.1 if cyear == 912009 // 2009 plurality vote
replace `i' = 36.89 - 28.75 if cyear == 912013 // 2013 plurality vote

// El Salvador
replace `i' = 51.32 - 48.68 if cyear == 922009 // Salvador Pres 2009 pop vote
replace `i' = 50.11 - 49.89 if cyear == 922014 // Salvador Pres 2014 pop vote, 2nd round
replace secround = 1 if cyear == 922014

// Costa Rica
replace `i' = 40.92 - 39.8 if cyear == 942006 // Costa Rica Pres 2006 pop vote
replace `i' = 46.78 - 25.15 if cyear == 942010 // Costa Rica Pres 2010 pop vote
replace `i' = 77.81 - 22.19 if cyear == 942014 // Costa Rica Pres 2014 pop vote, 2nd round
replace secround = 1 if cyear == 942014

// Panama
replace `i' = 60.03 - 37.65 if cyear == 952009 // 2009 pop vote
replace `i' = 39.07 - 31.4 if cyear == 952014 // 2014 pop vote

// Colombia
replace `i' = 62.35 - 22.03 if cyear == 1002006 // 2006 pop vote
replace `i' = 69.06 - 27.53 if cyear == 1002010 // 2010 pop vote, 2nd round
replace `i' = 50.95 - 45 if cyear == 1002014 // 2014 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 1002010, 1002014) 

// Ecuador
replace `i' = 56.67 - 43.33 if cyear == 1302006 // 2006 pop vote, 2nd round
replace `i' = 51.79 - 28.13 if cyear == 1302009 // 2009 pop vote
replace `i' = 57.17 - 22.68 if cyear == 1302013 // 2009 pop vote
replace secround = 1 if cyear == 1302006

// Peru
replace `i' = 52.63 - 47.37 if cyear == 1352006 // 2006 pop vote, 2nd round
replace `i' = 51.45 - 48.55 if cyear == 1352011 // 2011 pop vote, 2nd round
replace `i' = 50.12 - 49.88 if cyear == 1352016 // 2016 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 1352006, 1352011, 1352016)

// Brazil
replace `i' = 60.83 - 39.17 if cyear == 1402006 // 2006 pop vote, 2nd round
replace `i' = 56.05 - 43.95 if cyear == 1402010 //2010 pop vote, 2nd round
replace `i' = 51.64 - 48.36 if cyear == 1402014 // 2014 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 1402006, 1402010, 1402014)

// Bolivia
replace `i' = 53.74 - 28.59 if cyear == 1452005 // 2005 pop vote
replace `i' = 64.22 - 26.46 if cyear == 1452009 // 2009 pop vote
replace `i' = 61.36 - 24.23 if cyear == 1452014 // 2014 pop vote

// Paraguay
replace `i' = 42.29 - 31.83 if cyear == 1502008 // 2008 pop vote
replace `i' = 48.45 - 39.08 if cyear == 1502013 // 2013 pop vote

// Chile
replace `i' = 53.5 - 46.5 if cyear == 1552005 // 2005 pop vote, 2nd round. Note that the 2nd round took place in Jan 2006, but we still code it in 2005
replace `i' = 51.61 - 48.39 if cyear == 1552009 // 2009 pop vote, 2nd round. Same as before
replace `i' = 62.16 - 37.83 if cyear == 1552013 // 2013 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 1552005, 1552009, 1552013)

// Argentina
replace `i' = 44.92 - 22.95 if cyear == 1602007 // 2007 pop vote
replace `i' = 53.96 - 16.87 if cyear == 1602011 // 2011 pop vote
replace `i' = 51.34 - 48.66 if cyear == 1602015 // 2015 pop vote, 2nd round
replace secround = 1 if cyear == 162015

// Uruguay
replace `i' = 53.33 - 44.28 if cyear == 1652009 // 2009 pop vote, 2nd round
replace `i' = 56.63 - 43.37 if cyear == 1652014 // 2014 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 1652009, 1652014)

// Poland 
replace `i' = 54.04 - 45.96 if cyear == 2902005 // 2005 pop vote, 2nd round
replace `i' = 53.01 - 46.99 if cyear == 2902010 // 2010 pop vote, 2nd round
replace `i' = 51.55 - 48.45 if cyear == 2902015 // 2015 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 2902005, 2902010, 2902015)

// Cyprus
replace `i' = 53.37 - 46.63 if cyear == 3522008 // 2008 pop vote, 2nd round
replace `i' = 57.48 - 42.52 if cyear == 3522013 // 2013 pop vote, 2nd round
replace secround = 1 if cyear == 3522013 | cyear == 3522008

// Lithuania
replace `i' = 69.09 - 11.82 if cyear == 3682009 // 2009 pop vote
replace `i' = 59.05 - 40.95 if cyear == 3682014 // 2014 pop vote, 2nd round
replace secround = 1 if cyear == 3682009

// Ukraine
replace `i' = 48.95 - 45.47 if cyear == 3692010 // 2010 pop vote, 2nd round
replace `i' = 54.7 - 12.81 if cyear == 3692014 // 2014 pop vote 
replace secround = 1 if cyear == 3692010

// Armenia
replace `i' = 52.89 - 21.58 if cyear == 3712008 // 2008 pop vote
replace `i' = 56.67 - 35.51 if cyear == 3712013 // 2013 pop vote

// Georgia
replace `i' = 53.47 - 25.69 if cyear == 3722008 // 2008 pop vote
replace `i' = 62.11 - 21.73 if cyear == 3722013 // 2013 pop vote

// Cape Verde
replace `i' = 50.98 - 49.02 if cyear == 4022006 // 2006 pop vote
replace `i' = 54.26 - 45.74 if cyear == 4022011 // 2011 pop vote
replace `i' = 74.08 - 22.51 if cyear == 4022016 // 2016 pop vote

// Senegal
replace `i' = 55.9 - 14.9 if cyear == 4332007 // 2007 pop vote
replace `i' = 65.8 - 34.2 if cyear == 4332012 // 2012 pop vote, 2nd round
replace secround = 1 if cyear == 4332012

// Benin
replace `i' = 74.6 - 25.4 if cyear == 4342006 // 2006 pop vote, 2nd round
replace `i' = 53.14 - 35.64 if cyear == 4342011 // 2011 pop vote
replace `i' = 65.39 - 34.61 if cyear == 4342016 // 2016 pop vote, 2nd round
replace secround = 1 if inlist(cyear, 4342006, 4342016)

// Liberia
replace `i' = 90.7 - 9.3 if cyear == 4502011 // 2011 pop vote, 2nd round
replace secround = 1 if cyear == 4502011

// Sierra Leone
replace `i' = 54.62 - 45.38 if cyear == 4512007 // 2007 pop vote, 2nd round
replace `i' = 58.65 - 37.36 if cyear == 4512012 // 2012 pop vote
replace secround = 1 if cyear == 4512007

// Ghana
replace `i' = 50.23 - 49.77 if cyear == 4522008 // 2008 pop vote, 2nd round
replace `i' = 50.7 - 47.74 if cyear == 4522012 // 2012 pop vote
replace `i' = 53.85 - 44.4 if cyear == 4522016 // 2016 pop vote
replace secround = 1 if cyear == 4522008

// Uganda
replace `i' = 59.26 - 37.39 if cyear == 5002006 // 2006 pop vote
replace `i' = 68.36 - 26.01 if cyear == 5002011 // 2011 pop vote
replace `i' = 60.75 - 35.37 if cyear == 5002016 //2016 pop vote

// Kenya
replace `i' = 46.42 - 44.07 if cyear == 5012007 // 2007 plurality vote
replace `i' = 50.51 - 43.75 if cyear == 5012013 // 2013 plurality vote

// Tanzania
replace `i' = 80.28 - 11.68 if cyear == 5102005 // 2005 pop vote
replace `i' = 62.83 - 27.05 if cyear == 5102010 // 2010 pop vote
replace `i' = 58.5 - 40 if cyear == 5102015 // 2015 pop vote

// Mozambique 
replace `i' = 75.01 - 16.41 if cyear == 5412009 // 2009 pop vote
replace `i' = 57.03 - 36.61 if cyear == 5412014 // 2014 pop vote

// Malawi
replace `i' = 65.98 - 30.69 if cyear == 5532009 // 2009 pop vote
replace `i' = 36.4 - 27.8 if cyear == 5532014 // 2014 plurality vote

// Namibia 
replace `i' = 75.25 - 10.91 if cyear == 5652009 // 2009 pop vote
replace `i' = 86.73 - 4.97 if cyear == 5652014 // 2014 pop vote

// Comoros
replace `i' = 58.02 - 28.32 if cyear == 5812006
replace `i' = 60.91 - 32.81 if cyear == 5812010
replace election =  1 if cyear == 5812010
replace `i' = 40.98 - 39.87 if cyear == 5812016

// Mongolia
replace `i' = 54.2 - 20.2 if cyear == 7122005 // 2005 pop vote
replace `i' = 51.85 - 48 if cyear == 7122009 // 2009 pop vote
replace `i' = 50.23 - 41.97 if cyear == 7122013 // 2013 pop vote

// Kyrgyz Republic
replace `i' = 63.56 - 14.84 if cyear == 7032011 // 2011 pop vote

// South Korea 
replace `i' = 48.67 - 26.15 if cyear == 7322007 // 2007 plurality vote
replace `i' = 51.56 - 48.02 if cyear == 7322012 // 2012 plurality vote

// Sri Lanka
replace `i' = 50.29 - 48.43 if cyear == 7802005 // 2005 pop vote
replace `i' = 57.88 - 40.15 if cyear == 7802010 // 2010 pop vote
replace `i' = 51.28 - 47.58 if cyear == 7802015 // 2015 pop vote

// Philippines
replace `i' = 42.08 - 26.25 if cyear == 8402010 // 2010 pop vote
replace `i' = 38.6 - 23.4 if cyear == 8402016 // 2016 pop vote

// Indonesia
replace `i' = 60.8 - 26.79 if cyear == 8502009 // 2009 pop vote
replace `i' = 53.15 - 46.85 if cyear == 8502014 // 2014 pop vote

// Timor
replace `i' = 69.18 - 30.82 if cyear == 8602007 // 2007 pop vote, 2nd round
replace `i' = 61.23 - 38.77 if cyear == 8602012 // 2012 pop vote, 2nd round
replace secround =1 if inlist(cyear, 8602007, 8602012)

}


// Fill missing values for legislative elections

// Switzerland
replace vote_closeness2 = 28.9 - 19.5 if cyear == 2252007 // 2007 pop vote
replace vote_closeness2 = 29.4 - 18.8 if cyear == 2252015 // 2015 pop vote

// Italy
replace vote_closeness2 = 47.32 - 38.01 if cyear == 3252008 // 2008 pop vote
replace vote_closeness2 = 31.64 - 30.72 if cyear == 3252013 // 2008 pop vote

// Greece
replace vote_closeness2 = 29.66 - 26.89 if cyear == 3502012 // June 2012 pop vote

// Bulgaria
replace vote_closeness2 = 32.67 - 15.4 if cyear == 3552014 // 2014 pop vote

// Romania
replace vote_closeness2 = 60.16 -16.73 if cyear == 3602012 // 2012 pop vote

// Latvia
replace vote_closeness2 = 31.9 - 26.61 if cyear == 3672010 // 2010 pop vote

// Japan
replace vote_closeness2 = 42.21 - 26.73 if cyear == 7402009 // 2009
replace vote_closeness2 = 31.6 - 24.1 if cyear == 7402010 // 2010
replace vote_closeness2 = 33.11 - 18.33 if cyear == 7402014 // 2014 

// India
replace vote_closeness2 = 28.6 - 18.9 if cyear == 7502009 // 2009 pop vote

// Pakistan
replace vote_closeness2 = 32.77 - 16.92 if cyear == 7702013 // 2013 pop vote

// Thailand
replace vote_closeness2 = 56.4 - 16.1 if cyear == 8002005 // 2005 pop vote
replace vote_closeness2 = 48.41 - 35.51 if cyear == 8002011

// Czech Republic 
replace vote_closeness2 = 20.45 - 18.65 if cyear == 3162013 // 2013 pop vote

// Jamaica
replace vote_closeness2 = 53.3 - 46.6 if cyear == 512011 // 2011 pop vote
replace vote_closeness2 = 50.1 - 49.7 if cyear == 512016 // 2016 pop vote

// Barbados 
replace vote_closeness2 = 51.3 - 48.2 if cyear == 532013 // 2013 pop vote

// Saint Lucia
replace vote_closeness2 = 51.34 - 48.32 if cyear == 562006 // 2006 pop vote
replace vote_closeness2 = 51 - 47 if cyear == 562011 // 2011 pop vote
replace vote_closeness2 = 54.75 - 44.09 if cyear == 562016 // 2016 pop vote

// Suriname
replace vote_closeness2 = 45.46 - 37.29 if cyear == 1152015 // 2015 pop vote

// Hungary 
replace vote_closeness2 = 52.73 - 19.3 if cyear == 3102010 // 2010 pop vote

// Bosnia and Herzegovina
replace vote_closeness2 = 16.39 - 16.21 if cyear == 3462010 // 2010 pop vote
replace vote_closeness2 = 18.74 - 15.64 if cyear == 3462014 // 2014 pop vote

// Lesotho
replace vote_closeness2 = 52.6 - 28.4 if cyear == 5702007
replace vote_closeness2 = 39.58 - 25.18 if cyear == 5702012
replace vote_closeness2 = 38.71 - 38.12 if cyear == 5702015

// Mauritius
replace vote_closeness2 = 49.69 - 42.01 if cyear == 5902010
replace vote_closeness2 = 49.83 - 38.51 if cyear == 5902014

// Israel
replace vote_closeness2 = 23.32 - 14.32 if cyear == 6662013

// Australia
replace vote_closeness2 = 35.31 - 21.53 if cyear == 9002010
replace vote_closeness2 = 33.38 - 32.02 if cyear == 9002013
replace vote_closeness2 = 34.73 - 28.67 if cyear == 9002016

// Papua New Guinea -- data not available

// Vanuatu
replace vote_closeness2 = 24.23 - 15.66 if cyear == 9352008
replace vote_closeness2 = 12.19 - 11.29 if cyear == 9352012
replace vote_closeness2 = 11.91 - 9.73 if cyear == 9352016

// Solomon Islands
replace vote_closeness2 = 6.87 - 6.31 if cyear == 9402006
replace vote_closeness2 = 11.3 - 6.7 if cyear == 9402010
replace vote_closeness2 = 10.72 - 7.78 if cyear == 9402014

// Samoa
replace vote_closeness2 = 51.66 - 26.1 if cyear == 9902006
replace vote_closeness2 = 55.6 - 24.7 if cyear == 9902011
replace vote_closeness2 = 56.11 - 35.1 if cyear == 9902016



local x "vote_closeness_seats2"
// Jamaica
replace `x' = (42 - 21)/63 *100 if cyear == 512011 
replace `x' = (32 - 31)/63 * 100 if cyear == 512016

// Barbados
replace `x' = (16-14)/30*100 if cyear == 532013

// Saint Lucia
replace `x' = (11 - 6)/17 *100 if cyear == 562006
replace `x' = (11 - 6)/17 *100 if cyear == 562011
replace `x' = (11 - 6)/17 *100 if cyear == 562016

// Suriname
replace `x' = (26-18)/51 * 100 if cyear == 1152015

// Hungary
replace `x' = (263-59)/386 * 100 if cyear == 3102010

// Czech Rep.
replace `x' = (50 - 47)/200 * 100 if cyear == 3162013

// Italy
replace `x' = (272 - 211)/630 * 100 if cyear == 3252008

// Bosnia
replace `x' = (10 - 6)/42 * 100 if cyear == 3462014

// Bulgaria
replace `x' = (84-39)/240 * 100 if cyear == 3552014

// Latvia
replace `x' = (33-29)/100 * 100 if cyear == 3672010

// Lesotho
replace `x' = (47 - 46)/120 * 100 if cyear == 5702015

// Mauritius
replace `x' = (47-13)/62 * 100 if cyear == 5902014

// India
replace `x' = (206-116)/543 * 100 if cyear == 7502009

// Australia
replace `x' = (72-44)/150 * 100 if cyear == 9002010
replace `x' = (58-55)/150 * 100 if cyear == 9002013
replace `x' = (69-45)/150 * 100 if cyear == 9002016

// Solomon Islands
replace `x' = (4-4)/50 *100 if cyear == 9402006
replace `x' = (13-3)/50 *100 if cyear == 9402010

// Samoa
replace `x' = (35 - 10)/49 * 100 if cyear == 9902006
replace `x' = (29 - 13)/49 * 100 if cyear == 9902011
replace `x' = (35-2)/49 * 100 if cyear == 9902016

// Grenada
replace `x' = (15-0)/15 *100 if cyear == 552013
replace `x' = 0 if inlist(cyear, 552014, 552015, 552016)

// Panama
replace `x' = 0 if inlist(cyear, 952010, 952011, 952012, 952013, 1002005)

// save ./output/data/thesisdata_int.dta, replace

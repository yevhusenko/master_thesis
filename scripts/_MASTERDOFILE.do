*********************** MASTER DO-FILE ***************************


global ROOT "/Users/usenk/Desktop/research/master_thesis"
cd "$ROOT"

// Verify that packages are installed and if not, install them
local packages "coefplot spmap shp2dta mif2dta xtabond2 tsspell kountry xtpatternvar winsor estout"
foreach p of local packages {
	capture which `p'
	if _rc != 0 {
		ssc install `p'
	}
}


*** Prepare the data

run ./scripts/data_prep/fas.do   				// IMF's Financial Access Survey data
run ./scripts/data_prep/dpi.do 					// DPI (2017)
run ./scripts/data_prep/wdi.do 					// World Bank's WDI
run ./scripts/data_prep/gfd.do 					// Global Financial Development Database
run ./scripts/data_prep/adtnl_macrovars.do   	// Additional vars from WDI
run ./scripts/data_prep/merge.do 				// Merge everything into one file
run ./scripts/data_prep/final_prep.do



*** Summary statistics
if "`c(os)'" == "MacOSX" | "`c(os)'" == "Linux" {
	local python = "/usr/local/bin/python3"
}
else {
	local python = "python.exe"
}

shell "`python'" ./scripts/summary/descstats.py

run ./scripts/summary/summary_plots.do		// descriptive statistics tables and figures
shell "`python'" ./scripts/summary/coef_plots.py	// prelim. results figures

*** Regressions

// main regressions with real HH deposit growth as the dependent variable
run ./scripts/regressions/deposit_regressions.do
// main regressions with real loan growth as the dependent variable
run ./scripts/regressions/loans_regressions.do


*** Robustness checks
run ./scripts/robustness/robust_fixedelec.do  				// deposits -- fixed elections only
run ./scripts/robustness/robust_fixedelec_loans.do 			// loans -- fixed elections only
run ./scripts/robustness/robust_bankcrises.do 				// deposits -- add systemic banking crisis indicator of Laeven and Valencia
run ./scripts/robustness/robust_bankcrises_loans.do 		// loans -- add systemic banking crisis indicator
run ./scripts/robustness/robust_wealth_alt_clelec.do		// gvmt tampering, C&B and wealth level and another close election measure
run ./scripts/robustness/robust_dropsmall.do				// deposits -- drop small countries
run ./scripts/robustness/robust_dropsmall_loans.do			// loans -- drop small countries
run ./scripts/robustness/robust_alldeposits.do					// total deposits



*** Compile Latex (tested on MacOSX)
cd main_tex
local pdflatex "/Library/TeX/texbin/pdflatex"
local bibtex "/Library/TeX/texbin/bibtex"

quietly shell "`pdflatex'" thesis.tex
quietly shell "`bibtex'" thesis.aux
quietly shell "`pdflatex'" thesis.tex
quietly shell "`pdflatex'" thesis.tex

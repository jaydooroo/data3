
log using data3.log, replace


clear  

use pwt1001.dta

sort country year

drop if year < 1950 | year > 2000


replace country = "Bolivia" if country == "Bolivia (Plurinational State of)"
replace country = "Bosnia-Herzegovina" if country == "Bosnia and Herzegovina"
replace country = "Burma" if country == "Myanmar" 
replace country = "Macao" if country == "China, Macao SAR"
replace country = "Hong Kong" if country == "China, Hong Kong SAR"
// replace country = "Czech Republic" if country == "Czechoslovakia"  
replace country = "Democratic Republic of the Congo" if country == "D.R. of the Congo"
replace country = "Iran" if country == "Iran (Islamic Republic of)"
replace country = "Laos" if country == "Lao People's DR"
replace country = "Macedonia" if country == "North Macedonia" 
replace country = "Moldova" if country == "Republic of Moldova"
replace country = "Russia" if country == "Russian Federation"
replace country = "South Korea" if country == "Republic of Korea"
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Tanzania" if country == "U.R. of Tanzania: Mainland"
replace country = "Venezuela" if country == "Venezuela (Bolivarian Republic of)"
replace country = "Vietnam" if country == "Viet Nam"

export delimited using pwt1001_mod

save "C:\Users\ejh612\Documents\data3\pwt1001_mod.dta", replace



clear

use chat.dta

rename country_name country

sort country year

drop if year < 1950 | year > 2000

drop if country == "Czechoslovakia" 


replace country = "Bolivia" if country == "Bolivia (Plurinational State of)"
replace country = "Bosnia-Herzegovina" if country == "Bosnia and Herzegovina"
replace country = "Burma" if country == "Myanmar" 
replace country = "Macao" if country == "China, Macao SAR"
replace country = "Hong Kong" if country == "China, Hong Kong SAR"
// replace country = "Czech Republic" if country == "Czechoslovakia"  
replace country = "Democratic Republic of the Congo" if country == "D.R. of the Congo"
replace country = "Iran" if country == "Iran (Islamic Republic of)"
replace country = "Laos" if country == "Lao People's DR"
replace country = "Macedonia" if country == "North Macedonia" 
replace country = "Moldova" if country == "Republic of Moldova"
replace country = "Russia" if country == "Russian Federation"
replace country = "South Korea" if country == "Republic of Korea"
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Tanzania" if country == "U.R. of Tanzania: Mainland"
replace country = "Venezuela" if country == "Venezuela (Bolivarian Republic of)"
replace country = "Vietnam" if country == "Viet Nam"



save "C:\Users\ejh612\Documents\data3\chat_mod.dta", replace

export delimited using chat_mod

merge 1:1 country year using pwt1001_mod.dta

drop if _merge ==1 | _merge == 2

export delimited using result, replace

// keep country countrycode year ag_harvester internetuser cellphone cabletv newspaper rgdpe pop
keep country countrycode year radio  telephone tv vehicle_car elecprod rgdpe pop

gen developed = inlist(country, "France", "Germany", "Italy", "Japan", "United Kingdom", "United States")

gen gdp_per_capita = rgdpe / pop

reshape wide gdp_per_capita radio  telephone tv vehicle_car elecprod rgdpe pop , i(country) j(year)


forvalues i = 1950/2000 {    
 local j =  `i' + 1      
 gen gdpgwt`i' = ((gdp_per_capita`j'/gdp_per_capita`i')-1)*100,   
 gen radiogwt`i' = ((radio`j'/radio`i')-1)*100, 
 gen telephonegwt`i' = ((telephone`j'/telephone`i')-1)*100, 
 gen tvgwt`i' = ((tv`j'/tv`i')-1)*100,
 gen vehicle_cargwt`i' = ((vehicle_car`j'/vehicle_car`i')-1)*100,
 gen elecprodgwt`i' = ((elecprod`j'/elecprod`i')-1)*100,
 }

 

 reshape long gdp_per_capita  radio  telephone tv vehicle_car elecprod rgdpe pop gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt, i(country) j(year) 
preserve 
 
collapse (mean) gdpgwt [aweight = pop], by(developed)
list developed gdpgwt 


restore

// harvest tech usage growth
preserve 
collapse (mean) radiogwt , by(developed)
list developed radiogwt 
restore

// internet usage growth 
preserve 
collapse (mean) telephonegwt , by(developed)
list developed telephonegwt 
restore


preserve 
collapse (mean) tvgwt , by(developed)
list developed tvgwt 
restore

preserve 
collapse (mean) vehicle_cargwt , by(developed)
list developed vehicle_cargwt 
restore

preserve 
collapse (mean) elecprodgwt , by(developed)
list developed elecprodgwt 
restore


* Create interaction terms
gen radiogwt_developed = radiogwt * developed
gen telephonegwt_developed = telephonegwt * developed
gen tvgwt_developed = tvgwt * developed
gen vehicle_cargwt_developed = vehicle_cargwt * developed
gen elecprodgwt_developed = elecprodgwt * developed


* Run the regression with interaction terms
regress gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt developed radiogwt_developed telephonegwt_developed tvgwt_developed vehicle_cargwt_developed elecprodgwt_developed


regress gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt developed
 encode country, generate(country_code)
xtset country_code year
xtreg gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt developed, fe

// xtreg gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt developed radiogwt_developed telephonegwt_developed tvgwt_developed vehicle_cargwt_developed elecprodgwt_developed, fe

predict predicted_gdpgwt

twoway (scatter gdpgwt predicted_gdpgwt), title("Predicted vs Actual GDP Growth") xtitle("Predicted GDP Growth")
twoway (scatter gdpgwt telephonegwt) (lfit gdpgwt telephonegwt), 

tsline gdpgwt, title("Average GDP Growth Rate Over Time") ylabel(, format(%9.0g)) xlabel(, grid) ytitle("GDP Growth Rate (%)") xtitle("Year") legend(label(1 "GDP Growth Rate"))



xtset country_code year
xtline gdpgwt if developed == 1, overlay title("GDP Growth Rate Over Time by Development Status") ylabel(, format(%9.0g)) xlabel(, grid) ytitle("GDP Growth Rate (%)") xtitle("Year") legend(label(1 "Developed Countries") label(2 "Developing Countries")) scheme(s1mono)

xtline gdpgwt if developed == 0, overlay title("GDP Growth Rate Over Time by Development Status") ylabel(, format(%9.0g)) xlabel(, grid) ytitle("GDP Growth Rate (%)") xtitle("Year") legend(label(1 "Developed Countries") label(2 "Developing Countries")) scheme(s1mono)

preserve
collapse (mean) gdpgwt, by(year developed)
twoway (line gdpgwt year if developed == 1, lcolor(blue)) (line gdpgwt year if developed == 0, lcolor(red)),legend(label(1 "Developed Countries") label(2 "Developing Countries")) title("GDP Growth Over Time") xtitle("Year") ytitle("Average GDP Growth Rate (%)") graphregion(color(white)) plotregion(color(white)) 
restore


// preserve
// collapse (mean) radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt, by(year developed)
// reshape wide radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt, i(year) j(developed)
//
// twoway (line radiogwt1 year, lcolor(blue) title("Radio Growth")) (line radiogwt0 year, lcolor(red)) 
// (line telephonegwt1 year, lcolor(blue) title("Telephone Growth")) ///
// (line telephonegwt0 year, lcolor(red)) ///
// (line tvgwt1 year, lcolor(blue) title("TV Growth")) ///
// (line tvgwt0 year, lcolor(red)) ///
// (line vehicle_cargwt1 year, lcolor(blue) title("Vehicle Growth")) ///
// (line vehicle_cargwt0 year, lcolor(red)) ///
// (line elecprodgwt1 year, lcolor(blue) title("Electricity Production Growth")) ///
// (line elecprodgwt0 year, lcolor(red)) ///
// legend(label(1 "Developed - Radio") label(2 "Developing - Radio") ///
// label(3 "Developed - Telephone") label(4 "Developing - Telephone") ///
// label(5 "Developed - TV") label(6 "Developing - TV") ///
// label(7 "Developed - Vehicle") label(8 "Developing - Vehicle") ///
// label(9 "Developed - Electricity Production") label(10 "Developing - Electricity Production")) ///
// title("Technological Growth Over Time by Development Status") ///
// xtitle("Year") ///
// ytitle("Average Technology Growth Rate (%)") ///
// graphregion(color(white)) plotregion(color(white))
// restore

preserve
collapse (mean) gdpgwt radiogwt telephonegwt tvgwt vehicle_cargwt elecprodgwt, by(year)
twoway (line gdpgwt year, lcolor(red) lpattern(solid)) (line radiogwt year, lcolor(blue) lpattern(solid)) (line telephonegwt year, lcolor(red) lpattern(dash)) (line tvgwt year, lcolor(green) lpattern(dash_dot)) (line vehicle_cargwt year, lcolor(orange) lpattern(longdash)) (line elecprodgwt year, lcolor(purple) lpattern(dot)), legend(order(1 "GDP" 2 "Radio" 3 "Telephone" 4 "TV" 5 "Vehicle" 6 "Electric Production") ring(0) position(outside)) title("Technological Growth Over Time") xtitle("Year") ytitle("Average Growth Rate (%)") graphregion(color(white)) plotregion(color(white))

restore

preserve
collapse (mean) gdpgwt radiogwt telephonegwt vehicle_cargwt elecprodgwt, by(year)
twoway (line gdpgwt year, lcolor(red) lpattern(solid)) (line radiogwt year, lcolor(blue) lpattern(solid)) (line telephonegwt year, lcolor(red) lpattern(dash)) (line vehicle_cargwt year, lcolor(orange) lpattern(longdash)) (line elecprodgwt year, lcolor(purple) lpattern(dot)), legend(order(1 "GDP" 2 "Radio" 3 "Telephone" 4 "Vehicle" 5 "Electric Production") ring(0) position(outside)) title("Technological Growth Over Time") xtitle("Year") ytitle("Average Growth Rate (%)") graphregion(color(white)) plotregion(color(white))

restore

log close
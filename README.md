# data3
To accomplish our statistical experiments, we should collect data that includes technological status and GDP. To do this, we used “Penn World Table” data which contains the nations’ real GDP,  relative levels of income, output, input, and productivity, covering 183 countries between 1950 and 2019. This data is very useful to track how the GDP of the nations in the world changes over time. 

	To retrieve the data for technological status, we used NBER data which contains an unbalanced panel dataset with information on the specific amount of how well the nations adopted over 100 technologies in more than 150 countries since 1800. we used this data as an indicator of each country's technological status and we will track how technological adoption and advancements of each country change over time.

These two datasets are not useful for themselves. We had to merge two datasets and make some modifications to use them for our research. We added variables for GDP growth and technological variables growth which are calculated according to variables of each year. The formula is like this “(value of current year)  / (value of previous year)  - 1  ) x 100”. This represents the percentage of Growth for each variable. 
Since we also examined whether developed countries have higher GDP and technological growth overall, we created a variable “developed” which is a dummy variable. The developed countries in this research only include (France, Germany, Italy, Japan, the United Kingdom, and the United States of America). Other countries are classified as developing countries with 0 value of the “developed” variable.  We only used 5 selected technologies for our research. The variables are radio (radio), telephone(telephone), tv(tv), car (vehicle_car), and electricity production (elecprod). We only used data from 1970 to 2000. 

The source of data will be found below: 
Penn World Table data:  https://www.rug.nl/ggdc/productivity/pwt/
NBER data: https://data.nber.org/data-appendix/w15319/


# CMS Hospital Compare Data 2004-2016
Code to process the public use CMS Hospital Compare data. The output include CMS Hospital Compare data for the years 2004-2016. I originally processed this data focusing on the year 2006-2008 values for the HCAHPS and the AMI, CHF, and pneumonia mortality/readmission and process of care (now called timely and effective care) scores. The tables that were added more recently (e.g. hospital associated infections, structural measures) are not included. If you would like to use this data in your own research, I urge you test it carefully.

# Instructions
1. Download the repository using the 'Clone or download' link on github, or clone this repository with the git command: `git clone https://github.com/asacarny/hospital-compare.git`
1. Download the most recent hospital compare source data from my website, http://sacarny.com/data/, and extract it into the repository
1. Open stata, change its working directory to the repository, and run `do process.do`

# Todo
* Provide the shares of patients taking on each response value in the HCAHPS results
* Process the other Hospital Compare measures, like hospital associated infections and patient safety indicators
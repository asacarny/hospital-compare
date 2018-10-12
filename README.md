# CMS Hospital Compare Data 2004-2016
Here you'll find code to process the public use CMS Hospital Compare data. The output include CMS Hospital Compare data for the years 2004-2016. I originally processed this data focusing on the year 2006-2008 values for the HCAHPS and the AMI, CHF, and pneumonia mortality/readmission and process of care (now called timely and effective care) scores. The tables that were added more recently (e.g. hospital associated infections, structural measures) are not included. If you would like to use this data in your own research, I urge you test it carefully.

# Quick Start
The processed data can be downloaded here:
## Process of Care Scores, 2004-2016
Shares of patients receiving evidence-based treatments for AMI, CHF, pneumonia, surgical care, and outpatient care. All-payer.
(Includes data in Stata v14, Stata v11, and CSV formats, plus full variable descriptions for those not using Stata. Also includes full names of process measures.)
http://sacarny.com/public-files/hospital-compare/latest/hospital-compare-poc.zip

## HCAHPS, 2007-2016
Average scores for the aggregated questions in HCAHPS patient satisfaction survey. All-payer.
(Includes data in Stata v14, Stata v11, and CSV formats, plus full variable descriptions for those not using Stata. Also includes listing of numeric values I assigned to question responses.)
http://sacarny.com/public-files/hospital-compare/latest/hospital-compare-hcahps.zip

## Mortality (2007-2016) and Readmission (2008-2016)
Estimates of AMI, CHF, and pneumonia mortality and readmission rates. Medicare FFS patients only.
(Includes data in Stata v14, Stata v11, and CSV formats, plus full variable descriptions for those not using Stata.)
http://sacarny.com/public-files/hospital-compare/latest/hospital-compare-mortreadm.zip

# Instructions for processing the data yourself
1. Download the repository using the 'Clone or download' link on github, or clone this repository with the git command:
`git clone https://github.com/asacarny/hospital-compare.git`
1. Download the most recent hospital compare source data from my website:
http://sacarny.com/public-files/hospital-compare/latest/hospital-compare-source.zip
1. Extract the zip file into the repository
1. Open stata, change its working directory to the repository, and run `do process.do`

# Todo
* Provide the shares of patients taking on each response value in the HCAHPS results
* Process the other Hospital Compare measures, like hospital associated infections and patient safety indicators
# Notes on how the hospital compare metrics were calculated

# Method

For years 2004-2010, I downloaded the data files from CMS and extracted them, yielding MS Access MDB files. Then I used the mdb-export command to extract the relevant tables into CSVs in the extracted/ folder.

For 2011, CMS simply provided the CSVs, so I used them directly.

The file process.do reads in and and converts to stata format the HCAHPS (hcahps/), mortality and readmission (mortreadm/) and process of care (poc/) measures

# Extracting files from the 2005-2008 archive

(Archive downloaded from [http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html](http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html))

## 2004 Data

According to [https://web.archive.org/web/20060926204316/http://www3.cms.hhs.gov/HospitalQualityInits/25\_HospitalCompare.asp](https://web.archive.org/web/20060926204316/http://www3.cms.hhs.gov/HospitalQualityInits/25_HospitalCompare.asp)

the September 2005 file has data from 2004Q1-2004Q4

## 2005 Data

According to [https://web.archive.org/web/20070911180040/http://www.cms.hhs.gov/HospitalQualityInits/25\_HospitalCompare.asp](https://web.archive.org/web/20070911180040/http://www.cms.hhs.gov/HospitalQualityInits/25_HospitalCompare.asp)

The file named &quot;Hospital200612Archive.zip&quot; has data from 2005Q1-2005Q4

## 2006 Data

According to [https://web.archive.org/web/20080517011029/http://www.cms.hhs.gov/hospitalqualityinits/25\_hospitalcompare.asp](https://web.archive.org/web/20080517011029/http://www.cms.hhs.gov/hospitalqualityinits/25_hospitalcompare.asp)

The file from September 2007 refresh has data from 2006Q1-2006Q4

(I verified this by comparing it to the September 2007 / Hospital200712Archive.zip file from [https://web.archive.org/web/20090111221702/http://www.cms.hhs.gov/HospitalQualityInits/11\_HospitalCompare.asp#TopOfPage](https://web.archive.org/web/20090111221702/http://www.cms.hhs.gov/HospitalQualityInits/11_HospitalCompare.asp#TopOfPage))

## 2007 Data

According to [https://web.archive.org/web/20090512050104/https://www.cms.hhs.gov/HospitalQualityInits/11\_HospitalCompare.asp](https://web.archive.org/web/20090512050104/https://www.cms.hhs.gov/HospitalQualityInits/11_HospitalCompare.asp)

Hospital200812Archive.zip has the data from 2007Q1-2007Q4

(Verified that file in 2005-2008 archive ZIP matches the analogous one from that website)

According to docs in Hospital200903Archive.zip, this includes HCAHPS scores for 2007Q1-2007Q4, and mortality quality measures from July 2006-June 2007 (2006Q3-2007Q2)

# Extracting files from 2009-2010 Archive

(Archive downloaded from [http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html](http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html))

## 2008 Data

According to [https://web.archive.org/web/20100326074622/http://www.cms.hhs.gov/HospitalQualityInits/11\_HospitalCompare.asp](https://web.archive.org/web/20100326074622/http://www.cms.hhs.gov/HospitalQualityInits/11_HospitalCompare.asp)

Hospital200912Archive.zip has the 2008Q1-2008Q4 data (couldn&#39;t download file to verify)

Includes HCAHPS 2008Q1-2008Q4, Mortality &amp; Readmission 2005Q3-2008Q2 (raised to 36 month collection period)

## 2009 Data

According to [https://web.archive.org/web/20110709095605/http://www.cms.gov/HospitalQualityInits/11\_HospitalCompare.asp](https://web.archive.org/web/20110709095605/http://www.cms.gov/HospitalQualityInits/11_HospitalCompare.asp)

Hospital201012Archive.zip has the 2009Q1-2009Q4 data (didn&#39;t download to verify)

Includes HCAHPS 2009Q1-2009Q4, Mortality &amp; Readmission 2006Q3-2009Q2

# Later Files

## 2010 Data

Pulled October 2011 archive from [http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html](http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html)

Process of Care and HCAHPS 2010Q1-2010Q4

Mortality &amp; Readmission 2007Q3-2010Q2

## 2011 Data

Pulled October 2012 archive from [http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html](http://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HospitalQualityInits/HospitalCompare.html)

Process of Care and HCAHPS 2011Q1-2011Q4

Mortality &amp; Readmission 2008Q3-2011Q2

## 2012 Data

Pulled October 2013 archive from [https://data.medicare.gov/data/archives/hospital-compare](https://data.medicare.gov/data/archives/hospital-compare)

Process of Care and HCAHPS from 2012Q1-2012Q4

Mortality &amp; Readmission 2009Q3-2012Q2 (except hospital wide)

## 2013 Data

Pulled December 2014 archive from [https://data.medicare.gov/data/archives/hospital-compare](https://data.medicare.gov/data/archives/hospital-compare)

Process of Care from 2013Q2-2014Q1 (due to system upgrades, they did not post a file that had CY2013 POC data)

HCAHPS from 2013Q1-2013Q4

Mortality &amp; Readmission 2010Q3-2013Q2 (except hospital wide)

Extract code:

`perl -e '@t = qw(Measure_Dates HQI_FTNT HQI_HOSP_HCAHPS HQI_HOSP_TimelyEffectiveCare HQI_HOSP_ReadmCompDeath HQI_HOSP_HAI HQI_HOSP_IMG HQI_HOSP_MSPB HQI_HOSP_MV HQI_OP_Procedure_Volume HQI_HOSP_STRUCTURAL); foreach $t (@t) { print("mdb-export Hospital.mdb $t > $t.csv\n"); system("mdb-export Hospital.mdb $t > $t.csv"); }'`

## 2014 Data

Pulled October 2015 archive from [https://data.medicare.gov/data/hospital-compare](https://data.medicare.gov/data/hospital-compare)

Process of Care and HCAHPS from 2014Q1-2014Q4

Mortality &amp; Readmission 2011Q3-2014Q2 (except hospital wide)

Extract code:

`perl -e '@t = qw( MEASURE_DATES HQI_FTNT HQI_HOSP_STRUCTURAL HQI_HOSP_HCAHPS HQI_HOSP_TIMELYEFFECTIVECARE HQI_HOSP_COMP HQI_HOSP_HAI  HQI_HOSP_READMDEATH HQI_HOSP_IMG HQI_HOSP_PAYMENTANDVALUEOFCARE HQI_HOSP_MSPB HQI_OP_PROCEDURE_VOLUME); foreach $t (@t) { print("mdb-export Hospital.mdb $t > $t.csv\n"); system("mdb-export Hospital.mdb $t > $t.csv"); }'`

## 2015 Data

Pulled November 2016 archive from [https://data.medicare.gov/data/hospital-compare](https://data.medicare.gov/data/hospital-compare)

Process of Care and HCAHPS from 2015Q1-2015Q4. Some process of care shorter window in 2015

Mortality &amp; Readmission 2012Q3-2015Q2 (except hospital wide)

## 2016 Data

Pulled October 2017 archive from [https://data.medicare.gov/data/archives/hospital-compare](https://data.medicare.gov/data/archives/hospital-compare)

Process of Care and HCAHPS from 2016Q1-2016Q4

Mortality &amp; Readmission 2013Q3-2016Q2 (except hospital wide)

Extract code:

`perl -e '@t = qw( Measure_Dates HQI_FTNT HQI_HOSP_STRUCTURAL HQI_HOSP_HCAHPS HQI_HOSP_TimelyEffectiveCare HQI_HOSP_Comp HQI_HOSP_HAI  HQI_HOSP_ReadmDeath HQI_HOSP_IMG_AVG HQI_HOSP_PaymentAndValueOfCare HQI_HOSP_MSPB HQI_OP_Procedure_Volume); foreach $t (@t) { print("mdb-export Hospital.mdb $t > $t.csv\n"); system("mdb-export Hospital.mdb $t > $t.csv"); }'`
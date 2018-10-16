* process the mortality and readmission measures, HCAHPS surveys, and process of care
* measures from hospital compare

capture log close
log using process.log, replace

set more off

clear all

**** source of hospital compare data ***

* the data files are available here:
* http://sacarny.com/data/

* each year's files assumed to sit in the following folder:
* $HCBASE/hospital`year'/

* base directory where hospital compare data stored
global HCBASE "source/"

* mortality & readmission data spans 2007-2016
global MRSTARTYEAR = 2007
global MRENDYEAR = 2016

* hcahpcs data spans 2007-2016
global HCSTARTYEAR = 2007
global HCENDYEAR = 2016

* process of care data spans 2004-2016
global POCSTARTYEAR = 2004
global POCENDYEAR = 2016

* process of care measures that are in minutes, not shares of patients
global MINUTEMEAS "ed1 ed2 op1 op3 op5 op18 op20 op21"

* make the output folder if it doesn't exist
capture mkdir output

*** MORTALITY AND READMISSION ***

forvalues year = $MRSTARTYEAR/$MRENDYEAR {
	
	* before 2016, mortality and readmission in one file
	if (`year' < 2016) {
		if (`year'==2007) {
			local fname "HOSP_MORTALITY_XWLK"
		}
		else if (`year' <= 2012) {
			local fname "HOSP_MORTALITY_READM_XWLK"
		}
		else if (`year' == 2013) {
			local fname "HOSP_ReadmCompDeath"
		}
		else if (`year' == 2014) {
			local fname "HQI_HOSP_READMDEATH"
		}
		else if (`year' == 2015) {
			local fname "HQI_HOSP_ReadmDeath"
		}
	
		import delimited using $HCBASE/hospital`year'/`fname'.csv, varnames(1)
	}
	else {
		* starting in 2016, mortality and readmission stored in separate files
		
		* load mortality
		tempfile mortality
		import delimited ///
			using "$HCBASE/hospital`year'/Complications and Deaths - Hospital.csv", ///
			varnames(1)
		save `mortality'
		
		* load readmission
		import delimited ///
			using "$HCBASE/hospital`year'/Hospital Returns - Hospital.csv", ///
			varnames(1) clear
		
		* bring together
		append using `mortality'
	}
	
	drop hospitalname

	rename provider* pn
	tostring pn, replace format(%06.0f)
	if (`year'>=2009) {
		replace pn = subinstr(pn,"'","",.)
	}

	if (`year' < 2013) {
		replace condition = "hf" if condition=="Heart Failure"
		replace condition = "ami" if condition=="Heart Attack"
		replace condition = "pn" if condition=="Pneumonia"
		replace condition = "hk" if condition=="Hip/Knee"
		replace condition = "all" if condition=="Hospital-Wide All-Cause"

		gen meas = "mort" if regexm(measurename,"Mortality")
		replace meas = "readm" if regexm(measurename,"[Rr]eadmission")
		replace meas = "compl" if regexm(measurename,"[Cc]omplication")
		* in 2012 some of the measures are blank for everything except the rate
		* and then it looks like THA/THK RSCR has just a blank rate...
		replace meas = "blank" if measurename==""
				
		rename numberofpatients npatients
	}
	else {
		
		* in some years (2013, 2016, others?) the files include PSI measures,
		* which we don't want. they also make the regular expressions fail.
		* let's remove them now
		drop if regexm(measureid,"^PSI_")
		
		
		gen condition = regexs(3) if regexm(measureid,"^([^_]+)_([^_]+)_([^_]+|HIP_KNEE)$")
		replace condition = "HIP_KNEE" if measureid=="COMP_HIP_KNEE"
		replace condition = "ALL" if measureid=="READM_30_HOSP_WIDE"
		
		gen meas = regexs(1) if regexm(measureid,"^([^_]+)_([^_]+)_([^_]+|HIP_KNEE)$")
		replace meas = "COMPL" if measureid=="COMP_HIP_KNEE"
		replace meas = "READM" if measureid=="READM_30_HOSP_WIDE"
		
		assert !missing(meas) & !missing(condition)

		replace condition = strlower(condition)
		replace condition = "hk" if condition=="hip_knee"
		
		replace meas = strlower(meas)
		
		rename denominator npatients
	}
	
	*** IGNORE COMPLICATION RATE & EDAC FOR NOW ***
	drop if inlist(meas,"compl","blank","edac")
	assert inlist(meas,"mort","readm")
	
	replace meas = condition + "_" + meas
	drop condition
	
	if (`year'==2007) {
		rename mortalityrate rate
	}
	else if (`year' <= 2011) {
		rename mortality_readmrate rate
	}
	else if (`year'==2012) {
		rename mortality_readm_compl_rate rate
	}
	else {
		rename score rate
	}
	

	if (`year'>=2009) {
		replace rate = "" if inlist(rate,"Not Available","N/A")
		replace npatients = "" if inlist(npatients,"Not Available","N/A")
		destring rate npatients, replace
	}

	replace rate = rate/100

	keep pn meas rate npatients

	replace meas = meas + "_"
	
	reshape wide @rate @npatients, i(pn) j(meas) string

	gen year = `year'
	compress

	order pn year
	sort pn year
	save output/mortreadm`year'.dta, replace
	clear

}

forvalues year = $MRSTARTYEAR/$MRENDYEAR {
	if (_N==0) {
		use output/mortreadm`year'.dta
	}
	else {
		append using output/mortreadm`year'.dta
	}
	
	rm output/mortreadm`year'.dta
}

order pn year
sort pn year

label data "cms hospital compare mortality and readmission measures"
label var pn "medicare provider number"
label var year "rates for patients from (year-3)Q3 to yearQ2 [2007=2006Q3 to 2007Q2]"

foreach cond in ami hf pn copd stk cabg hk {
	local condupper = upper("`cond'")
	
	if ("`cond'"!="hk") {
		label var `cond'_mort_rate "`condupper' adjusted 30 day mortality rate"
		label var `cond'_mort_npatients "count of `condupper' patients used to calculate mortality rate"
	}

	label var `cond'_readm_rate "`condupper' adjusted 30 day readmission rate"
	label var `cond'_readm_npatients "count of `condupper' patients used to calculate readmission rate"	
}

	label var all_readm_rate "all-patient adjusted 30 day readmission rate NOTE: covers (year-1)Q3 to yearQ2"
	label var all_readm_npatients "count of patients used to calculate all-patient readmission rate"	


compress
save output/mortreadm.dta, replace
saveold output/mortreadm.v12.dta, replace version(11)
export delimited output/mortreadm.csv, replace

log close

quietly {
    log using output/mortreadm_codebook.txt, text replace
    noisily describe, fullnames
    log close
}

log using process.log, append

clear


*** HCAHPS ***

tempfile hcahps_xwlk
import delimited using misc/hcahps_xwlk.csv
save `hcahps_xwlk'
clear

forvalues year=$HCSTARTYEAR/$HCENDYEAR {

	if (`year' <= 2012) {
		local fname "HOSP_HCAHPS_MSR"
	}
	else if (`year' == 2013) {
		local fname "HOSP_HCAHPS"
	}
	else if (`year' == 2014 | `year' == 2015) {
		local fname "HQI_HOSP_HCAHPS"
	}
	else {
		local fname "HCAHPS - Hospital"
	}

	import delimited using "$HCBASE/hospital`year'/`fname'.csv", varnames(1)
	
	drop hospitalname
	
	if (`year' <= 2007) {
		rename providernumber pn
	}
	else if (`year'>2007 & `year'<=2012) {
		rename providernumber pn
		rename hcahpsmeasurecode measurecode
	}
	else {
		rename providerid pn
		rename hcahpsmeasureid measurecode
	}
	
	tostring pn, replace format(%06.0f)
	
	rename hcahpsquestion question
	rename hcahpsanswerdescription answerdescription
	rename hcahpsanswerpercent percent
	rename numberofcompletedsurveys nsurveys
	rename surveyresponseratepercent rrate

	replace question = subinstr(question,"&#39;","'",.)
	
	* REMOVING LINEAR SCORE AND STAR RATING FROM 2014 ONWARD *
	if (`year'>=2014) {
		drop if regexm(measurecode,"(LINEAR_SCORE|STAR_RATING)$")
	}

	if (`year' <= 2007) {
		merge m:1 question answerdescription using `hcahps_xwlk', ///
			keep(match) assert(match using) nogenerate keepusing(meas value)
	}
	else {
		merge m:1 measurecode using `hcahps_xwlk', ///
			keep(match) assert(match using) nogenerate keepusing(meas value)
	
		replace percent = "" if percent=="Not Available" | percent=="N/A"
	}
	
	if (`year'>=2009) {
		replace rrate = "" if rrate=="Not Available" | rrate=="N/A"
		replace pn = subinstr(pn,"'","",.)
	}

	destring percent rrate, replace

	keep pn meas value percent nsurveys rrate

	rename percent share
	replace share = share/100
	replace rrate = rrate/100
	
	* 2014 gives exact number of nsurveys
	if (`year'<2014) {
		replace nsurveys = "" if nsurveys=="N/A" | nsurveys=="Not Available"
		replace nsurveys = "1" if nsurveys=="Fewer than 100"
		replace nsurveys = "2" if nsurveys=="Between 100 and 299"
		replace nsurveys = "3" if nsurveys=="300 or More" | nsurveys=="300 or more"
	}
	else {
		rename nsurveys nsurveys_exact
		
		gen nsurveys = "" if nsurveys_exact=="Not Available"
		replace nsurveys = "1" if nsurveys_exact=="FEWER THAN 50"
		
		destring nsurveys_exact, force replace
		replace nsurveys = "1" if nsurveys_exact!=. & nsurveys_exact<100
		replace nsurveys = "2" if nsurveys_exact!=. & nsurveys_exact>=100 & nsurveys_exact<300 
		replace nsurveys = "3" if nsurveys_exact!=. & nsurveys_exact>=300 		
	}

	destring nsurveys, replace

	label define surv 1 "Fewer than 100" 2 "Between 100 and 299" 3 "300 or more"
	label values nsurveys surv

	gen score = value*share
	gen missing = score==.
	
	* missing should be constant within pn-measure
	egen meanmissing = mean(missing), by(pn meas)
	assert missing==meanmissing
	drop meanmissing
	
	* share of responses taking on each value
	// preserve
	// keep pn meas value share
	// 
	// rename share share_value_
	// 
	// reshape wide share_value_, i(pn meas) j(value)
	// tempfile fracvalues
	// save `fracvalues'
	// restore
		
	collapse (sum) score (mean) missing, by(pn nsurveys* rrate meas)
	isid pn meas
	
	* bring in share of responses taking on each value
	// merge 1:1 pn meas using `fracvalues', assert(match) nogenerate

	replace score = . if missing!=0
	drop missing
	isid pn meas

	replace meas = meas + "_"
	
	reshape wide @score, i(pn) j(meas) string
	
	gen year = `year'
	compress

	order pn year
	order nsurveys*, last
	sort pn year
	save output/hcahps`year'.dta, replace
	clear
	
}

forvalues year = $HCSTARTYEAR/$HCENDYEAR {
	if (_N==0) {
		use output/hcahps`year'.dta
	}
	else {
		append using output/hcahps`year'.dta
	}
	
	rm output/hcahps`year'.dta
}

order pn year
sort pn year

label data "cms hospital compare HCAHPS survey"
label var pn "medicare provider number"
label var year "scores calculated on data from yearQ1 thru yearQ4"

label var clean_score "Rooms Kept Clean (1-3)"
label var commdoc_score "Doctor Communication (1-3)"
label var commnurse_score "Nurse Communication (1-3)"
label var explain_score "Explained Medicines (1-3)"
label var help_score "Staff Helpful (1-3)"
label var info_score "Given Recovery Info (0/1)"
label var overall_score "Overall (1-3)"
label var pain_score "Pain Well Controlled (1-3)"
label var quiet_score "Rooms Quiet at Night (1-3)"
label var recommend_score "Would Recommend to Others (1-3)"
label var understood_score "Patients Understood Care (1-3)"

compress
save output/hcahps.dta, replace
saveold output/hcahps.v12.dta, replace version(11)
export delimited output/hcahps.csv, replace

log close

quietly {
    log using output/hcahps_codebook.txt, text replace
    noisily describe, fullnames
    noisily label dir
    log close
}
copy misc/hcahps_xwlk_codebook.csv output/hcahps_xwlk.csv, replace

log using process.log, append
clear


*** PROCESS OF CARE MEASURES ***

* make the list of minute measures that we can pass as arguments to inlist
local minutemeas_args ""
foreach meas in $MINUTEMEAS {
	if (`"`minutemeas_args'"'=="") { // "
		local minutemeas_args `""`meas'""'
	}
	else {
		local minutemeas_args `"`minutemeas_args',"`meas'""' // "
	}
}

tempfile poc_xwlk

import delimited using misc/poc_xwlk.csv, varnames(1)
save `poc_xwlk', replace
clear

forvalues year = $POCSTARTYEAR/$POCENDYEAR {

	if (`year' <= 2012) {
		local fname = "HOSP_MSR_XWLK"
	}
	else if (`year' == 2013) {
		local fname = "HOSP_TimelyEffectiveCare"
	}
	else if (`year' == 2014) {
		local fname = "HQI_HOSP_TIMELYEFFECTIVECARE"
	}
	else if (`year' == 2015) {
		local fname = "HQI_HOSP_TimelyEffectiveCare"
	}
	else {
		local fname = "Timely and Effective Care - Hospital"
	}

	import delimited using "$HCBASE/hospital`year'/`fname'.csv", varnames(1)

	drop hospitalname
	
	if (`year'<=2012) {
		rename providernumber pn
	}
	else {
		rename providerid pn
	}
	
	tostring pn, replace format(%06.0f)
	
	replace sample = regexr(sample," patients","")
	destring sample, force replace
	rename sample denom
	
	if (`year'>=2013) {
		rename measureid measurecode
	}

	if (`year' < 2008) {
		replace measurename = regexr(measurename,"^(Heart Attack|Heart Failure|Pneumonia|Surgery) ","")
		merge m:1 condition measurename using `poc_xwlk', ///
			nogenerate keep(match) assert(match using)
	}
	else {
		replace measurecode = lower(measurecode)

		if (`year'==2008) {
			replace measurecode = regexr(measurecode," +$","")
			replace measurecode = subinstr(measurecode,"-","",.)
		}
		else {
			replace measurecode = subinstr(measurecode,"_","",.)
		}
		
		replace measurecode = regexr(measurecode,"[abc]$","")
	}
	
	replace score = regexr(score,"%","")
	
	* make EDV, which equals: Low, Medium, High, Very High, numeric
	* it will get divided by 100 later, so everything is in 100s now
	replace score = "100" if regexm(score,"^Low") & measurecode=="edv"
	replace score = "200" if regexm(score,"^Medium") & measurecode=="edv"
	replace score = "300" if regexm(score,"^High") & measurecode=="edv"
	replace score = "400" if regexm(score,"^Very High") & measurecode=="edv"
	
	destring score, force replace
	
	* make scores into shares, not percentage points, unless the measure is measured in
	* minutes
	replace score = score/100 if !inlist(measurecode,`minutemeas_args')
	rename score share

	if (`year'>=2009) {
		replace pn = subinstr(pn,"'","",.)
	}
	
	keep pn measurecode share denom
	
	tostring pn, replace format(%06.0f)

	* fix name for imm-3 measure
	replace measurecode="imm3" if inlist(measurecode,"imm3facadhpct","imm3op27facadhpct")

	replace measurecode = measurecode + "_"

	reshape wide @share @denom, i(pn) j(measurecode) string
	
	gen year = `year'
	
	compress
	save output/poc`year'.dta, replace
	clear
}


forvalues year = $POCSTARTYEAR/$POCENDYEAR {
	if (_N==0) {
		use output/poc`year'.dta
	}
	else {
		append using output/poc`year'.dta
	}
	
	rm output/poc`year'.dta
}

order pn year ami* hf* pn* scipinf* scipvte* scipcard* cac* ed* imm* op* pc* stk* vte*

sort pn year

label data "cms hospital compare process of care measures"
label var pn "medicare provider number"
label var year "scores calculated on data from yearQ1 thru yearQ4"

foreach pfx in share denom {
	if ("`pfx'"=="share") {
		local txt "(Share)"
	}
	else {
		local txt "(Denominator)"
	}

	
	label var ami1_`pfx' "Aspirin at Arrival `txt'"
	label var ami2_`pfx' "Aspirin at Discharge `txt'"
	label var ami3_`pfx' "ACE Inhibitor for LVSD `txt'"
	label var ami4_`pfx' "Smoking Cessation Advice `txt'"
	label var ami5_`pfx' "Beta Blocker at Discharge `txt'"
	label var ami6_`pfx' "Beta Blocker at Arrival `txt'"
	label var ami7_`pfx' "Thrombolytics/fibrinolytics at Arrival `txt'"
	label var ami8_`pfx' "PCI at Arrival `txt'"
	label var ami10_`pfx' "Statin Rx at Discharge `txt'"

	label var hf1_`pfx' "Discharge Instructions `txt'"
	label var hf2_`pfx' "LVS Function Eval `txt'"
	label var hf3_`pfx' "ACE Inhibitor/ARB for LVSD `txt'"
	label var hf4_`pfx' "Smoking Cessation Advice `txt'"

	label var pn1_`pfx' "Oxygenation Assessment `txt'"
	label var pn2_`pfx' "Given Pneumococcal Vaccine `txt'"
	label var pn3_`pfx' "Blood Culture before Antibiotics `txt'"
	label var pn4_`pfx' "Smoking Cessation Advice `txt'"
	label var pn5_`pfx' "Timely Antibiotics `txt'"
	label var pn6_`pfx' "Given Most Appropriate Antibiotic `txt'"
	label var pn7_`pfx' "Given Influenza Vaccine `txt'"

	label var scipinf1_`pfx' "Preventative Antibiotics `txt'"
	label var scipinf2_`pfx' "Appropriate Antibiotic `txt'"
	label var scipinf3_`pfx' "Antibiotics Stopped Quickly `txt'"
	label var scipinf4_`pfx' "Blood Glucose Controlled `txt'"
	label var scipinf6_`pfx' "Appropriate Hair Removal `txt'"
	label var scipinf9_`pfx' "Urinary Cath Removed Quickly `txt'"
	label var scipinf10_`pfx' "Body Temperature Management `txt'"
	label var scipvte1_`pfx' "Doc Ordered Clot-Prevention `txt'"
	label var scipvte2_`pfx' "Pat Received Clot-Prevention `txt'"

	label var scipcard2_`pfx' "Pat Kept on Beta Blocker `txt'"

	label var cac1_`pfx' "Received Reliever Medicine `txt'"
	label var cac2_`pfx' "Received Systemic Corticosteroids `txt'"
	label var cac3_`pfx' "Received Home Management Plan `txt'"
	
	label var ed1_`pfx' "Time from arrival to departure `txt'"
	label var ed2_`pfx' "Time from admit decision to departure `txt'"
	
	label var imm2_`pfx' "Immunization for influenza `txt'"
	label var imm3_`pfx' "Healthcare workers immunized for influenza `txt'"
	
	label var op1_`pfx' "Median time to Fibrinolysis `txt'"
	label var op2_`pfx' "Timely anti-clotting drugs `txt'"
	label var op3_`pfx' "Avg minutes to transfer `txt'"
	label var op4_`pfx' "Timely receipt of aspirin `txt'"
	label var op5_`pfx' "Avg time until perform ECG `txt'"
	label var op6_`pfx' "Antibiotic administered promptly `txt'"
	label var op7_`pfx' "Correct antibiotic administered `txt'"

	label var op18_`pfx' "Median time arrival to departure for ED disch `txt'"
	label var op20_`pfx' "Median time door to diagnostic `txt'"
	label var op21_`pfx' "Median time to pain mgmt for long bone fractures `txt'"
	label var op22_`pfx' "Patients left without being seen `txt'"
	label var op23_`pfx' "Timely scan results for stroke `txt'"
	
	label var op29_`pfx' "Approp colonoscopy follow-up for avg risk `txt'"
	label var op30_`pfx' "Approp colonoscopy follow-up for med risk `txt'"
	label var op31_`pfx' "Improvement in vision after cataract surg `txt'"

	label var pc01_`pfx' "Elective delivery before recommended `txt'"

	label var stk1_`pfx' "Venous Thromboembolism (VTE) Prophylaxis `txt'"
	label var stk2_`pfx' "Discharged on Antithrombotic Therapy `txt'"
	label var stk3_`pfx' "Anticoagulation Therapy for Atrial Fibrillation/Flutter `txt'"
	label var stk4_`pfx' "Thrombolytic Therapy `txt'"
	label var stk5_`pfx' "Antithrombotic Therapy By End of Hospital Day 2 `txt'"
	label var stk6_`pfx' "Discharged on Statin Medication `txt'"
	label var stk8_`pfx' "Stroke Education `txt'"
	label var stk10_`pfx' "Assessed for Rehabilitation `txt'"

	label var vte1_`pfx' "VTE Prophylaxis `txt'"
	label var vte2_`pfx' "ICU VTE Prophylaxis `txt'"
	label var vte3_`pfx' "VTE Patients with Anticoagulation Overlap Therapy `txt'"
	label var vte4_`pfx' "VTE Patients UFH Therapy by Protocol `txt'"
	label var vte5_`pfx' "VTE Warfarin Therapy Discharge Instructions `txt'"
	label var vte6_`pfx' "Hospital Acquired Potentially-Preventable VTE `txt'"

}

* rename minute measures to be _minutes and fix their variable labels
foreach meas in $MINUTEMEAS {
	rename `meas'_share `meas'_minutes
	local vlabel: variable label `meas'_minutes
	
	local vlabel = regexr("`vlabel'","Share","Minutes")
	label variable `meas'_minutes "`vlabel'"
}

* fix ED volume measure to be _scale
rename edv_share edv_scale
label var edv_scale "Emergency dept volume (1-4 Scale: Lo/Med/High/V High)"
label var edv_denom "Emergency dept volume (Denominator)"

compress
save output/poc.dta, replace
saveold output/poc.v12.dta, replace version(11)
export delimited output/poc.csv, replace

copy misc/poc_xwlk.csv output/poc_xwlk.csv, replace

log close

quietly {
    log using output/poc_codebook.txt, text replace
    noisily describe, fullnames
    log close
}

log using process.log, append

log close

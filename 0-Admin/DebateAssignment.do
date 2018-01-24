/* This Do File Randomly assigns students to be either for or against in our
  debate.
  
  It takes as an input, the file called download.tsv which is downloaded from 
  SSOL and contains all the students registered for the class (on 1/15)
  
  It produces as an output a file called "DebateAssignment.dta" containing the 
  assignments.
  
*/

import excel using "/Users/michael//Documents/GitHub/GR6307---Public-Economics-and-Development/0-Admin/DebateParticipants.xlsx", firstrow allstring clear
set more off
set seed 20180124
replace Name = strtrim(stritrim(Name))
isid Name //double-check there aren't 2 people with the same name
count if SpeakSpanish == ""
assert `r(N)' == 0 //double-check we know spanish status of everyone

gen rvar1 = runiform() //random, uniform variable to use to sort people randomly
gen rvar2 = runiform()

sort SpeakSpanish rvar1
count if SpeakSpanish == "No"
local NoSpan = `r(N)' //the number of people who don't speak spanish
count if SpeakSpanish == "Yes"
local YesSpan = `r(N)' //the number of people who do speak spanish
if mod(`NoSpan',2)==1 & mod(`YesSpan',2)==1 { //if there are an odd number of both types
  local lastForNoSpan = floor(`NoSpan'/2) //last "For" non-spanish speaker
  local firstAgainstNoSpan = `lastForNoSpan' + 1 //first "Against" non-spanish speaker
  local lastAgainstNoSpan = floor(`NoSpan'/2)*2 //last "Against" non-spanish speaker
  local firstYesSpan = `NoSpan' + 1 //first Spanish speaker
  local lastForYesSpan = `NoSpan' + floor(`YesSpan'/2) //last "For" Spanish speaker
  local firstAgainstYesSpan = `lastForYesSpan' + 1 //first "Against" Spanish speaker
  local lastAgainstYesSpan = `NoSpan' + (floor(`YesSpan'/2)*2) //last "Against" Spanish speaker
  qui gen Team = "For" in 1/`lastForNoSpan'
  qui replace Team = "Against" in `firstAgainstNoSpan'/`lastAgainstNoSpan'
  qui replace Team = "For" in `firstYesSpan'/`lastForYesSpan'
  qui replace Team = "Against" in `firstAgainstYesSpan'/`lastAgainstYesSpan'
  count if Team == ""
  assert `r(N)' == 2
  summ rvar2 if Team == "", meanonly
  qui replace Team = "For" if Team == "" & rvar2 < `r(mean)'
  qui replace Team = "Against" if Team == "" & rvar2 > `r(mean)'
  tab Team SpeakSpanish
}
if mod(`NoSpan',2)==0 | mod(`YesSpan',2)==0 { //if there is an even number of either type
  local breakNoSpan = round(`NoSpan'/2) //last "For" non-spanish speaker
  local firstYesSpan = `NoSpan' + 1 //first Spanish speaker
  local breakYesSpan = round(`NoSpan' + (`YesSpan'/2)) //last "For Spanish speaker
  qui gen Team = "For" in 1/`breakNoSpan'
  qui replace Team = "For" in `firstYesSpan'/`breakYesSpan'
  qui replace Team = "Against" if Team == ""
  tab Team SpeakSpanish
}

save "/Users/michael/Documents/GitHub/GR6307---Public-Economics-and-Development/0-Admin/DebateAssignments.dta", replace

sort Team SpeakSpanish
list Name email Team

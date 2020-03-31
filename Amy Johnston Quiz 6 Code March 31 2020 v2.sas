/*QUIZ 6 CODE
  SUBMITTED BY: AMY JOHNSTON
  MARCH 31, 2020*/

/*QUESTION 1A: How many patients had at least 1 inpatient encounter that started in 2003?*/

*Making sure I identify the variables required in my dataset;
proc contents data=epidat.nencounter varnum;
	run;
dm 'odsresults; clear'; *Clearing the output window;

*BELOW, creating a copy of my dataset in the work library;
DATA QUIZ6;
	SET EPIDAT.NENCOUNTER;
	RUN;

*We want to identify inpatient encounters that started in 2003, so I'm limiting the year to 2003;
*Keeping the 4 variables that I'll need;
DATA QUIZ6;
	SET QUIZ6; 
	KEEP EncStartDtm EncVisitTypeCd EncPatWID EncWID; 
		IF year(datepart(EncStartDtm))=2003;
	RUN;
*Right now, there are 3327 observations representing encounters limited to those starting in 2003;
*Below, I am trying to identify and remove any duplicate ENCOUNTERS that might be in the dataset (EncWID);
*The instructions say that these are UNIQUE, so if there are any duplicates, I need to remove them;

PROC SORT DATA=QUIZ6 OUT=TEST NODUPKEY;
	 BY EncWID;
	RUN;
*According to the log, 0 observations with duplicate key values were deleted so we're good to go;

*Now just sorting my QUIZ6 dataset by patientID;
PROC SORT DATA=QUIZ6
	OUT=ENCOUNTER; 
		BY EncPatWID;
	RUN;
*Here, we can see that there are multiple patient identifiers per line, so I have to flatfile;

*Coding my counter: Doing INPT separately;
DATA INPT;
	SET ENCOUNTER;
	BY EncPatWID;
		IF first.EncPatWID=1 THEN DO;
		VISIT=0;COUNT=0;
	END;
		IF EncVisitTypeCd in:('INPT') THEN DO; 
		VISIT=1;COUNT=COUNT+1;END;
		IF last.EncPatWID=1 then output;
	RETAIN VISIT COUNT;
	RUN;

PROC FREQ DATA=INPT;
	TABLES VISIT COUNT;
	RUN;
*According to this frequency table, 1074 patients had at least 1 inpatient encounter that started in 2003;

/*QUESTION 1B: How many patients had at least 1 emergency room encounter that started in 2003? */

*Coding my counter: Doing EMERG separately;
DATA EMERG;
	SET ENCOUNTER;
	BY EncPatWID ;
		IF first.EncPatWID=1 THEN DO;
		VISIT=0;COUNT=0;
	END;
		IF EncVisitTypeCd in:('EMERG') THEN DO; 
		VISIT=1;COUNT=COUNT+1;END;
		IF last.EncPatWID=1 then output;
	RETAIN VISIT COUNT;
	RUN;

PROC FREQ DATA=EMERG;
	TABLES VISIT COUNT;
	RUN;
*1978 patients had at least 1 emergency room encounter that started in 2003;

/*QUESTION 1C AND 1D- Combined: How many patients had at least 1 visit of either type (inpatient or emergency room encounter)
 that started in 2003? 1D: In patients from c) who had at least 1 visit of either type, I created a variable that counts 
 the total number encounters (of either type) using the code below*/

*Sorting by EncPatWID before I set up my counter, that was used to address both questions;
DATA INPEMERG;
	SET ENCOUNTER;
	BY EncPatWID;
		IF first.EncPatWID=1 THEN DO;
		VISIT=0;COUNT=0;
	END;
		IF EncVisitTypeCd in:('EMERG' 'INPT') THEN DO; 
		VISIT=1;COUNT=COUNT+1;END;
		IF last.EncPatWID=1 then output;
	RETAIN VISIT COUNT;
	RUN;

PROC FREQ DATA=INPEMERG;
	TABLES VISIT COUNT;
	RUN;
*2891 Participants had at least 1 visit of either type that started in 2003 (100% of the people in this dataset);

/*QUESTION 2: I generated a frequency table of total encounter number for this data set, and pasted the table 
into my code, below, using the formchar options to make it text-friendly*/

ODS LISTING;
options formchar="|----|+|---+=|-/\<>*";
PROC FREQ DATA=INPEMERG;
	TABLES VISIT COUNT;
	RUN;
*Note that the sum of all the counts*frequencies = 3327, which is what we would expect because this is the 
total number of unique patient numbers in the datafile after limiting to encounters that started in 2003;
*2556+(2*270)+(3*45)+(4*14)+(5*3)+6+7+12 = 3327;

 /*                  
                                                      Cumulative    Cumulative
                    COUNT    Frequency     Percent     Frequency      Percent
                    ----------------------------------------------------------
                        1        2556       88.41          2556        88.41
                        2         270        9.34          2826        97.75
                        3          45        1.56          2871        99.31
                        4          14        0.48          2885        99.79
                        5           3        0.10          2888        99.90
                        6           1        0.03          2889        99.93
                        7           1        0.03          2890        99.97
                       12           1        0.03          2891       100.00

*/






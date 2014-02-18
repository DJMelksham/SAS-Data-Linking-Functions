PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;

/***********************************************************************************************************

PROGRAM NAME: 	New York State Identification and Intelligence System Algorithm
------------------------------------------------------------------------------------------------------------
AUTHOR: 		ORIGINAL: Robert L. Taft | SAS ADAPTION: Damien John Melksham
------------------------------------------------------------------------------------------------------------
DATE CREATED: 	3rd June, 2012
------------------------------------------------------------------------------------------------------------
PURPOSE:		A phonetic algorithm developed for approximate matching between surnames.
		
				This version was based on the original code found here:
				http://www.dropby.com/nysiisOriginal.js

************************************************************************************************************
COMMENTARY: 	

There's probably a few opportunities for efficiency gains left.  But I have been more 
interested in trying to replicate the form and operation of the original code
rather than change it to be incomprehensible, or indeed, to develop a better algorithm
which happens in my other projects.

Having said that, I have made one or two adjustments that make it more SAS relevent.
I return a value of missing if the original input is missing (rather than partaking in
the computational joys of the rest of the function).

Why one would check for digits and return a string which terminates the function, but then have later
a check to remove non-alpha characters and allow the function to run sucessfully is beyond me,
so I have removed the checks for digits, and maintained the stripping of non alpha characters
which should take care of the digits anyway.

The original code returned a message of "no numerics allowed!" which although a friendly message,
isn't what I would necessarily want when operating on a big project of name matching in SAS,
or when partaking in record linkage.

I'm also removing the check for the presence of the name suffixes JR(junior) and
SR(senior), because they seem relatively arbitrary to me, and they may give one the impression 
proper cleaning has taken place when a search for those two strings is likely to do "sweet F all" in
the grand scheme of all possible suffix repairs.

I ran basic checks using names from the test URL (available at the time of authorship)
at http://www.dropby.com/NYSIISTextStrings.html
and the codes have been returning properly.

************************************************************************************************************/

FUNCTION NYSIIS(string_1 $) $ 6;

/* Step 1: Convert string to Uppercase letters, and remove whitespace */
length lengthvar 8 NYSIIS $6 firstchar $1;
workstring = UPCASE(TRIM(LEFT(string_1)));

/* Remove non-alpha characters */

workstring = PRXCHANGE('s/[^A-Z]//o',-1,workstring);

/* Beginning the "real algorithm" */
/* 
	Transcode first characters of name:
	MAC -> MCC
	KN -> NN
	K -> C
	PH, PF -> FF
	SCH -> SSS
*/

IF PRXMATCH('/^MAC/o',workstring)>0 THEN
workstring=	PRXCHANGE('s/^MAC/MCC/o',-1,workstring);
ELSE 
IF PRXMATCH('/^KN/o',workstring)>0 THEN
workstring=	PRXCHANGE('s/^KN/NN/o',-1,workstring);
ELSE 
IF PRXMATCH('/^K/o',workstring)>0 THEN
workstring=	PRXCHANGE('s/^K/C/o',-1,workstring);
ELSE
IF PRXMATCH('/^PH/o',workstring)>0 THEN
workstring=	PRXCHANGE('s/^PH|^PF/FF/o',-1,workstring);
ELSE
IF PRXMATCH('/^SCH/o',workstring)>0 THEN
workstring=	PRXCHANGE('s/^SCH/SSS/o',-1,workstring);

/* Transcode two-character suffix as follows,
EE, IE -> Y
DT, RT, RD, NT, ND -> D
*/
	IF PRXMATCH('/EE$|IE$/o',trim(workstring)) THEN
		workstring = PRXCHANGE('s/EE$|IE$/Y/o',-1,trim(workstring));
	else IF PRXMATCH('/DT$|RT$|RD$|NT$|ND$/o',trim(workstring)) THEN
		workstring = PRXCHANGE('s/DT$|RT$|RD$|NT$|ND$/D/o',-1,trim(workstring));
	

/* Save first char for later, to be used as first char of key */

	firstChar = substr(workstring,1,1);
IF length(workstring)=1 THEN workstring='';
ELSE workstring=substr(workstring,2);


/* Translate remaining characters by following these rules sequentially.  Some other comments
have been along the lines of "incrementing one character at a time", but this description is
ambiguous at best, and misleading at worst.  

The code from the original via which I have translated this version implimented the code below:
		EV	->	AF 	else A,E,I,O,U	->	A 	*/                                 
	
	workstring = PRXCHANGE('s/EV/AF/o',-1,workstring);
	workstring = PRXCHANGE('s/[AEIOU]+/A/o',-1,workstring);
	/*	Q	->	G */	  	  	  	  	 
	workstring = PRXCHANGE('s/Q/G/o',-1,workstring);
	/*	Z	->	S */	  	  	  	  	 
	workstring = PRXCHANGE('s/Z/S/o',-1,workstring);
	/*	M	->	N */	  	  	  	  	 
	workstring = PRXCHANGE('s/M/N/o',-1,workstring);
	/*	KN	->	N, else K	->	C */ 	 
	workstring = PRXCHANGE('s/KN/N/o',-1,workstring);
	workstring = PRXCHANGE('s/K/C/o',-1,workstring);
	/*	SCH	->	SSS */ 	  	  	  	  	 
	workstring = PRXCHANGE('s/SCH/SSS/o',-1,workstring);
	/*	PH	->	FF 	*/  	  	  	  	 
	workstring = PRXCHANGE('s/PH/FF/o',-1,workstring);
	/* H -> If previous or next is nonvowel, previous */
	workstring = PRXCHANGE('s/([^AEIOU])H/$1/o',-1,workstring);
	workstring = PRXCHANGE('s/(.)H[^AEIOU]/$1/o',-1,workstring);
	/* W ->	If previous is vowel, then A */
	workstring = PRXCHANGE('s/[AEIOU]W/A/o',-1,workstring);
	
	/* If last character is S, remove it */
	workstring = PRXCHANGE('s/S$//o',-1,trim(workstring));

	/* If last characters are AY, replace with Y */
	workstring = PRXCHANGE('s/AY$/Y/o',-1,trim(workstring));


	/* If last character is A, remove it */
	workstring = PRXCHANGE('s/A$//o',-1,trim(workstring));

	/* Collapse all strings of repeated characters
	 Except for vowels which become A.  The comments say vowels, but the earlier code
	 changed all the vowels to A.  You could make things more efficient here by
	 dropping checks for the other vowel characters, and you could also do this
	 by dropping the same checks for the vowel characters up above in the code as well.

	 But I'm just going to keep things as they are, as it will work fine as it is,
	 it will be more comparable with code from the past, and efficiency is not the 
	 main concern with this algorithm. */

	workstring = PRXCHANGE('s/[AEIOU]+/A/o',-1,workstring);
	workstring = PRXCHANGE('s/B+/B/o',-1,workstring);
	workstring = PRXCHANGE('s/C+/C/o',-1,workstring);
	workstring = PRXCHANGE('s/D+/D/o',-1,workstring);
	workstring = PRXCHANGE('s/F+/F/o',-1,workstring);
	workstring = PRXCHANGE('s/G+/G/o',-1,workstring);
	workstring = PRXCHANGE('s/H+/H/o',-1,workstring);
	workstring = PRXCHANGE('s/J+/J/o',-1,workstring);
	workstring = PRXCHANGE('s/K+/K/o',-1,workstring);
	workstring = PRXCHANGE('s/L+/L/o',-1,workstring);
	workstring = PRXCHANGE('s/M+/M/o',-1,workstring);
	workstring = PRXCHANGE('s/N+/N/o',-1,workstring);
	workstring = PRXCHANGE('s/P+/P/o',-1,workstring);
	workstring = PRXCHANGE('s/Q+/Q/o',-1,workstring);
	workstring = PRXCHANGE('s/R+/R/o',-1,workstring);
	workstring = PRXCHANGE('s/S+/S/o',-1,workstring);
	workstring = PRXCHANGE('s/T+/T/o',-1,workstring);
	workstring = PRXCHANGE('s/V+/V/o',-1,workstring);
	workstring = PRXCHANGE('s/W+/W/o',-1,workstring);
	workstring = PRXCHANGE('s/X+/X/o',-1,workstring);
	workstring = PRXCHANGE('s/Y+/Y/o',-1,workstring);
	workstring = PRXCHANGE('s/Z+/Z/o',-1,workstring);

	/* Use original first char of surname as first char of key */
	lengthvar=length(workstring);
	IF lengthvar>=5 then NYSIIS = firstChar||substr(workstring,1,5);
	ELSE NYSIIS=firstchar||trim(workstring);

return(NYSIIS);
endsub;
run;

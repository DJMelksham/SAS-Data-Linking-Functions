PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;

/***********************************************************************************************************

PROGRAM NAME: 	Caverphone 2.0
------------------------------------------------------------------------------------------------------------
AUTHOR: 		ORIGINAL: David Hood | SAS ADAPTION: Damien John Melksham
------------------------------------------------------------------------------------------------------------
DATE CREATED: 	3rd June, 2012
------------------------------------------------------------------------------------------------------------
PURPOSE:		A phonetic algorithm developed for approximate matching between names.
		
				This version was based on the instructions contained in the following document:
				http://caversham.otago.ac.nz/files/working/ctp150804.pdf

************************************************************************************************************
COMMENTARY: The original Caverphone algorithm was provided to document the phonetic matching
procedures used in linking the Caversham Project databases, and to give some guidelines for those
attempting similar projects. It was not intended as a general phonetic matching code. Version two 
(this version) of Caverphone has been created as a general purpose English phonetic matching system.

Luckily, the Caverphone algorithm is relatively easy to impliment.  I tested this version against
some of the examples given in the documentation at the URL contained above.

I have fixed a typo or two that I discovered in the original documentation/code, whereby I thought it
easy enough to intuit the author's original intention whereby the code/documentation didn't make sense.
For example, the original documentation contained two consecutive searches for the phrase "enough", but
it involved changing them to "enou2f" and "trou2f" respectively.  I intuited that the second search
was in fact for the phrase "trough" which was to be mapped to the replacement phrase "trou2f" (and it was
confirmed in the python code contained therein as well), even though
there was the typo in the original documentation.
 
************************************************************************************************************/

FUNCTION CAVERPHONE(string_1 $) $ 10;

IF missing(string_1) THEN return('');
/*Set alphabetic characters to lower case and remove everything but lowercase characters */
workstring=compress(LOWCASE(trim(string_1)),,'kl');
length lengthvar 8;

/* remove final 'e' if it exists */
lengthvar=length(workstring);
if substr(workstring,lengthvar,1)='e' THEN DO;
IF lengthvar=1 THEN workstring='e';
ELSE workstring=substr(workstring,1,lengthvar-1);
end;

/* If the name starts with 'cough' make it 'cou2f' */
lengthvar=length(workstring);
IF find(workstring,'cough',-5)=1 then do;
IF lengthvar=5 then workstring='cou2f';
else workstring='cou2f'||substr(workstring,6);
end;

/* If the name starts with 'rough' make it 'rou2f' */
IF find(workstring,'rough',-5)=1 then do;
IF lengthvar=5 then workstring='rou2f';
else workstring='rou2f'||substr(workstring,6);
end;

/* If the name starts with 'tough' make it 'tou2f' */
IF find(workstring,'tough',-5)=1 then do;
IF lengthvar=5 then workstring='tou2f';
else workstring='tou2f'||substr(workstring,6);
end;

/* If the name starts with 'enough' make it 'enou2f' */
IF find(workstring,'enough',-6)=1 then do;
IF lengthvar=6 then workstring='enou2f';
else workstring='enou2f'||substr(workstring,7);
end;
/* If the name starts with 'trough' make it 'trou2f' */
IF find(workstring,'trough',-6)=1 then do;
IF lengthvar=6 then workstring='trou2f';
else workstring='trou2f'||substr(workstring,7);
end;
/* If the name starts with 'gn' make it '2n' */
IF find(workstring,'gn',-2)=1 then do;
IF lengthvar=2 then workstring='2n';
else workstring='2n'||substr(workstring,3);
end;
/* If the name ends with 'mb' make it 'm2' */
IF find(workstring,'mb',-2)=lengthvar-1 then do;
IF lengthvar=2 then workstring='m2';
else workstring=substr(workstring,1,lengthvar-2)||'m2';
end;

/* replace cq with 2q */

workstring=TRANWRD(workstring,'cq','2q');

/* replace ci with si */

workstring=TRANWRD(workstring,'ci','si');

/* replace ce with se */

workstring=TRANWRD(workstring,'ce','se');

/* replace cy with sy */

workstring=TRANWRD(workstring,'cy','sy');

/* replace tch with 2ch */

workstring=TRANWRD(workstring,'tch','2ch');

/* replace c with k */

workstring=TRANWRD(workstring,'c','k');

/* replace q with k */

workstring=TRANWRD(workstring,'q','k');

/* replace x with k */

workstring=TRANWRD(workstring,'x','k');

/* replace v with f */

workstring=TRANWRD(workstring,'v','f');

/* replace dg with 2g */

workstring=TRANWRD(workstring,'dg','2g');

/* replace tio with sio */

workstring=TRANWRD(workstring,'tio','sio');

/* replace tia with sia */

workstring=TRANWRD(workstring,'tia','sia');

/* replace d with t */

workstring=TRANWRD(workstring,'d','t');

/* replace ph with fh */

workstring=TRANWRD(workstring,'ph','fh');

/* replace b with p */

workstring=TRANWRD(workstring,'b','p');

/* replace sh with s2 */

workstring=TRANWRD(workstring,'sh','s2');

/* replace z with s */

workstring=TRANWRD(workstring,'z','s');

/* STAND BACK! I'M USING PERL REGULAR EXPRESSIONS!*/
/* replace initial vowels with A */

workstring=PRXCHANGE('s/^(a|e|i|o|u)/A/o',-1,workstring);

/* replace all other vowels with a 3 */

workstring=PRXCHANGE('s/(a|e|i|o|u)/3/o',-1,workstring);

/* replace j with y */

workstring=TRANSLATE(workstring,'y','j');

/* replace an initial y3 with Y3 */

workstring=PRXCHANGE('s/^y3/Y3/o',-1,workstring);

/* replace an initial y with A */

workstring=PRXCHANGE('s/^y/A/o',-1,workstring);

/* replace y with 3 */

workstring=TRANSLATE(workstring,'3','y');

/* replace 3gh3 with 3kh3 */

workstring=TRANWRD(workstring,'3gh3','3kh3');

/* replace gh with 22 */

workstring=TRANWRD(workstring,'gh','22');

/* replace g with k */

workstring=TRANSLATE(workstring,'k','g');

/* replace groups of the letter s with a S */

workstring=PRXCHANGE('s/s+/S/o',-1,workstring);

/* replace groups of the letter t with a T */

workstring=PRXCHANGE('s/t+/T/o',-1,workstring);

/* replace groups of the letter p with a P */

workstring=PRXCHANGE('s/p+/P/o',-1,workstring);

/* replace groups of the letter k with a K */

workstring=PRXCHANGE('s/k+/K/o',-1,workstring);

/* replace groups of the letter f with a F */

workstring=PRXCHANGE('s/f+/F/o',-1,workstring);

/* replace groups of the letter m with a M */

workstring=PRXCHANGE('s/m+/M/o',-1,workstring);

/* replace groups of the letter n with a N */

workstring=PRXCHANGE('s/n+/N/o',-1,workstring);

/* replace w3 with W3 */

workstring=TRANWRD(workstring,'w3','W3');

/* replace wh3 with Wh3 */

workstring=TRANWRD(workstring,'wh3','Wh3');

/* if the name ends in w replace the final w with 3 */

workstring=PRXCHANGE('s/w$/3/o',-1,trim(workstring));

/* replace w with 2 */

workstring=TRANSLATE(workstring,'2','w');

/* replace an initial h with an A */

workstring=PRXCHANGE('s/^h/A/o',-1,workstring);

/* replace all other occurrences of h with a 2 */

workstring=TRANSLATE(workstring,'2','h');

/* replace r3 with R3 */

workstring=TRANWRD(workstring,'r3','R3');

/* if the name ends in r replace the final r with 3*/

workstring=PRXCHANGE('s/r$/3/o',-1,trim(workstring));

/* replace r with 2 */

workstring=TRANSLATE(workstring,'2','r');

/* replace l3 with L3 */

workstring=TRANWRD(workstring,'l3','L3');

/* if the name ends in l replace the final l with 3 */

workstring=PRXCHANGE('s/l$/3/o',-1,trim(workstring));

/* replace l with 2 */

workstring=TRANSLATE(workstring,'2','l');

/* remove all 2's */

workstring=TRANSTRN(workstring,'2',trimn(''));

/* if the name ends in 3, replace the final 3 with A */

workstring=PRXCHANGE('s/3$/A/o',-1,trim(workstring));

/* remove all 3's */

workstring=TRANSTRN(workstring,'3',trimn(''));

/* put ten 1's on the end */

workstring=trim(workstring)||'1111111111';

/* take the first ten characters as the code */

CAVERPHONEValue=substr(workstring,1,10);

return(CAVERPHONEValue);
endsub;
run;
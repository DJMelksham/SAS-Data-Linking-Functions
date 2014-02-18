PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;
FUNCTION winkler(string_1 $,string_2 $,score);
if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>26 then length1=26;
length2=length(string_2);
if length2>26 then length2=26;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{26} $ 1 _temporary_;
array String2{26} $ 1 _temporary_;
array String1Match{26} $ 1 _temporary_;
array String2Match{26} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We set i back to 1, and introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 THEN return(0);

/* If m=1, we check the first letter of the two strings.  If it matches, then there is 1 common character at the start of the string */

else if m=1 then do;
if String1{1}^=String2{1} then do;
/* If m=1 and the first letter of the two strings did not match, then there are no transpositions, and the strings do not have
a common character at the start of the string */
t=0;
s=0;
end;
else do;
t=0;
s=1;
end;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
s will be the number of common characters at the start of the string with a maximum of 4.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
s=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1;
		ELSE IF c=s+1 AND c<=4 AND c=i THEN s=s+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));
winklertest=jaro+((s*score)*(1-jaro));

return(winklertest);
end;

endsub;


FUNCTION jaroT(string_1 $,string_2 $);

if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>26 then length1=26;
length2=length(string_2);
if length2>26 then length2=26;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{26} $ 1 _temporary_;
array String2{26} $ 1 _temporary_;
array String1Match{26} $ 1 _temporary_;
array String2Match{26} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 then return(0);

else if m=1 then do;
t=0;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));

return(jaro);
end;

endsub;

/*FUNCTION fuzznum(num_1,num_2,diff,direction);*/
/*IF direction=-1 THEN DO;*/
/*	IF num_1-num_2<=diff AND num_1-num_2>=0 THEN RETURN(1);*/
/*	ELSE RETURN(0);*/
/*	END;*/
/*IF direction=1 THEN DO;*/
/*	IF num_1-num_2>=-(diff) AND num_1-num_2<=0 THEN RETURN(1);*/
/*	ELSE RETURN(0);*/
/*	END;*/
/*IF direction=0 THEN DO;*/
/*	IF ABS(num_1-num_2)<=diff THEN RETURN(1);*/
/*	ELSE RETURN(0);*/
/*	END;*/
/*endsub;*/

FUNCTION winklerT52(string_1 $,string_2 $,score);
if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>52 then length1=52;
length2=length(string_2);
if length2>52 then length2=52;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{52} $ 1 _temporary_;
array String2{52} $ 1 _temporary_;
array String1Match{52} $ 1 _temporary_;
array String2Match{52} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We set i back to 1, and introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 THEN return(0);

/* If m=1, we check the first letter of the two strings.  If it matches, then there is 1 common character at the start of the string */

else if m=1 then do;
if String1{1}^=String2{1} then do;
/* If m=1 and the first letter of the two strings did not match, then there are no transpositions, and the strings do not have
a common character at the start of the string */
t=0;
s=0;
end;
else do;
t=0;
s=1;
end;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
s will be the number of common characters at the start of the string with a maximum of 4.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
s=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1;
		ELSE IF c=s+1 AND c<=4 AND c=i THEN s=s+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));
winklertest=jaro+((s*score)*(1-jaro));

return(winklertest);
end;

endsub;


FUNCTION jaroT52(string_1 $,string_2 $);

if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>52 then length1=52;
length2=length(string_2);
if length2>52 then length2=52;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{52} $ 1 _temporary_;
array String2{52} $ 1 _temporary_;
array String1Match{52} $ 1 _temporary_;
array String2Match{52} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 then return(0);

else if m=1 then do;
t=0;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));

return(jaro);
end;

endsub;

FUNCTION winklerT200(string_1 $,string_2 $,score);
if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>200 then length1=200;
length2=length(string_2);
if length2>200 then length2=200;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{200} $ 1 _temporary_;
array String2{200} $ 1 _temporary_;
array String1Match{200} $ 1 _temporary_;
array String2Match{200} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We set i back to 1, and introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 THEN return(0);

/* If m=1, we check the first letter of the two strings.  If it matches, then there is 1 common character at the start of the string */

else if m=1 then do;
if String1{1}^=String2{1} then do;
/* If m=1 and the first letter of the two strings did not match, then there are no transpositions, and the strings do not have
a common character at the start of the string */
t=0;
s=0;
end;
else do;
t=0;
s=1;
end;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
s will be the number of common characters at the start of the string with a maximum of 4.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
s=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1;
		ELSE IF c=s+1 AND c<=4 AND c=i THEN s=s+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));
winklertest=jaro+((s*score)*(1-jaro));

return(winklertest);
end;

endsub;


FUNCTION jaroT200(string_1 $,string_2 $);

if STRING_1=STRING_2 THEN return(1);
else do;
length1=length(string_1);
if length1>200 then length1=200;
length2=length(string_2);
if length2>200 then length2=200;
range=(int(max(length1,length2)/2)-1);
big=max(length1,length2);
short=min(length1,length2);
array String1{200} $ 1 _temporary_;
array String2{200} $ 1 _temporary_;
array String1Match{200} $ 1 _temporary_;
array String2Match{200} $ 1 _temporary_;

/*The following two do loops place the characters into arrays labelled string1 and string2. 
While we are here, we also set a second array of the same dimensions full of zeros.  This will
act as our match key, whereby values in the same relative position as those in the original string
will be set to 1 when we find a valid match candidate later on.*/

do i=1 to length1 by 1;
    String1{i}=substr(string_1,i,1);
	String1Match{i}='0';
end;

do i=1 to length2 by 1;
    String2{i}=substr(string_2,i,1);
	String2Match{i}='0';
end;

/*We introduce m, which will keep track of the number of matches */

m=0;

/*We set a loop to compare one string with the other.  We only need to loop the same number of
times as there are characters in one of our strings.  Hence "do while i<=length1".

We set the allowable search range for a character using pos and endpos, and set another loop to
search through this range.  We loop through until we find our first match, or until we hit
the end of our search range.  If the character in string 2 is already signed to a match, we move
on to searching the next character.  When we find a match, the match flag for that character in both
strings is set to 1.  Hopefully by the end of the loop, we have match flags for our two arrays set.

*/

do i=1 to length1 by 1;
pos=max(i-range,1);
endpos=min(range+i,length2);
	do while (pos<=endpos and String1Match{i}^='1');
	if String1{i}=String2{pos} and String2Match{pos}^='1' then do;
		m=m+1;
		String1Match{i}='1';
		String2Match{pos}='1';
		end;
	pos=pos+1;
	end;
end;

/* If there are no matching characters, we do not bother with any more work, and say the two strings are not alike at all */

IF m=0 then return(0);

else if m=1 then do;
t=0;
end;

/* If those three conditions all fail, then we move onto the heavy lifting.*/

else do;

/* We set i back to 1, ready for another looping run.  

c is a variable to track the position of the next valid transposition check.
j is a variable helping to keep track of matching characters found during the next loop inside string 1.
k is a variable helping to keep track of matching characters found during the next loop inside string 2.
t will be the number of tranpositions found.

*/

i=1;
c=1;
k=0;
j=0;
t=0;

/* We begin our loop.  These conditional loops within loops 
make several logical conclusions to arrive at the correct number of transpositions and matching characters 
at the beginning of a string.  At the end of this we should have every variable we need to calculate the winkler
score (and theoretically the jaro as well).  I'm not going to write out an explanation here, but if you're
interested all the extra variables are defined just above this comment, and I've already told you what the
string arrays are.  Work through a couple of examples with pen and paper, or in your head, to see how 
and why it works.*/

do while (j<m OR k<m);
	IF j<m then do;
		IF String1Match{i}='1' THEN DO;
			j=j+1;
			String1{j}=String1{i};
		end;
	end;
	IF k<m then do;
		IF String2Match{i}='1' THEN DO;
			k=k+1;
			String2{k}=String2{i};
		end;
	end;
	IF j>=c and k>=c then do;
		IF String1{c}^=String2{c} then t=t+1; 
	c=c+1;
	end;
i=i+1;
end;
end;

/* Finally, we do the calculation of the scores */

jaro=(1/3)*((m/length1)+(m/length2)+((m-(t/2))/m));

return(jaro);
end;

endsub;

run;
PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;

FUNCTION lowfuzz(num_1,num_2,diff);

	IF missing(num_1) OR missing(num_2) or missing(diff) then return(.);
	else IF num_1-num_2<=diff AND num_1-num_2>=0 THEN RETURN(1);
	ELSE RETURN(0);

endsub;

FUNCTION highfuzz(num_1,num_2,diff);

	IF missing(num_1) OR missing(num_2) or missing(diff) then return(.);
	else IF num_1-num_2>=-(diff) AND num_1-num_2<=0 THEN RETURN(1);
	ELSE RETURN(0);

endsub;

FUNCTION genfuzz(num_1,num_2,diff);

	IF missing(num_1) OR missing(num_2) or missing(diff) then return(.);
	else IF ABS(num_1-num_2)<=diff THEN RETURN(1);
	ELSE RETURN(0);

endsub;

run;
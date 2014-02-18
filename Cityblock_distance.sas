PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;
FUNCTION CITYBLOCK2(a1,b1,a2,b2);
if missing(a1) or missing(b1) or missing(a2) or missing(b2) then return(.);
distance=ABS(a1-a2)+ABS(b1-b2);
return(distance);
endsub;

FUNCTION CITYBLOCK3(a1,b1,c1,a2,b2,c2);
if missing(a1) or missing(b1) or missing(c1) or missing(a2) or missing(b2) or missing(c2) then return(.);
distance=ABS(a1-a2)+ABS(b1-b2)+ABS(c1-c2);
return(distance);
endsub;

run;
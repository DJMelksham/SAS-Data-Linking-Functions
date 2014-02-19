PROC FCMP outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;
FUNCTION MINKOWSKI2(a1,b1,a2,b2,p);
if missing(a1) or missing(b1) or missing(a2) or missing(b2) or missing(p) then return(.);
distance=((ABS(a1-a2))**p+(ABS(b1-b2))**p)**(1/p);
return(distance);
endsub;

FUNCTION MINKOWSKI3(a1,b1,c1,a2,b2,c2,p);
if missing(a1) or missing(b1) or missing(c1) or missing(a2) or missing(b2) or missing(c2) or missing(p) then return(.);
distance=((ABS(a1-a2))**p+(ABS(b1-b2))**p+(ABS(c1-c2))**p)**(1/p);
return(distance);
endsub;
run;
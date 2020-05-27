LABEL "genrand" ;
DATA R0, RNG ;
OUTA R0 ;
IND R0 ;

REM "Select char" ;
CLF ;
SHR R0, R0 ;
JC '@a' ;
DATA R1, 47 ;
GOTO "printR1" ;
LABEL "a" ;
DATA R1, 92 ;

LABEL "printR1" ;
DATA R0, TTY ;
OUTA R0 ;
OUTD R1 ;
GOTO "genrand" ;
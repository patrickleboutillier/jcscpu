use strict ;
use jcsasm ;
use STACK ;

STACK::init() ;

DATA R2, 20 ;
DATA R3, 22 ;
PUSH R2 ;
PUSH R3 ;

GOTO "add" ;

LABEL "add" ;
POP R1 ;
POP R0 ;

ADD R1, R0 ;
PUSH R0 ;
DUMP ;
DEBUG0 ;
HALT ;


__DATA__


JMP '@start' ;
CLF ;
LABEL "start" ;
DUMP ;
DEBUG0 ;

DATA R2, 20 ;
DATA R3, 22 ;

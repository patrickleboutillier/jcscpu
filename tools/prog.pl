use strict ;
use jcsasm ;
use STACK ;

STACK::init() ;

DATA R1, 20 ;
DATA R2, 22 ;
DATA R3, 1 ;
PUSH R1 ;
PUSH R2 ;
PUSH R3 ;
GOTO "add3" ;
POP R0 ;
DUMP ;
DEBUG0 ;
HALT ;

LABEL "add" ;
LR R0 ;
POP R1 ;
POP R2 ;
ADD R1, R2 ;
PUSH R2 ;
JMPR R0 ;

LABEL "add3" ;
LR R0 ;
POP R1 ;
POP R2 ;
POP R3 ;
PUSH R0 ;
PUSH R1 ;
PUSH R2 ;
PUSH R3 ;
CALL "add" ;
CALL "add" ;
POP R1 ;
POP R0 ;
PUSH R1 ;
JMPR R0 ;

__DATA__


JMP '@start' ;
CLF ;
LABEL "start" ;
DUMP ;
DEBUG0 ;

DATA R2, 20 ;
DATA R3, 22 ;

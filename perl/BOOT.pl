use strict ;
use jcsasm ;
use Devices ;

REM "R0 is our ROM address, R1 is our ROM size, R2 is our 1, R3 is our ROM data" ;
REM "Initialize R0 to 0" ;
DATA R0, 0 ;

REM "Activate ROMSize and place value in R1" ;
DATA R1, 3 ;
OUTA R1 ;
IND R1 ;

REM "Initialize R2 to 1" ;
DATA R2, 1 ;

REM "Activate ROM" ;
DATA R3, 2 ;
OUTA R3 ;

my $loop = LABEL "getnextinst" ;
OUTD R3 ;
REM "Receive data in R3 and copy it to RAM at address that is in R0" ;
IND R3 ;
ST R0, R3 ;

REM "Increment R0" ;
ADD R2, R0 ;

REM "IF R0 == R1, jump to byte 0 in RAM" ;
CMP R0, R1 ;
JE 0 ;
REM "(ELSE) Loop back" ;
JMP $loop ;
HALT ;
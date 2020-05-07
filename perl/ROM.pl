use strict ;
use jcsasm ;
use Devices ;

# Activate ROM
DATA R0, DEVICES::ROM() ;
OUTA R0 ;
DATA R0, 1 ;
DATA R3, 0 ;
DATA R1, 0 ;
# Ask for address in R1
my $loop = LABEL "loop" ;
OUTD R1 ;
# Receive data in R2 and copy it to RAM at address that is in R1
IND R2 ;
ST R2, R1 ;
CMP R2, R3 ;
JE 0 ;
# Increment R1
ADD R0, R1 ;
JMP $loop ;
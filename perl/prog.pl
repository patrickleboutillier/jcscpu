use strict ;
use jcsasm ;
use Devices ;

DATA R0, 20 ;
DATA R1, 22 ;
ADD R0, R1 ;
DATA R0, DEVICES::TTY() ;
OUTA R0 ;
OUTD R1 ;
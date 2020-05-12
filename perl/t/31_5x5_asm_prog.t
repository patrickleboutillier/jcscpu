use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;
use jcsasm ;

plan(tests => 1) ;

my $BB = new BREADBOARD('instproc' => 1, 'instimpl' => 1, 'insts' => 'all', 'devs' => ['TTY']) ;

# Load our program into RAM
$BB->initRAMl(ASM {
    DATA R0, 5 ;
    DATA R1, 5 ;
    DATA R3, 1 ;
    XOR R2, R2 ;
    CLF ;
    SHR R0, R0 ;
    JC 13 ;
    JMP 15 ;
    CLF ;
    ADD R1, R2 ;
    CLF ;
    SHL R1, R1 ;
    SHL R3, R3 ;
    JC 22 ;
    JMP 7 ;
    DATA R3, 100 ;
    ST R3, R2 ;
    HALT ;
}) ;


$BB->on_halt(sub {
    is($BB->get("RAM")->peek(sprintf("%08b", 100)), sprintf("%08b", 25)) ;
}) ;


# HALT instruction will stop the computer
$BB->get("CLK")->start() ;
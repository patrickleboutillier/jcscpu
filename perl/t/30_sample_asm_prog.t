use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;
use jcsasm ;

plan(tests => 7) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => ['TTY'],
) ;

pipe(READ, WRITE) ;
$DEVICES::TTY_OUTPUT = \*WRITE ;

# Load our program into RAM
$BB->initRAMl(ASM {
    DATA R0, 20 ;
    DATA R1, 22 ;
    ADD R0, R1 ;
    DATA R0, DEVICES::TTY() ;
    OUTA R0 ;
    OUTD R1 ;
    HALT ;
}) ;

$BB->inst() ;
is($BB->get("R0")->power(), "00010100") ;
$BB->inst() ;
is($BB->get("R1")->power(), "00010110") ;
$BB->inst() ;
is($BB->get("R1")->power(), "00101010") ;
$BB->inst() ;
is($BB->get("R0")->power(), "00000001") ;
$BB->inst() ;
is($BB->get("IO.adapter")->active(DEVICES::TTY()), 1, "TTY is active") ;
$BB->inst() ;
my $char = undef ;
my $nb = sysread(\*READ, $char, 1) ;
is($nb, 1, "One byte returned by sysread") ;
is($char, "*", "*") ;

# HALT instruction will stop the computer
$BB->get("CLK")->start() ;
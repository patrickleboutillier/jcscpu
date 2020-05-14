use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;
use jcshll ;

plan(tests => 5) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => ['TTY'],
) ;

pipe(READ, WRITE) ;
$DEVICES::TTY_OUTPUT = \*WRITE ;

# Load our program into RAM
$BB->initRAMl(HLL {
    my $a = VAR(20) ;
    my $b = VAR(22) ;
    my $c = PLUS($a, $b) ;
    PRINT($c) ;
}) ;


$BB->inst(3) ;
is($BB->get("RAM")->peek("11111111"), sprintf("%08b", 20)) ;
$BB->inst(3) ;
is($BB->get("RAM")->peek("11111110"), sprintf("%08b", 22)) ;
$BB->inst(8) ;
is($BB->get("RAM")->peek("11111101"), sprintf("%08b", 42)) ;
$BB->inst(5) ;
my $char = undef ;
my $nb = sysread(\*READ, $char, 1) ;
is($nb, 1, "One byte returned by sysread") ;
is($char, "*", "*") ;

# HALT instruction will stop the computer
$BB->get("CLK")->start() ;
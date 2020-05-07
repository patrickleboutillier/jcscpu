use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;

plan(tests => 7) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => 'all',
) ;

pipe(READ, WRITE) ;
$DEVICES::TTY_OUTPUT = \*WRITE ;

# Load our program into RAM
$BB->initRAMh(\*DATA) ;

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

__DATA__
# Place to values in R0 and R1, add them and send the code as ASCII to the TTY.
00100000 # DATA  R0, 00010100 (20)
00010100 # ...   20
00100001 # DATA  R1, 00010110 (22)
00010110 # ...   22
10000001 # ADD   R0, R1
00100000 # DATA  R0, 00000001 (1)
00000001 # ...   1
01111100 # OUTA  R0
01111001 # OUTD  R1
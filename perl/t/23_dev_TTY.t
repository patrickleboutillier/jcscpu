use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;


my $nb_tty_tests = 8 ;
plan(tests => $nb_tty_tests*3) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['IO'],
    'devs' => ['TTY'],
) ;

pipe(READ, WRITE) ;
$DEVICES::TTY_OUTPUT = \*WRITE ;

map { make_tty_test() } (1..$nb_tty_tests) ;


sub make_tty_test {
    # Generate a random register
    my $rb = int rand(4) ;
    my $iaddr = sprintf("%08b", int rand(256)) ;
    my $data = sprintf("%08b", int rand(256)) ;

    # First, activate the device
    my $iinst = sprintf("011111%02b", $rb) ;
    $BB->setREG("R$rb", sprintf("%08b", DEVICES::TTY())) ;
    $BB->setRAM($iaddr, $iinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("IO.adapter")->active(DEVICES::TTY()), 1, "TTY is active") ;

    # Then, send data to the device
    my $iinst = sprintf("011110%02b", $rb) ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    my $char = undef ;
    my $nb = sysread(\*READ, $char, 1) ;
    is($nb, 1, "One byte returned by sysread") ;
    is(ord($char), oct("0b$data"), "Byte written ($data) was received through the pipe") ;
}





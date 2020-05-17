use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;
use IO::Handle ;


my $nb_rng_tests = 8 ;
plan(tests => $nb_rng_tests*2) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['IO'],
    'devs' => ['RNG'],
) ;

map { make_rng_test() } (1..$nb_rng_tests) ;


sub make_rng_test {
    # Generate a random register
    my $rb = int rand(4) ;
    my $iaddr = sprintf("%08b", int rand(256)) ;
    my $data = sprintf("%08b", int rand(256)) ;

    # First, activate the device
    my $iinst = sprintf("011111%02b", $rb) ;
    $BB->setREG("R$rb", sprintf("%08b", DEVICES::RNG())) ;
    $BB->setRAM($iaddr, $iinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("IO.adapter")->active(DEVICES::RNG()), 1, "RNG is active") ;

    # Then, get data from the device
    my $iinst = sprintf("011100%02b", $rb) ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $iinst) ;
    $BB->setREG("IAR", $iaddr) ;
    $BB->inst() ;
    is($BB->get("R$rb")->power(), $DEVICES::RNG_LAST, "Byte received equals \$DEVICES::RNG_LAST") ;
    #my $char = undef ;
    #my $nb = sysread(\*READ, $char, 1) ;
    #is($nb, 1, "One byte returned by sysread") ;
    #is(ord($char), oct("0b$data"), "Byte written ($data) was received through the pipe") ;
}





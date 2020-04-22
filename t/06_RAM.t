use strict ;
use Test::More ;
use RAM ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;

plan(tests => 1) ;

my $RAM = new RAM("System memory") ;
my $ba = new BUS([$RAM->as()]) ;
my $wsa = new WIRE($RAM->sa()) ;
my $bio = new BUS([$RAM->ios()]) ;
my $ws = new WIRE($RAM->s()) ;
my $we = new WIRE($RAM->e()) ;
$RAM->show("00000000") ;

# First, setup an address on the MAR input bus and let it in the MAR 
my $addr1 = "10101010" ;
$ba->power($addr1) ;
$wsa->power(1) ;
$wsa->power(0) ;
# warn $RAM->show() ;

# Then setup some data on the I/O bus and store it.
my $data1 = "00011110" ;
$bio->power($data1) ;
$ws->power(1) ;
$ws->power(0) ;
# warn $RAM->show($addr1) ;

# Reset the data bus
$bio->power("00000000") ;
# warn $RAM->show($addr1) ;

# Now if we tune on the e, we should get our data back on the bus.
$we->power(1) ;
# warn $RAM->show($addr1) ;

is($bio->power(), $data1) ;
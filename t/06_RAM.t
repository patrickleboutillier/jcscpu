use strict ;
use Test::More ;
use RAM ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;

plan(tests => 3) ;

my $RAM = new RAM("System memory") ;
my $ba = new BUS([$RAM->as()]) ;
my $wsa = new WIRE($RAM->sa()) ;
my $bio = new BUS([$RAM->ios()]) ;
my $ws = new WIRE($RAM->s()) ;
my $we = new WIRE($RAM->e()) ;
# warn $RAM->show("00000000") ;

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

# Now if we turn on the e, we should get our data back on the bus.
$we->power(1) ;
# warn $RAM->show($addr1) ;
is($bio->power(), $data1) ;
$we->power(0) ;


# Now, setup a different on the MAR input bus and let it in the MAR 
my $addr2 = "11101011" ;
$ba->power($addr2) ;
$wsa->power(1) ;
$wsa->power(0) ;
# warn $RAM->show() ;

# Then setup some data on the I/O bus and store it.
my $data2 = "01111000" ;
$bio->power($data2) ;
$ws->power(1) ;
$ws->power(0) ;
# warn $RAM->show($addr1) ;

# Reset the data bus
$bio->power("00000000") ;
# warn $RAM->show($addr1) ;

# Now if we turn on the e, we should get our data back on the bus.
$we->power(1) ;
# warn $RAM->show($addr1) ;
is($bio->power(), $data2) ;
$we->power(0) ;


# Now, get back the data from the first address 
$ba->power($addr1) ;
$wsa->power(1) ;
$wsa->power(0) ;
# warn $RAM->show() ;

# Now if we tune on the e, we should get our data back on the bus.
$we->power(1) ;
# warn $RAM->show($addr1) ;
is($bio->power(), $data1) ;
$we->power(0) ;

exit() ;

my @ts = tuples_with_repetition([0, 1], 8) ;
# splice(@ts, 6) ;
# warn Dumper(\@ts) ;
my @ts = ([0,0,0,0,0,0,0,0] , [1,1,1,1,1,1,1,1]) ; # , [1,0,1,0,1,0,1,0]) ;
foreach my $t (@ts){
    my $addr = join('', @{$t}) ;
    $ba->power($addr) ;
    $wsa->power(1) ;
    $wsa->power(0) ;
    # Then setup some data on the I/O bus and store it.
    my $data = join('', reverse @{$t}) ;
    $bio->power($data) ;
    $ws->power(1) ;
    $ws->power(0) ;
    # warn $RAM->show("$addr") ;
}

foreach my $t (@ts){
    my $addr = join('', @{$t}) ;
    warn $RAM->show("$addr") ;
    $ba->power($addr) ;
    $wsa->power(1) ;
    $wsa->power(0) ;
    warn $RAM->show("$addr") ;

    # Now if we turn on the e, we should get our data back on the bus.
    $GATES::DEBUG = 0 ;
    $we->power(1) ;
    warn $RAM->show("$addr") ;
    my $data = join('', reverse @{$t}) ;
    is($bio->power(), $data) ;
    $we->power(0) ;
    warn $RAM->show("$addr") ;
    exit ;
}


use strict ;
use Test::More ;
use RAM ;
use Data::Dumper ;


my $nb_ram_tests = 256 ;
plan(tests => 3 + $nb_ram_tests) ;


my $ba = new BUS() ;
my $wsa = new WIRE() ;
my $bio = new BUS() ;
my $ws = new WIRE() ;
my $we = new WIRE() ;
my $RAM = new RAM($ba, $wsa, $bio, $ws, $we, "System memory") ;
$RAM->show("00000000") ; # coverage...

# First, setup an address on the MAR input bus and let it in the MAR 
my $addr1 = "10101010" ;
$ba->power($addr1) ;
$wsa->power(1) ;
$wsa->power(0) ;

# Then setup some data on the I/O bus and store it.
my $data1 = "00011110" ;
$bio->power($data1) ;
$ws->power(1) ;
$ws->power(0) ;

# Now if we turn on the e, we should get our data back on the bus.
$we->power(1) ;
is($bio->power(), $data1) ;
$we->power(0) ;

# Now, setup a different on the MAR input bus and let it in the MAR 
my $addr2 = "11101011" ;
$ba->power($addr2) ;
$wsa->power(1) ;
$wsa->power(0) ;

# Then setup some data on the I/O bus and store it.
my $data2 = "01111000" ;
$bio->power($data2) ;
$ws->power(1) ;
$ws->power(0) ;

# Now if we turn on the e, we should get our data back on the bus.
$we->power(1) ;
is($bio->power(), $data2) ;
$we->power(0) ;

# Now, get back the data from the first address 
$ba->power($addr1) ;
$wsa->power(1) ;
$wsa->power(0) ;

# Now if we tune on the e, we should get our data back on the bus.
$we->power(1) ;
is($bio->power(), $data1) ;
$we->power(0) ;

make_ram_test(1) ;

sub make_ram_test {
    my $random = shift ;

    my @ts = map { int rand(255) } (1..$nb_ram_tests) ;
    foreach my $t (@ts){
        my $addr = sprintf("%08b", $t) ;
        $ba->power($addr) ;
        $wsa->power(1) ;
        $wsa->power(0) ;
        # Then setup some data on the I/O bus and store it.
        my $data = join('', scalar(reverse($addr))) ;
        $bio->power($data) ;
        $ws->power(1) ;
        $ws->power(0) ;
    }

    foreach my $t (@ts){
        my $addr = sprintf("%08b", $t) ;
        $ba->power($addr) ;
        $wsa->power(1) ;
        $wsa->power(0) ;

        # Now if we turn on the e, we should get our data back on the bus.
        $we->power(1) ;
        my $data = join('', scalar(reverse($addr))) ;
        is($bio->power(), $data) ;
        $we->power(0) ;
    }
}


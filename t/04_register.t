use strict ;
use Test::More ;
use Register ;
use Data::Dumper ;

plan(tests => 20) ;

# Basic test for REGISTER circuit.
my $R = new REGISTER() ;
my $bin = new BUS([$R->is()]) ;
my $bout = new BUS([$R->os()]) ;
my $ws = new WIRE($R->s()) ;
my $we = new WIRE($R->e()) ;
$R->show() ;

# Let input from the input bus into the register and turn on the enabler
$ws->power(1) ;
$we->power(1) ;
is($bout->power(), "00000000", "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0") ;
$ws->power(0) ;
$bin->wire(0)->power(1) ;
is($bout->power(), "00000000", "R(i:10000000,s:0,e:1)=o:00000000, s=off, e=on, since s=off, output should be 0") ;
$ws->power(1) ;
is($bout->power(), "10000000", "R(i:10000000,s:1,e:1)=o:10000000, s=on, e=on, both s and e on, i should flow to o") ;
$ws->power(0) ;
$we->power(0) ;
is($bout->power(), "00000000", "R(i:10000000,s:0,e:0)=o:00000000, s=on, e=off, no output since e=off") ;
$bin->wire(0)->power(0) ;
$ws->power(1) ;
$we->power(1) ;
is($bout->power(), "00000000", "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, i flows, so 0") ;


# Some BUS coverage tests
is(scalar($bin->wires()), 8, "8 wires in a bundle") ;
eval {
    $bin->wire(-1) ;
} ;
like($@, qr/Bad wire/, "Invalid wire index <0") ;
eval {
    $bin->wire(10) ;
} ;
like($@, qr/Bad wire/, "Invalid wire index >7") ;
eval {
    $bin->power("1100") ;
} ;
like($@, qr/Invalid bus power string/, "Invalid bus power string <8") ;
eval {
    my @is = $R->is() ;
    pop @is ;
    $bin->connect([@is]) ;
} ;
like($@, qr/Invalid bundle count/, "Invalid bundle count (7)") ;


# Tests using a REGISTRY with input and output on the same BUS.
my $R = new REGISTER() ;
my $bio = new BUS([$R->is()], [$R->os()]) ;
my $ws = new WIRE($R->s()) ;
my $we = new WIRE($R->e()) ;

# Let input from the input bus into the register and turn on the enabler
$ws->power(1) ;
$we->power(1) ;
is($bio->power(), "00000000", "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0") ;
$ws->power(0) ;
$we->power(0) ;
# Setup up the bus with our desired data, and let in into the registry.
$bio->power("10101010") ;
is($bio->power(), "10101010", "Data setup") ;
$ws->power(1) ;
$ws->power(0) ;
# Reset bus
$bio->power("00000000") ;
is($bio->power(), "00000000", "Bus reset") ;
$we->power(1) ;
is($bio->power(), "10101010", "Data restored") ;


# Multiple registries.
my $R1 = new REGISTER() ;
my $R2 = new REGISTER() ;
my $R3 = new REGISTER() ;
my $bio = new BUS([$R1->is()], [$R1->os()], [$R2->is()], [$R2->os()], [$R3->is()], [$R3->os()]) ;
my $ws1 = new WIRE($R1->s()) ;
my $we1 = new WIRE($R1->e()) ;
my $ws2 = new WIRE($R2->s()) ;
my $we2 = new WIRE($R2->e()) ;
my $ws3 = new WIRE($R3->s()) ;
my $we3 = new WIRE($R3->e()) ;

# Put something on the bus.
$bio->power("00001111") ;
is($bio->power(), "00001111", "Data setup") ;
# Let it go into R1
$ws1->power(1) ;
$ws1->power(0) ;
# Check it is into R1
$we1->power(1) ;
is($bio->power(), "00001111", "From R1") ;
$we1->power(0) ;
# Copy into R3
$we1->power(1) ;
$ws3->power(1) ;
$ws3->power(0) ;
# Reset bus
$bio->power("00000000") ;
is($bio->power(), "00000000", "Reset") ;
$we3->power(1) ;
is($bio->power(), "00001111", "From R3") ;
$we3->power(0) ;
# Copy to R2
$we3->power(1) ;
$ws2->power(1) ;
$ws2->power(0) ;
# Reset bus
$bio->power("00000000") ;
is($bio->power(), "00000000", "Reset") ;
$we2->power(1) ;
is($bio->power(), "00001111", "From R2") ;
$we3->power(0) ;


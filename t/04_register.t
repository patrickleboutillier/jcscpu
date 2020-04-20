use strict ;
use Test::More ;
use Register ;
use Data::Dumper ;

plan(tests => 9) ;

# Basic test for REGISTER circuit.
my $R = new REGISTER() ;
my $bin = new BUS([$R->is()]) ;
my $bout = new BUS([$R->os()]) ;
my $ws = new WIRE($R->s()) ;
my $we = new WIRE($R->e()) ;

# Let input from the input bus into the register and turn on the enabler
$ws->power(1) ;
$we->power(1) ;
is($bout->show(), "00000000", "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0") ;
$ws->power(0) ;
$bin->wire(0)->power(1) ;
is($bout->show(), "00000000", "R(i:10000000,s:0,e:1)=o:00000000, s=off, e=on, since s=off, output should be 0") ;
$ws->power(1) ;
is($bout->show(), "10000000", "R(i:10000000,s:1,e:1)=o:10000000, s=on, e=on, both s and e on, i should flow to o") ;
$ws->power(0) ;
$we->power(0) ;
is($bout->show(), "00000000", "R(i:10000000,s:0,e:0)=o:00000000, s=on, e=off, no output since e=off") ;
$bin->wire(0)->power(0) ;
$ws->power(1) ;
$we->power(1) ;
is($bout->show(), "00000000", "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, i flows, so 0") ;

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
    my @is = $R->is() ;
    pop @is ;
    $bin->connect([@is]) ;
} ;
like($@, qr/Invalid bundle count/, "Invalid bundle count (7)") ;
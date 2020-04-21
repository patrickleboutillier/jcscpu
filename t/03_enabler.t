use strict ;
use Test::More ;
use Enabler ;

plan(tests => 7) ;

# Basic test for ENABLER circuit.
my $E = new ENABLER() ;
my @eis = $E->is() ;
my @wis = WIRE->new_wires($E->is()) ;
my $we = new WIRE($E->e()) ;
my @wos = WIRE->new_wires($E->os()) ;

$wis[0]->power(1) ;
is(WIRE->power_wires(@wos), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, no output") ;
$wis[4]->power(1) ;
is(WIRE->power_wires(@wos), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, i should equal o") ;
$we->power(1) ;
is(WIRE->power_wires(@wos), "10001000", "B(i:10001000,e:1)=o:10001000, e=on, i goes through") ;
$wis[4]->power(0) ;
is(WIRE->power_wires(@wos), "10000000", "B(i:10000000,e:1)=o:10000000, e=on, i goes through") ;
$wis[0]->power(0) ;
is(WIRE->power_wires(@wos), "00000000", "B(i:00000000,e:1)=o:00000000, e=on, i goes through") ;
$wis[7]->power(1) ;
is(WIRE->power_wires(@wos), "00000001", "B(i:00000001,e:1)=o:00000001, e=on, i goes through") ;
$we->power(0) ;
is(WIRE->power_wires(@wos), "00000000", "B(i:00000001,e:0)=o:00000000, e=off, no output") ;

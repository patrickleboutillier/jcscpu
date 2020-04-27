use strict ;
use Test::More ;
use Enabler ;

plan(tests => 7) ;

# ENABLER
my $wis = new WIRES(8) ;
my $we = new WIRE() ;
my $wos = new WIRES(8) ;
my $E = new ENABLER($wis, $we, $wos) ;

$wis->wire(0)->power(1) ;
is($wos->power(), "00000000", "B(i:10000000,e:0)=o:00000000, e=off, no output") ;
$wis->wire(4)->power(1) ;
is($wos->power(), "00000000", "B(i:10001000,e:0)=o:00000000, e=off, no output") ;
$we->power(1) ;
is($wos->power(), "10001000", "B(i:10001000,e:1)=o:10001000, e=on, i goes through") ;
$wis->wire(4)->power(0) ;
is($wos->power(), "10000000", "B(i:10000000,e:1)=o:10000000, e=on, i goes through") ;
$wis->wire(0)->power(0) ;
is($wos->power(), "00000000", "B(i:00000000,e:1)=o:00000000, e=on, i goes through") ;
$wis->wire(7)->power(1) ;
is($wos->power(), "00000001", "B(i:00000001,e:1)=o:00000001, e=on, i goes through") ;
$we->power(0) ;
is($wos->power(), "00000000", "B(i:00000001,e:0)=o:00000000, e=off, no output") ;
